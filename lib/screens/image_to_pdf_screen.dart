
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
  State<ImageToPdfScreen> createState() =>
      _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ImagePicker _picker = ImagePicker();

  List<XFile> images = [];
  String pageSize = 'A4';
  bool isCreating = false;
  String? pdfPath;

  static const Color primary = Color(0xFF2563EB);

  Future<void> pickImages() async {
    try {
      final selected = await _picker.pickMultiImage(
        imageQuality: 90,
      );

      if (selected.isNotEmpty && mounted) {
        setState(() {
          images.addAll(selected);
          pdfPath = null;
        });
      }
    } catch (e) {
      showMessage('Photo select nahi ho paya: $e');
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
      pdfPath = null;
    });
  }

  Future<void> createPdf() async {
    if (images.isEmpty) {
      showMessage('Pehle photos select kijiye.');
      return;
    }

    setState(() {
      isCreating = true;
      pdfPath = null;
    });

    try {
      final document = pw.Document();

      final format = pageSize == 'A4'
          ? PdfPageFormat.a4
          : PdfPageFormat.letter;

      for (final image in images) {
        final bytes = await File(image.path).readAsBytes();
        final pdfImage = pw.MemoryImage(bytes);

        document.addPage(
          pw.Page(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(15),
            build: (context) {
              return pw.Center(
                child: pw.Image(
                  pdfImage,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/DocuMaster');

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final fileName =
          'DocuMaster_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File('${folder.path}/$fileName');
      await file.writeAsBytes(await document.save());

      if (!mounted) return;

      setState(() {
        pdfPath = file.path;
        isCreating = false;
      });

      showMessage('PDF successfully created!');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isCreating = false;
      });
      showMessage('PDF create nahi hua: $e');
    }
  }

  Future<void> sharePdf() async {
    if (pdfPath == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfPath!)],
          text: 'Created with DocuMaster',
        ),
      );
    } catch (e) {
      showMessage('Share failed: $e');
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
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Image to PDF',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172554),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: primary,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Convert Images to PDF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select photos and create your PDF document.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isCreating ? null : pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Select Photos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selected Images',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${images.length} Photos',
                        style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (images.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 45,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          const Text('No photos selected'),
                          Text(
                            'Select photos to get started',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;

                          final item = images.removeAt(oldIndex);
                          images.insert(newIndex, item);
                          pdfPath = null;
                        });
                      },
                      itemBuilder: (context, index) {
                        final image = images[index];

                        return Container(
                          key: ValueKey(image.path),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.file(
                                  File(image.path),
                                  width: 58,
                                  height: 65,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Page ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Drag to reorder',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => removeImage(index),
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

                  const SizedBox(height: 22),

                  const Text(
                    'Page Size',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    initialValue: pageSize,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          pageSize = value;
                          pdfPath = null;
                        });
                      }
                    },
                  ),

                  if (pdfPath != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your PDF is ready!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isCreating ? null : createPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isCreating
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Create PDF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  if (pdfPath != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: sharePdf,
                        icon: const Icon(Icons.share),
                        label: const Text('Share PDF'),
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
