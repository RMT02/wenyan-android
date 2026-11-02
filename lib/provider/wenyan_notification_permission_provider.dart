import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';
import 'wenyan_local_notifications_provider.dart';

part 'wenyan_notification_permission_provider.g.dart';

/// 系统通知权限状态。
///
/// 闻言的推送默认开启，但「能不能真的弹出通知」取决于系统级开关：Android 13
/// 以上需要运行时授权 `POST_NOTIFICATIONS`，而且用户随时可能在系统设置里把
/// 通知关掉。所以这里把权限状态单独做成一个可刷新的 provider，供设置首页、
/// 通知设置页与首次运行时的申请流程共用。
@Riverpod(keepAlive: true)
class WenyanNotificationPermission extends _$WenyanNotificationPermission {
  /// 是否已经向用户申请过一次通知权限。
  static const askedKey = 'wenyanNotificationPermissionAsked';

  bool get _supported => defaultTargetPlatform == TargetPlatform.android;

  AndroidFlutterLocalNotificationsPlugin? get _android => ref
      .read(wenyanLocalNotificationsPluginProvider)
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> build() => _areEnabled();

  Future<bool> _areEnabled() async {
    if (!_supported) return true;
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (error) {
      debugPrint('[wenyan-push] 读取通知权限失败: $error');
      return false;
    }
  }

  /// 首次运行时申请通知权限；已经申请过则只刷新当前状态。
  Future<bool> requestIfFirstRun() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(askedKey) ?? false) return refresh();
    return prefs.setBool(askedKey, true).then((_) => request());
  }

  /// 向系统申请通知权限，返回最终是否可用。
  ///
  /// 用户拒绝、系统拒绝或调用失败都返回 `false`，调用方据此提示「通知权限
  /// 未获取，通知不可用」。
  Future<bool> request() async {
    if (!_supported) {
      state = const AsyncValue.data(true);
      return true;
    }
    try {
      final result = await _android?.requestNotificationsPermission();
      final enabled = (result ?? false) && await _areEnabled();
      state = AsyncValue.data(enabled);
      return enabled;
    } catch (error, stackTrace) {
      debugPrint('[wenyan-push] 申请通知权限失败: $error\n$stackTrace');
      state = const AsyncValue.data(false);
      return false;
    }
  }

  /// 重新读取系统通知状态（从系统设置返回后调用）。
  Future<bool> refresh() async {
    final enabled = await _areEnabled();
    state = AsyncValue.data(enabled);
    return enabled;
  }
}
