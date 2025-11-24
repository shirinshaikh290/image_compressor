# Image Compressor

📦 Image Compressor

A lightweight and fast Flutter plugin to compress images on Android using native Kotlin code.
This package helps reduce image file size before uploading to servers, saving bandwidth and improving performance.

✨ Features

✔️ Compress images using native Android (Kotlin) code
✔️ Control compression quality (1–100)
✔️ Fast and memory efficient
✔️ Works with image picked from gallery
✔️ Simple API — one method call
✔️ Returns compressed image bytes

📸 Example Usage

Flutter Code

import 'package:image_compressor/image_compressor.dart';
import 'package:image_picker/image_picker.dart';
            void compressImageExample() async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                source: ImageSource.gallery);
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
            }

📝 Example App

A full working example is included in the example/ folder.
