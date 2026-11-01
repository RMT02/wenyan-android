import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:misskey_dart/misskey_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constant/wenyan.dart';
import '../constant/wenyan_push_types.dart';
import '../i18n/strings.g.dart';
import '../model/account.dart';
import '../model/general_settings.dart';
import '../util/wenyan_notification.dart';
import 'accounts_notifier_provider.dart';
import 'general_settings_notifier_provider.dart';
import 'server_url_notifier_provider.dart';
import 'token_provider.dart';
import 'tokens_notifier_provider.dart';
import 'wenyan_image_resolver_provider.dart';
import 'wenyan_local_notifications_provider.dart';

part 'wenyan_push_service.g.dart';

/// 闻言自建推送通道。
///
/// 设计要点：
/// * 用一个 `remoteMessaging` 类型的前台服务把进程保持在「前台优先级」，
///   避免 App 退到后台后被系统回收，从而让 Dart 侧的长连接继续存活；
/// * 长连接就是 Misskey 官方的 `/streaming` main 频道，服务端已经按用户的
///   `notificationRecieveConfig` 过滤过，客户端只补一层「逐类型开关」；
/// * 通知渲染复用 [showWenyanNotification]，与 UnifiedPush 通路完全一致
///   （同一套通知渠道、分组、头像大图）。
///
/// 边界：Android 把整个进程杀掉（强行停止、清理后台）之后不会再收到推送，
/// 重新打开 App 即自动恢复。
@Riverpod(keepAlive: true)
class WenyanPushService extends _$WenyanPushService {
  final Map<String, _WenyanPushConnection> _connections = {};
  GeneralSettings _settings = const GeneralSettings();
  bool _initialized = false;
  bool _syncing = false;

  /// 大图（头像 / 自定义表情）解析器。
  ///
  /// 图片缓存依赖 Isar，而 Isar 的 provider 是 autoDispose 的，不能在
  /// keepAlive 的 provider 里直接读；由 UI 层初始化时注入到
  /// [wenyanImageResolverProvider] 的持有者里。
  Future<File?> Function(Uri url)? get _imageResolver =>
      ref.read(wenyanImageResolverProvider).resolve;

  @override
  void build() {
    // 用 read + listen 而不是 watch：设置变化只需要重新同步，
    // 不能让 notifier 重建（否则长连接会丢）。
    _settings = ref.read(generalSettingsNotifierProvider);
    ref
      ..listen(generalSettingsNotifierProvider, (previous, next) {
        _settings = next;
        unawaited(sync());
      })
      ..listen(accountsNotifierProvider, (previous, next) {
        unawaited(sync());
      })
      ..listen(tokensNotifierProvider, (previous, next) {
        // token 是异步从安全存储读出来的，读到之后需要重新建立连接。
        unawaited(sync());
      })
      ..onDispose(() {
        unawaited(_closeAll());
      });
    unawaited(sync());
  }

  /// 让后台服务与当前账号/设置保持一致。
  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      _settings = ref.read(generalSettingsNotifierProvider);
      if (!_settings.wenyanPushEnabled) {
        await _stopService();
        await _closeAll();
        return;
      }
      final accounts = _activeAccounts();
      if (accounts.isEmpty) {
        await _stopService();
        await _closeAll();
        return;
      }
      await _startService();
      await _applyConnections(accounts);
    } finally {
      _syncing = false;
    }
  }

  Map<Account, String> _activeAccounts() {
    final result = <Account, String>{};
    for (final account in ref.read(accountsNotifierProvider)) {
      if (account.isGuest) continue;
      final token = ref.read(tokenProvider(account));
      if (token != null) result[account] = token;
    }
    return result;
  }

  Future<void> _initializeService() async {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'wenyan_push_service',
        channelName: t.aria.wenyanPush,
        channelDescription: t.aria.wenyanPushServiceRunning,
        visibility: NotificationVisibility.VISIBILITY_SECRET,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnMyPackageReplaced: true,
      ),
    );
    _initialized = true;
  }

  Future<void> _startService() async {
    await _initializeService();
    if (await FlutterForegroundTask.isRunningService) return;
    final result = await FlutterForegroundTask.startService(
      serviceId: 20209,
      serviceTypes: [ForegroundServiceTypes.remoteMessaging],
      notificationTitle: wenyanAppName,
      notificationText: t.aria.wenyanPushServiceRunning,
    );
    if (result is ServiceRequestFailure) {
      // 通知权限被拒或系统限制时，仍然尝试在进程存活期间推送。
      _ignore(result.error);
    }
  }

  Future<void> _stopService() async {
    if (!_initialized) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  Future<void> _closeAll() async {
    for (final connection in _connections.values) {
      await connection.close();
    }
    _connections.clear();
  }

  Future<void> _applyConnections(Map<Account, String> accounts) async {
    for (final entry in _connections.entries.toList()) {
      final account = entry.value.account;
      if (!accounts.containsKey(account) ||
          accounts[account] != entry.value.token) {
        await entry.value.close();
        _connections.remove(entry.key);
      }
    }
    for (final entry in accounts.entries) {
      final key = entry.key.toString();
      if (_connections.containsKey(key)) continue;
      final connection = _WenyanPushConnection(
        account: entry.key,
        token: entry.value,
        settings: () => _settings,
        serverUrl: ref.read(serverUrlNotifierProvider(entry.key.host)),
        onNotification: _showNotification,
      );
      _connections[key] = connection;
      unawaited(connection.connect());
    }
  }

  Future<void> _showNotification(
    Account account,
    PushNotification notification,
  ) async {
    try {
      await showWenyanNotification(
        plugin: ref.read(wenyanLocalNotificationsPluginProvider),
        account: account,
        notification: notification,
        generalSettings: _settings,
        serverUrl: ref.read(serverUrlNotifierProvider(account.host)),
        resolveImage: _imageResolver ?? (url) async => null,
      );
    } catch (error, stackTrace) {
      // 通知渲染失败绝不能影响 App 正常使用，但也不能静默吞掉：
      // 曾经因为「渠道分组未创建」被吞掉整整一轮排查。
      debugPrint('[wenyan-push] 渲染通知失败: $error\n$stackTrace');
    }
  }

  void _ignore(Object? error) {
    debugPrint('[wenyan-push] $error');
  }
}

