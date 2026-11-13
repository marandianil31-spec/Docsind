import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStorageService {
  static const String _historyKey = 'documaster_saved_files';

  static Future<Map<String, dynamic>> saveFile({
    required File file,
    required String fileName,
    required String category,
    required String mimeType,
  }) async {
    if (!await file.exists()) {
      throw Exception('File nahi mili.');
    }

    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    if (extension.isEmpty) {
      throw Exception('File extension missing hai.');
    }

    final cleanName =
        fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

    String? savedUri;

    if (mimeType.startsWith('image/')) {
      savedUri = await FileSaver.instance.saveToGallery(
        name: cleanName,
        filePath: file.path,
        fileExtension: extension,
        mimeType: MimeType.custom,
        customMimeType: mimeType,
        album: 'DocuMaster/$category',
      );
    } else {
      savedUri = await FileSaver.instance.saveToDownloads(
        name: cleanName,
        filePath: file.path,
        fileExtension: extension,
        mimeType: MimeType.custom,
        customMimeType: mimeType,
        subfolder: 'DocuMaster/$category',
      );
    }

    if (savedUri == null) {
      throw Exception('Phone storage mein save nahi ho payi.');
    }

    final record = <String, dynamic>{
      'name': fileName,
      'category': category,
      'uri': savedUri,
      'size': await file.length(),
      'savedAt': DateTime.now().toIso8601String(),
      'mimeType': mimeType,
    };

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.insert(0, jsonEncode(record));

    await prefs.setStringList(
      _historyKey,
      history.take(300).toList(),
    );

    return record;
  }

  static Future<List<Map<String, dynamic>>> getSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    final files = <Map<String, dynamic>>[];

    for (final item in history) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map) {
          files.add(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        continue;
      }
    }

    return files;
  }

  static Future<void> removeFromHistory(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere((item) {
      try {
        final data = jsonDecode(item);
        return data['uri'] == uri;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(_historyKey, history);
  }
}

