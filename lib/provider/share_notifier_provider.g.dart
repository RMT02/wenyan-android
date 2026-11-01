// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShareNotifier)
final shareNotifierProvider = ShareNotifierProvider._();

final class ShareNotifierProvider
    extends $NotifierProvider<ShareNotifier, bool> {
  ShareNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareNotifierHash();

  @$internal
  @override
  ShareNotifier create() => ShareNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shareNotifierHash() => r'38ab21afa5ab17473c84cf51be7b89cca9c79fc1';

abstract class _$ShareNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
