import 'package:flutter_test/flutter_test.dart';
import 'package:image_compressor/image_compressor.dart';
import 'package:image_compressor/image_compressor_platform_interface.dart';
import 'package:image_compressor/image_compressor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImageCompressorPlatform
    with MockPlatformInterfaceMixin
    implements ImageCompressorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ImageCompressorPlatform initialPlatform = ImageCompressorPlatform.instance;

  test('$MethodChannelImageCompressor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImageCompressor>());
  });

  test('getPlatformVersion', () async {
    ImageCompressor imageCompressorPlugin = ImageCompressor();
    MockImageCompressorPlatform fakePlatform = MockImageCompressorPlatform();
    ImageCompressorPlatform.instance = fakePlatform;

    expect(await imageCompressorPlugin.getPlatformVersion(), '42');
  });
}
