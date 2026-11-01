// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wenyan_push_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(WenyanPushService)
final wenyanPushServiceProvider = WenyanPushServiceProvider._();

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
final class WenyanPushServiceProvider
    extends $NotifierProvider<WenyanPushService, void> {
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
  WenyanPushServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wenyanPushServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wenyanPushServiceHash();

  @$internal
  @override
  WenyanPushService create() => WenyanPushService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wenyanPushServiceHash() => r'3bb8a42500fff58caaeda777b9e14e9743c05bb9';

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

abstract class _$WenyanPushService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
