import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_compressor/image_compressor.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _imageCompressorPlugin = ImageCompressor();
  File? pickedFile;
  File? compressed;

  XFile? pickedImage;
  String? savedPath;

  double quality = 90;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _imageCompressorPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  Future<String?> saveFileToDownloads({
    required Uint8List bytes,
    required String fileName,
    required String path
  }) async {
    // Ask Permission
    if (!await requestPermission()) {
      return "Permission Denied";
    }

    if (Platform.isAndroid) {
      // For Android 11+ use MediaStore via ImageGallerySaver
      final result = await GallerySaver.saveImage(
        path,
       // isReturnPathOfIOS: true,
      );

      // Fallback: For Android < 10
      Directory? downloadsDir = Directory("/storage/emulated/0/Download");

      if (!downloadsDir.existsSync()) {
        downloadsDir = await getExternalStorageDirectory();
      }

      final filePath = "${downloadsDir!.path}/$fileName";
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      return filePath;
    }
  }

  Future<bool> requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];

    var i = (Math.log(bytes) / Math.log(1024)).floor();
    return ((bytes / Math.pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Image Compressor")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Quality Slider
              Text(
                "Quality: ${quality.toInt()}%",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: quality,
                min: 1,
                max: 100,
                divisions: 99,
                label: quality.toInt().toString(),
                activeColor: Colors.blue,
                onChanged: (v) {
                  setState(() {
                    quality = v;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Image Preview
              if (compressed != null)
                Column(
                  children: [
                    const Text("Compressed Image Preview"),
                    const SizedBox(height: 10),
                    Image.file(compressed!, height: 200),
                    const SizedBox(height: 10),
                  ],
                ),

              // Buttons
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text("Pick & Compress"),
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                      source: ImageSource.gallery);

                  if (picked == null) return;

                  // Native compression using MethodChannel
                  if (picked != null) {
                    final result = await ImageCompressor.compressImage(
                        file: File(picked.path),
                        quality: quality.toInt(),
                    );

                    print("Original: ${File(picked.path).lengthSync()}");
                    print("Compressed: ${result.lengthSync()}");


                    File compressedFile = File(result.path);
                    setState(() {
                      pickedFile = File(picked.path);
                    });

                    print("Original: ${File(picked.path).lengthSync()}");
                    print("Compressed: ${compressedFile.lengthSync()}");

                    setState(() => compressed = compressedFile);

                    await requestPermission();

                    savedPath = await saveFileToDownloads(
                      bytes: await compressedFile.readAsBytes(),
                      fileName:
                      "compressed_${DateTime
                          .now()
                          .millisecondsSinceEpoch}.jpg",
                      path: compressedFile.path,
                    );

                    setState(() {
                      savedPath = savedPath;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Show saved location
              if (savedPath != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Saved at:\n$savedPath",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text("Original Size: ${formatBytes(File(pickedFile!.path.toString()).lengthSync(),2)}"),
                    Text("Compressed Size: ${formatBytes(File(savedPath.toString()).lengthSync(),2)}"),
                  ],
                ),
            ],
          ),
        ),
      ),
    );




/*    return MaterialApp(
      home:  Scaffold(
    appBar: AppBar(title: Text("Image Compressor")),
    body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    if (compressed != null)
    Image.file(compressed!, height: 200),

    ElevatedButton(
    child: Text("Pick & Compress"),
    onPressed: () async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
    final result = await ImageCompressor.compressImage(
    file: File(picked.path),
    quality: quality.toInt()
    //quality: 80,
    );

    print("Original: ${File(picked.path).lengthSync()}");
    print("Compressed: ${result.lengthSync()}");


    setState(() => compressed = result);

    await requestPermission();

    setState(() async {
      savedPath = await saveFileToDownloads(
          bytes: await compressed!.readAsBytes(),
      fileName: "compressed_image_${DateTime.now().millisecondsSinceEpoch}.jpg",
      path: compressed!.path.toString()
      );
    });

    print("Saved at: $savedPath");
    }
    },
    ),

      Slider(
        value: quality,
        min: 1,
        max: 100,
        label: quality.round().toString(),
        onChanged: (value) {
          setState(() {
            quality = value;
          });
        },
      ),

      const SizedBox(height: 20),
      // Show saved location
      if (savedPath != null)
        Text("Saved at:\n$savedPath"),
    ],
    ),
    ),
    ),
    );*/
  }
}
