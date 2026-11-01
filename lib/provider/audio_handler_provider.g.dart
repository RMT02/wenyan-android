// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_handler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioHandler)
final audioHandlerProvider = AudioHandlerProvider._();

final class AudioHandlerProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioHandler>,
          AudioHandler,
          FutureOr<AudioHandler>
        >
    with $FutureModifier<AudioHandler>, $FutureProvider<AudioHandler> {
  AudioHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioHandlerHash();

  @$internal
  @override
  $FutureProviderElement<AudioHandler> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AudioHandler> create(Ref ref) {
    return audioHandler(ref);
  }
}

String _$audioHandlerHash() => r'607ec1e25ade8e7c8afbd268afb9d35d06fc6b43';
