import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'image_compressor_platform_interface.dart';

/// An implementation of [ImageCompressorPlatform] that uses method channels.
class MethodChannelImageCompressor extends ImageCompressorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('image_compressor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
