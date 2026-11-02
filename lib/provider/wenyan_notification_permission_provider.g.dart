// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wenyan_notification_permission_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 系统通知权限状态。
///
/// 闻言的推送默认开启，但「能不能真的弹出通知」取决于系统级开关：Android 13
/// 以上需要运行时授权 `POST_NOTIFICATIONS`，而且用户随时可能在系统设置里把
/// 通知关掉。所以这里把权限状态单独做成一个可刷新的 provider，供设置首页、
/// 通知设置页与首次运行时的申请流程共用。

@ProviderFor(WenyanNotificationPermission)
final wenyanNotificationPermissionProvider =
    WenyanNotificationPermissionProvider._();

/// 系统通知权限状态。
///
/// 闻言的推送默认开启，但「能不能真的弹出通知」取决于系统级开关：Android 13
/// 以上需要运行时授权 `POST_NOTIFICATIONS`，而且用户随时可能在系统设置里把
/// 通知关掉。所以这里把权限状态单独做成一个可刷新的 provider，供设置首页、
/// 通知设置页与首次运行时的申请流程共用。
final class WenyanNotificationPermissionProvider
    extends $AsyncNotifierProvider<WenyanNotificationPermission, bool> {
  /// 系统通知权限状态。
  ///
  /// 闻言的推送默认开启，但「能不能真的弹出通知」取决于系统级开关：Android 13
  /// 以上需要运行时授权 `POST_NOTIFICATIONS`，而且用户随时可能在系统设置里把
  /// 通知关掉。所以这里把权限状态单独做成一个可刷新的 provider，供设置首页、
  /// 通知设置页与首次运行时的申请流程共用。
  WenyanNotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wenyanNotificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wenyanNotificationPermissionHash();

  @$internal
  @override
  WenyanNotificationPermission create() => WenyanNotificationPermission();
}

String _$wenyanNotificationPermissionHash() =>
    r'753650fbf97d246f973b892be648d1bed78ed42d';

/// 系统通知权限状态。
///
/// 闻言的推送默认开启，但「能不能真的弹出通知」取决于系统级开关：Android 13
/// 以上需要运行时授权 `POST_NOTIFICATIONS`，而且用户随时可能在系统设置里把
/// 通知关掉。所以这里把权限状态单独做成一个可刷新的 provider，供设置首页、
/// 通知设置页与首次运行时的申请流程共用。

abstract class _$WenyanNotificationPermission extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
