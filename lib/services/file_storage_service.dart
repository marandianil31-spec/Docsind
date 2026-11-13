import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStorageService {
  static const String _historyKey = 'documaster_saved_files';

  /// Saves a file to the phone's shared Downloads folder.
  ///
  /// Example:
  /// Downloads/DocuMaster/PDF/
  /// Downloads/DocuMaster/Images/
  static Future<Map<String, dynamic>> saveFile({
    required File file,
    required String fileName,
    required String category,
    required String mimeType,
  }) async {
    if (!await file.exists()) {
      throw Exception('Source file does not exist.');
    }

    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    if (extension.isEmpty) {
      throw Exception('File extension is missing.');
    }

    final result = await FileSaver.instance.saveToDownloads(
      name: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
      filePath: file.path,
      fileExtension: extension,
      mimeType: MimeType.custom,
      customMimeType: mimeType,
      subfolder: 'DocuMaster/$category',
    );

    if (result == null) {
      throw Exception('File could not be saved to phone storage.');
    }

    final record = <String, dynamic>{
      'name': fileName,
      'category': category,
      'uri': result.toString(),
      'sourcePath': file.path,
      'size': await file.length(),
      'savedAt': DateTime.now().toIso8601String(),
      'mimeType': mimeType,
    };

    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.insert(0, record.toString());

    // Keep the latest 300 records.
    await prefs.setStringList(
      _historyKey,
      history.take(300).toList(),
    );

    return record;
  }

  /// Returns saved-file history.
  static Future<List<Map<String, dynamic>>> getSavedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    final files = <Map<String, dynamic>>[];

    for (final item in history) {
      try {
        // Records are stored as JSON strings in the next version.
        // Skip records that cannot be decoded.
        files.add(
          Map<String, dynamic>.from(
            Uri.splitQueryString(item),
          ),
        );
      } catch (_) {
        continue;
      }
    }

    return files;
  }

  /// Removes a record from app history.
  /// Does not delete the actual phone-storage file.
  static Future<void> removeFromHistory(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere((item) => item.contains(uri));

    await prefs.setStringList(_historyKey, history);
  }
}

