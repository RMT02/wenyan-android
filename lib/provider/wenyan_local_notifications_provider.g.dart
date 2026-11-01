// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wenyan_local_notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全局唯一的本地通知插件实例。
///
/// UnifiedPush 通路与闻言自建推送通道共用同一个实例：初始化只做一次
/// （`main.dart` 里），两边都用它发通知，避免出现两套通知渠道配置。

@ProviderFor(wenyanLocalNotificationsPlugin)
final wenyanLocalNotificationsPluginProvider =
    WenyanLocalNotificationsPluginProvider._();

/// 全局唯一的本地通知插件实例。
///
/// UnifiedPush 通路与闻言自建推送通道共用同一个实例：初始化只做一次
/// （`main.dart` 里），两边都用它发通知，避免出现两套通知渠道配置。

final class WenyanLocalNotificationsPluginProvider
    extends
        $FunctionalProvider<
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin,
          FlutterLocalNotificationsPlugin
        >
    with $Provider<FlutterLocalNotificationsPlugin> {
  /// 全局唯一的本地通知插件实例。
  ///
  /// UnifiedPush 通路与闻言自建推送通道共用同一个实例：初始化只做一次
  /// （`main.dart` 里），两边都用它发通知，避免出现两套通知渠道配置。
  WenyanLocalNotificationsPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wenyanLocalNotificationsPluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wenyanLocalNotificationsPluginHash();

  @$internal
  @override
  $ProviderElement<FlutterLocalNotificationsPlugin> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterLocalNotificationsPlugin create(Ref ref) {
    return wenyanLocalNotificationsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterLocalNotificationsPlugin value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterLocalNotificationsPlugin>(
        value,
      ),
    );
  }
}

String _$wenyanLocalNotificationsPluginHash() =>
    r'4e0651fc84b6ea91486bec735677fa56c4d0edda';
