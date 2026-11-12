
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  List<PlatformFile> selectedFiles = [];
  bool isMerging = false;
  String? savedPdfPath;

  Future<void> pickPdfFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result == null) return;

      final validFiles = result.files
          .where((file) => file.path != null)
          .toList();

      setState(() {
        selectedFiles.addAll(validFiles);
        savedPdfPath = null;
      });

      if (validFiles.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF files could not be accessed.'),
          ),
        );
      }
    } catch (e) {
      showMessage('File selection failed: $e');
    }
  }

  void removePdf(int index) {
    setState(() {
      selectedFiles.removeAt(index);
      savedPdfPath = null;
    });
  }

  Future<void> mergePdfFiles() async {
    if (selectedFiles.length < 2) {
      showMessage('Please select at least 2 PDF files.');
      return;
    }

    setState(() {
      isMerging = true;
      savedPdfPath = null;
    });

    PdfDocument? outputDocument;

    try {
      outputDocument = PdfDocument();

      for (final file in selectedFiles) {
        final inputFile = File(file.path!);
        final bytes = await inputFile.readAsBytes();

        final inputDocument = PdfDocument(inputBytes: bytes);

        try {
          if (inputDocument.pages.count > 0) {
            outputDocument.importPageRange(
              inputDocument,
              0,
              inputDocument.pages.count - 1,
            );
          }
        } finally {
          inputDocument.dispose();
        }
      }

      if (outputDocument.pages.count == 0) {
        throw Exception('No PDF pages found.');
      }

      final outputBytes = await outputDocument.save();

      final directory = await getApplicationDocumentsDirectory();
      final mergeFolder = Directory(
        '${directory.path}/DocuMaster',
      );

      if (!await mergeFolder.exists()) {
        await mergeFolder.create(recursive: true);
      }

      final fileName =
          'Merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final outputFile = File(
        '${mergeFolder.path}/$fileName',
      );

      await outputFile.writeAsBytes(outputBytes, flush: true);

      if (!mounted) return;

      setState(() {
        savedPdfPath = outputFile.path;
      });

      showMessage('PDF files merged successfully!');
    } catch (e) {
      showMessage('Merge failed: $e');
    } finally {
      outputDocument?.dispose();

      if (mounted) {
        setState(() {
          isMerging = false;
        });
      }
    }
  }

  Future<void> shareMergedPdf() async {
    if (savedPdfPath == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(savedPdfPath!)],
          text: 'Merged PDF - DocuMaster',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          'PDF Merge',
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 55,
                            color: Color(0xFF1769E0),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Combine PDF Files',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Select multiple PDFs and combine them '
                            'into one document.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected PDF Files',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${selectedFiles.length} files',
                          style: const TextStyle(
                            color: Color(0xFF1769E0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (selectedFiles.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
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
                              Icons.folder_open,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No PDF files selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedFiles.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }

                            final file =
                                selectedFiles.removeAt(oldIndex);

                            selectedFiles.insert(newIndex, file);
                            savedPdfPath = null;
                          });
                        },
                        itemBuilder: (context, index) {
                          final file = selectedFiles[index];

                          return Container(
                            key: ValueKey(
                              '${file.path}-$index',
                            ),
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
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => removePdf(index),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                                const Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isMerging ? null : pickPdfFiles,
                        icon: const Icon(Icons.add),
                        label: const Text('Add PDF Files'),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Tip: Drag files to change their order.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
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
                      onPressed:
                          isMerging ? null : mergePdfFiles,
                      icon: isMerging
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.merge_type),
                      label: Text(
                        isMerging ? 'Merging...' : 'Merge PDF Files',
                      ),
                    ),
                  ),

                  if (savedPdfPath != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: shareMergedPdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Merged PDF'),
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
