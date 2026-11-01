// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wenyan_image_resolver_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wenyanImageResolver)
final wenyanImageResolverProvider = WenyanImageResolverProvider._();

final class WenyanImageResolverProvider
    extends
        $FunctionalProvider<
          WenyanImageResolverHolder,
          WenyanImageResolverHolder,
          WenyanImageResolverHolder
        >
    with $Provider<WenyanImageResolverHolder> {
  WenyanImageResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wenyanImageResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wenyanImageResolverHash();

  @$internal
  @override
  $ProviderElement<WenyanImageResolverHolder> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WenyanImageResolverHolder create(Ref ref) {
    return wenyanImageResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WenyanImageResolverHolder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WenyanImageResolverHolder>(value),
    );
  }
}

String _$wenyanImageResolverHash() =>
    r'128889348266500e6b4a5ae1bf54336e74af0279';
