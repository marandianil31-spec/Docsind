
package com.documaster.documaster

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.docsind/file_actions"

    private fun getMimeType(uri: Uri, suppliedType: String?): String {
        if (!suppliedType.isNullOrBlank() && suppliedType != "*/*") {
            return suppliedType
        }

        val contentType = contentResolver.getType(uri)
        if (!contentType.isNullOrBlank()) {
            return contentType
        }

        val extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString())
        return MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(extension.lowercase()) ?: "*/*"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            val uriString = call.argument<String>("uri")
            val suppliedType = call.argument<String>("mimeType")

            when (call.method) {

                "openFile" -> {
                    if (uriString.isNullOrBlank()) {
                        result.error("INVALID_URI", "File URI missing", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)
                        val mimeType = getMimeType(uri, suppliedType)

                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, mimeType)
                            addCategory(Intent.CATEGORY_DEFAULT)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            clipData = ClipData.newUri(
                                contentResolver,
                                "DocsIND File",
                                uri
                            )
                        }

                        startActivity(
                            Intent.createChooser(intent, "Open file with")
                        )

                        result.success(true)

                    } catch (e: ActivityNotFoundException) {
                        result.error(
                            "NO_APP",
                            "PDF ya Image open karne wala app nahi mila.",
                            null
                        )
                    } catch (e: Exception) {
                        result.error("OPEN_ERROR", e.message, null)
                    }
                }

                "shareFile" -> {
                    if (uriString.isNullOrBlank()) {
                        result.error("INVALID_URI", "File URI missing", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)
                        val mimeType = getMimeType(uri, suppliedType)

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
