
import 'package:flutter/services.dart';

class FileUriService {
  static const MethodChannel _channel =
      MethodChannel('com.docsind/file_actions');

  static Future<bool> openFile({
    required String uri,
    required String mimeType,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'openFile',
        {
          'uri': uri,
          'mimeType': mimeType,
        },
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'File open nahi hui.');
    }
  }

  static Future<bool> shareFile({
    required String uri,
    required String mimeType,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'shareFile',
        {
          'uri': uri,
          'mimeType': mimeType,
        },
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'File share nahi hui.');
    }
  }
}
