
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfCompressScreen extends StatefulWidget {
  const PdfCompressScreen({super.key});

  @override
  State<PdfCompressScreen> createState() => _PdfCompressScreenState();
}

class _PdfCompressScreenState extends State<PdfCompressScreen> {
  PlatformFile? selectedFile;
  String compression = 'Medium';
  bool isCompressing = false;

  String? outputPath;
  int? originalSize;
  int? compressedSize;

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        selectedFile = result.files.first;
        outputPath = null;
        originalSize = null;
        compressedSize = null;
      });
    } catch (e) {
      showMessage('PDF select nahi ho paya: $e');
    }
  }

  String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  PdfCompressionLevel getCompressionLevel() {
    switch (compression) {
      case 'Low':
        return PdfCompressionLevel.bestSpeed;
      case 'High':
        return PdfCompressionLevel.best;
      default:
        return PdfCompressionLevel.normal;
    }
  }

  Future<void> compressPdf() async {
    if (selectedFile == null) {
      showMessage('Pehle PDF select kijiye.');
      return;
    }

    setState(() {
      isCompressing = true;
      outputPath = null;
    });

    PdfDocument? document;

    try {
      final bytes = selectedFile!.bytes ??
          (selectedFile!.path != null
              ? await File(selectedFile!.path!).readAsBytes()
              : null);

      if (bytes == null || bytes.isEmpty) {
        throw Exception('PDF file read nahi ho payi.');
      }

      final inputSize = bytes.length;

      document = PdfDocument(inputBytes: bytes);

      document.fileStructure.incrementalUpdate = false;
      document.compressionLevel = getCompressionLevel();

      final compressedBytes = await document.save();
      document.dispose();
      document = null;

      final directory = await getApplicationDocumentsDirectory();
      final saveDirectory =
          Directory('${directory.path}/DocuMaster/PDF_Compress');

      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      final originalName = selectedFile!.name.replaceAll(
        RegExp(r'\.pdf$', caseSensitive: false),
        '',
      );

      final fileName =
          '${originalName}_compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File('${saveDirectory.path}/$fileName');

      await file.writeAsBytes(compressedBytes, flush: true);

      if (!mounted) return;

      setState(() {
        originalSize = inputSize;
        compressedSize = compressedBytes.length;
        outputPath = file.path;
      });

      showMessage('PDF compression complete!');
    } catch (e) {
      document?.dispose();

      if (mounted) {
        showMessage('Compression failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isCompressing = false;
        });
      }
    }
  }

  Future<void> sharePdf() async {
    if (outputPath == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(outputPath!)],
          text: 'Compressed PDF - DocuMaster',
        ),
      );
    } catch (e) {
      showMessage('Share nahi ho paya: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          'PDF Compress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1746A2),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.compress,
                    size: 58,
                    color: Color(0xFF2457C5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Reduce PDF Size',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B83),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Choose a PDF and select your compression level.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Select PDF File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            InkWell(
              onTap: isCompressing ? null : pickPdf,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB8CCF5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile?.name ?? 'Choose PDF from phone',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.folder_open,
                      color: Color(0xFF2457C5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Compression Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...[
              {
                'name': 'Low',
                'subtitle': 'Faster processing, lighter compression',
                'icon': Icons.speed,
              },
              {
                'name': 'Medium',
                'subtitle': 'Balanced speed and compression',
                'icon': Icons.balance,
              },
              {
                'name': 'High',
                'subtitle': 'Best available stream compression',
                'icon': Icons.compress,
              },
            ].map((item) {
              final name = item['name'] as String;
              final isSelected = compression == name;

              return GestureDetector(
                onTap: isCompressing
                    ? null
                    : () {
                        setState(() {
                          compression = name;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F0FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2457C5)
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF2457C5),
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: const Color(0xFF2457C5),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isCompressing ? null : compressPdf,
                icon: isCompressing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.compress),
                label: Text(
                  isCompressing ? 'Compressing...' : 'Compress PDF',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2457C5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            if (outputPath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Compression Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sizeRow('Original Size', originalSize!),
                    const SizedBox(height: 8),
                    _sizeRow('New Size', compressedSize!),
                    const SizedBox(height: 12),
                    if (compressedSize! < originalSize!)
                      Text(
                        'Reduced by ${((originalSize! - compressedSize!) / originalSize! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        'Is PDF ka size kam nahi hua. Original content preserve karne ke liye output size same ya bada ho sakta hai.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Compressed PDF'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sizeRow(String label, int size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          formatSize(size),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
