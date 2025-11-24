import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ImageCompressor {
  static const MethodChannel _channel =
  MethodChannel('image_compressor');

  static Future<File> compressImage({
    required File file,
    int quality = 90,
    int? maxSize
  }) async {
    final Uint8List bytes = await _channel.invokeMethod(
      'compressImage',
      {
        'path': file.path,
        'quality': quality,
        'maxSizeMB':maxSize
      },
    );

    final File output = File("${file.path}_compressed.jpg");
    await output.writeAsBytes(bytes);
    return output;
  }

  Future getPlatformVersion() async {}
}
