package com.documaster.documaster

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.docsind/file_actions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "openFile" -> {
                    val uriString = call.argument<String>("uri")
                    val mimeType = call.argument<String>("mimeType") ?: "*/*"

                    if (uriString.isNullOrBlank()) {
                        result.error("INVALID_URI", "File URI missing", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, mimeType)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        startActivity(intent)
                        result.success(true)

                    } catch (e: ActivityNotFoundException) {
                        result.error("NO_APP", "File open karne wala app nahi mila.", null)
                    } catch (e: Exception) {
                        result.error("OPEN_ERROR", e.message, null)
                    }
                }

                "shareFile" -> {
                    val uriString = call.argument<String>("uri")
                    val mimeType = call.argument<String>("mimeType") ?: "*/*"

                    if (uriString.isNullOrBlank()) {
                        result.error("INVALID_URI", "File URI missing", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = mimeType
                            putExtra(Intent.EXTRA_STREAM, uri)
                            clipData = ClipData.newUri(
                                contentResolver,
                                "DocsIND File",
                                uri
                            )
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        startActivity(
                            Intent.createChooser(intent, "Share DocsIND File")
                        )
                        result.success(true)

                    } catch (e: Exception) {
                        result.error("SHARE_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}

