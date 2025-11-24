import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'image_compressor_method_channel.dart';

abstract class ImageCompressorPlatform extends PlatformInterface {
  /// Constructs a ImageCompressorPlatform.
  ImageCompressorPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImageCompressorPlatform _instance = MethodChannelImageCompressor();

  /// The default instance of [ImageCompressorPlatform] to use.
  ///
  /// Defaults to [MethodChannelImageCompressor].
  static ImageCompressorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImageCompressorPlatform] when
  /// they register themselves.
  static set instance(ImageCompressorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
