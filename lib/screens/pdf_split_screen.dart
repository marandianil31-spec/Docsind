
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfSplitScreen extends StatefulWidget {
  const PdfSplitScreen({super.key});

  @override
  State<PdfSplitScreen> createState() => _PdfSplitScreenState();
}

class _PdfSplitScreenState extends State<PdfSplitScreen> {
  PlatformFile? selectedFile;
  bool isSplitting = false;
  List<String> splitFiles = [];

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.path == null) {
        showMessage('Could not access this PDF file.');
        return;
      }

      setState(() {
        selectedFile = file;
        splitFiles = [];
      });
    } catch (e) {
      showMessage('File selection failed: $e');
    }
  }

  Future<void> splitPdf() async {
    if (selectedFile == null || selectedFile!.path == null) {
      showMessage('Please select a PDF file first.');
      return;
    }

    setState(() {
      isSplitting = true;
      splitFiles = [];
    });

    PdfDocument? inputDocument;

    try {
      final inputFile = File(selectedFile!.path!);

      if (!await inputFile.exists()) {
        throw Exception('Selected PDF file not found.');
      }

      final bytes = await inputFile.readAsBytes();

      inputDocument = PdfDocument(inputBytes: bytes);

      final pageCount = inputDocument.pages.count;

      if (pageCount == 0) {
        throw Exception('This PDF has no pages.');
      }

      final directory =
          await getApplicationDocumentsDirectory();

      final outputFolder = Directory(
        '${directory.path}/DocuMaster/PDF_Split',
      );

      if (!await outputFolder.exists()) {
        await outputFolder.create(recursive: true);
      }

      final baseName = selectedFile!.name
          .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

      final generatedFiles = <String>[];

      for (int i = 0; i < pageCount; i++) {
        final sourcePage = inputDocument.pages[i];
        final template = sourcePage.createTemplate();

        final outputDocument = PdfDocument();

        try {
          outputDocument.pageSettings.size = sourcePage.size;

          final newPage = outputDocument.pages.add();

          newPage.graphics.drawPdfTemplate(
            template,
            Offset.zero,
            sourcePage.size,
          );

          final outputBytes = await outputDocument.save();

          final outputFile = File(
            '${outputFolder.path}/${baseName}_Page_${i + 1}.pdf',
          );

          await outputFile.writeAsBytes(
            outputBytes,
            flush: true,
          );

          generatedFiles.add(outputFile.path);
        } finally {
          outputDocument.dispose();
        }

        if (!mounted) return;

        setState(() {
          splitFiles = List<String>.from(generatedFiles);
        });
      }

      showMessage('$pageCount PDF pages created successfully!');
    } catch (e) {
      showMessage('PDF Split failed: $e');
    } finally {
      inputDocument?.dispose();

      if (mounted) {
        setState(() {
          isSplitting = false;
        });
      }
    }
  }

  Future<void> shareSplitFiles() async {
    if (splitFiles.isEmpty) return;

    try {
      final files = splitFiles.map((path) => XFile(path)).toList();

      await SharePlus.instance.share(
        ShareParams(
          files: files,
          text: 'Split PDF pages - DocuMaster',
        ),
      );
    } catch (e) {
      showMessage('Sharing failed: $e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getFileSize(String path) {
    final file = File(path);
    if (!file.existsSync()) return '';

    final size = file.lengthSync();
    return '${(size / 1024).toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          'PDF Split',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.call_split,
                            size: 55,
                            color: Color(0xFF1769E0),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Split PDF Pages',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Separate every page of your PDF '
                            'into individual PDF files.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Select PDF File',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (selectedFile == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFDCE5F2),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No PDF selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFE7ECF5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              color: Color(0xFFE53935),
                              size: 35,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedFile!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isSplitting
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedFile = null;
                                        splitFiles = [];
                                      });
                                    },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isSplitting ? null : pickPdf,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Choose PDF File'),
                      ),
                    ),

                    const SizedBox(height: 25),

                    if (splitFiles.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Split PDF Files',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${splitFiles.length} pages',
                            style: const TextStyle(
                              color: Color(0xFF1769E0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...List.generate(splitFiles.length, (index) {
                        final path = splitFiles[index];
                        final name = path.split('/').last;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE7ECF5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xFFE53935),
                                size: 30,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      getFileSize(path),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isSplitting ? null : splitPdf,
                      icon: isSplitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.call_split),
                      label: Text(
                        isSplitting ? 'Splitting...' : 'Split PDF',
                      ),
                    ),
                  ),

                  if (splitFiles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: shareSplitFiles,
                        icon: const Icon(Icons.share),
                        label: const Text('Share All PDF Files'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
