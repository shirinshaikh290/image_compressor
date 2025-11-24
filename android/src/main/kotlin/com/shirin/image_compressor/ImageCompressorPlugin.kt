package com.shirin.image_compressor

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.ByteArrayOutputStream

/** ImageCompressorPlugin */
class ImageCompressorPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "image_compressor")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            // Get platform version
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "compressImage" -> {
                val path = call.argument<String>("path")!!
                var quality = call.argument<Int>("quality")!!
                val maxSizeMB = call.argument<Int>("maxSizeMB") // optional

                val options = BitmapFactory.Options()
                options.inPreferredConfig = Bitmap.Config.ARGB_8888

                val bitmap = BitmapFactory.decodeFile(path, options)
                val outputStream = ByteArrayOutputStream()

                // First compression
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
                var compressedBytes = outputStream.toByteArray()

                // If maxSizeMB given → loop until size <= target
                if (maxSizeMB != null) {
                    val targetBytes = maxSizeMB * 1024 * 1024

                    while (compressedBytes.size > targetBytes && quality > 5) {
                        quality -= 5
                        outputStream.reset()
                        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
                        compressedBytes = outputStream.toByteArray()
                    }
                }

                result.success(compressedBytes)
            }


            /* "compressImage" -> {
                 val path = call.argument<String>("path")!!
                 val quality = call.argument<Int>("quality")!!

                 val options = BitmapFactory.Options()
                 options.inPreferredConfig = Bitmap.Config.ARGB_8888

                 val bitmap = BitmapFactory.decodeFile(path, options)
                 val outputStream = ByteArrayOutputStream()

                 bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)

                 result.success(outputStream.toByteArray())
             }*/

            else -> result.notImplemented()
        }
    }

/*    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }*/

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