/// 一个账号在 `/streaming` 上的 main 频道长连接。
class _WenyanPushConnection {
  new({
    required this.account,
    required this.token,
    required this.settings,
    required this.serverUrl,
    required this.onNotification,
  });

  final Account account;
  final String token;
  final GeneralSettings Function() settings;
  final Uri serverUrl;
  final Future<void> Function(Account account, PushNotification notification)
  onNotification;

  WebSocket? _webSocket;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  bool _closed = false;
  int _retryCount = 0;

  bool get connected => _webSocket != null;

  Future<void> connect() async {
    if (_closed) return;
    _reconnectTimer?.cancel();
    try {
      final url = serverUrl.replace(
        scheme: serverUrl.scheme == 'https' ? 'wss' : 'ws',
        pathSegments: ['streaming'],
        queryParameters: {'i': token},
      );
      final webSocket = await WebSocket.connect(
        url.toString(),
      ).timeout(const Duration(seconds: 20));
      if (_closed) {
        await webSocket.close();
        return;
      }
      _webSocket = webSocket;
      _retryCount = 0;
      webSocket.pingInterval = const Duration(minutes: 1);
      webSocket.add(
        jsonEncode({
          'type': 'connect',
          'body': {'channel': 'main', 'id': 'main'},
        }),
      );
      debugPrint('[wenyan-push] 已连接 $account');
      _subscription = webSocket.listen(
        _onMessage,
        onError: (Object _) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  Future<void> close() async {
    _closed = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    await _webSocket?.close();
    _webSocket = null;
  }

  void _scheduleReconnect() {
    _webSocket = null;
    _subscription = null;
    if (_closed) return;
    _reconnectTimer?.cancel();
    final seconds = (1 << _retryCount.clamp(0, 6)).clamp(2, 120);
    _retryCount = (_retryCount + 1).clamp(0, 8);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      unawaited(connect());
    });
  }

  void _onMessage(dynamic message) {
    if (message is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(message);
    } catch (_) {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    if (decoded['type'] != 'channel') return;
    final body = decoded['body'];
    if (body is! Map<String, dynamic> || body['id'] != 'main') return;
    // unreadNotification 只是 notification 两秒后的重复事件，跳过；
    // readAllNotifications / meUpdated 等不产生系统通知。
    final payload = body['body'];
    if (payload is! Map<String, dynamic>) return;
    switch (body['type']) {
      case 'notification':
        debugPrint('[wenyan-push] 收到 notification');
        _dispatch(payload, isChatMessage: false);
      case 'newChatMessage':
        debugPrint('[wenyan-push] 收到 newChatMessage');
        _dispatch(payload, isChatMessage: true);
    }
  }

  void _dispatch(Map<String, dynamic> payload, {required bool isChatMessage}) {
    final PushNotification notification;
    try {
      notification = PushNotification.fromJson({
        'type': isChatMessage ? 'newChatMessage' : 'notification',
        'userId':
            payload['userId'] ?? payload['toUserId'] ?? payload['fromUserId'],
        'dateTime': DateTime.now().millisecondsSinceEpoch,
        'body': payload,
      });
    } catch (error) {
      debugPrint('[wenyan-push] 解析通知失败: $error');
      return;
    }
    final current = settings();
    if (!current.wenyanPushEnabled) return;
    final type = WenyanPushType.of(notification);
    if (type == null) return;
    if (current.wenyanPushDisabledTypes.contains(type.key)) {
      debugPrint('[wenyan-push] 类型 ${type.key} 已被用户关闭');
      return;
    }
    debugPrint('[wenyan-push] 展示通知 ${type.key}');
    unawaited(onNotification(account, notification));
  }
}
