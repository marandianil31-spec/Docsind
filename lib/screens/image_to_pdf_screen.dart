
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];

  String pageSize = 'A4';
  bool isCreating = false;
  String? savedPath;

  static const Color blue = Color(0xFF1769E8);

  Future<void> pickImages() async {
    try {
      final selected = await picker.pickMultiImage(
        imageQuality: 95,
      );

      if (!mounted || selected.isEmpty) return;

      setState(() {
        images.addAll(selected);
        savedPath = null;
      });
    } catch (e) {
      showMessage('Photo select error: $e');
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
      savedPath = null;
    });
  }

  void reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final image = images.removeAt(oldIndex);
      images.insert(newIndex, image);
      savedPath = null;
    });
  }

  Future<void> createPdf() async {
    if (images.isEmpty) {
      showMessage('Please select photos first.');
      return;
    }

    setState(() {
      isCreating = true;
      savedPath = null;
    });

    try {
      final document = pw.Document();

      final format = pageSize == 'A4'
          ? PdfPageFormat.a4
          : PdfPageFormat.letter;

      for (final image in images) {
        final bytes = await image.readAsBytes();
        final memoryImage = pw.MemoryImage(bytes);

        document.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(20),
            build: (context) {
              return pw.Center(
                child: pw.Image(
                  memoryImage,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      final directory = await getApplicationDocumentsDirectory();

      final pdfDirectory = Directory(
        '${directory.path}/DocuMaster',
      );

      if (!await pdfDirectory.exists()) {
        await pdfDirectory.create(recursive: true);
      }

      final fileName =
          'DocuMaster_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File('${pdfDirectory.path}/$fileName');

      await file.writeAsBytes(
        await document.save(),
        flush: true,
      );

      if (!mounted) return;

      setState(() {
        savedPath = file.path;
        isCreating = false;
      });

      showMessage('PDF created successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCreating = false;
      });

      showMessage('PDF creation failed: $e');
    }
  }

  Future<void> sharePdf() async {
    if (savedPath == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(savedPath!)],
          title: 'DocuMaster PDF',
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

  Widget buildPhotoList() {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 55,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No photos selected',
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 5),
            Text(
              'Select photos to start creating PDF.',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: images.length,
      onReorder: reorderImages,
      itemBuilder: (context, index) {
        final image = images[index];

        return Card(
          key: ValueKey(
            '${image.path}_$index',
          ),
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.file(
                File(image.path),
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              'Photo ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Hold and drag to reorder',
              style: TextStyle(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => removeImage(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      appBar: AppBar(
        title: const Text(
          'Image to PDF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1769E8),
                        Color(0xFF5599F5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 45,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Convert Photos to PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Select multiple images and combine them into one PDF.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isCreating ? null : pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select Photos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: blue,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      side: const BorderSide(color: blue),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selected Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${images.length} Photos',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                buildPhotoList(),

                const SizedBox(height: 22),

                const Text(
                  'PDF Page Size',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: pageSize,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'A4',
                      child: Text('A4'),
                    ),
                    DropdownMenuItem(
                      value: 'Letter',
                      child: Text('Letter'),
                    ),
                  ],
                  onChanged: isCreating
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              pageSize = value;
                            });
                          }
                        },
                ),

                const SizedBox(height: 18),

                if (savedPath != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your PDF is saved in DocuMaster app storage.',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCreating ? null : createPdf,
                      icon: isCreating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(
                        isCreating ? 'Creating PDF...' : 'Create PDF',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: savedPath == null ? null : sharePdf,
                    icon: const Icon(Icons.share),
                    style: IconButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
