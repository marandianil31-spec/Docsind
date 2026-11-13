
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() =>
      _DocumentScannerScreenState();
}

class _DocumentScannerScreenState
    extends State<DocumentScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<File> _pages = [];

  bool _isProcessing = false;
  String _status = '';

  Future<void> _addPage(ImageSource source) async {
    if (_isProcessing) return;

    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (pickedImage == null) return;

      setState(() {
        _isProcessing = true;
        _status = 'Opening crop editor...';
      });

      final CroppedFile? croppedImage =
          await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            toolbarColor: const Color(0xFF2457C5),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF2457C5),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedImage != null && mounted) {
        setState(() {
          _pages.add(File(croppedImage.path));
          _status = '${_pages.length} page(s) added';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _removePage(int index) {
    setState(() {
      _pages.removeAt(index);
      _status = '${_pages.length} page(s) remaining';
    });
  }

  Future<void> _createPdf() async {
    if (_pages.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _status = 'Creating PDF...';
    });

    try {
      final pdf = pw.Document();

      for (final file in _pages) {
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      final appDirectory =
          await getApplicationDocumentsDirectory();

      final saveDirectory = Directory(
        '${appDirectory.path}/DocuMaster/Scanned_Documents',
      );

      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      final fileName =
          'Scanned_Document_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final pdfFile = File(
        '${saveDirectory.path}/$fileName',
      );

      await pdfFile.writeAsBytes(await pdf.save());

      if (!mounted) return;

      setState(() {
        _status = 'PDF created successfully!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document PDF saved successfully!'),
        ),
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path)],
          text: 'Scanned Document - DocuMaster',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Document Scanner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Color(0xFF2457C5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.document_scanner_rounded,
                  size: 65,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Scan Your Documents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Capture, crop and convert documents into PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.camera_alt,
                        title: 'Camera',
                        onTap: () =>
                            _addPage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.photo_library,
                        title: 'Gallery',
                        onTap: () =>
                            _addPage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanned Pages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                Text(
                  '${_pages.length} Pages',
                  style: const TextStyle(
                    color: Color(0xFF2457C5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _pages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 75,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No documents scanned yet',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Use Camera or Gallery to add pages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        elevation: 1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8),
                            child: Image.file(
                              _pages[index],
                              width: 55,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            'Document Page ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                              const Text('Scanned page'),
                          trailing: IconButton(
                            onPressed: () =>
                                _removePage(index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _status,
                style: const TextStyle(
                  color: Color(0xFF2457C5),
                  fontSize: 12,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18, 8, 18, 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _pages.isEmpty || _isProcessing
                    ? null
                    : _createPdf,
                icon: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _isProcessing
                      ? 'Please wait...'
                      : 'Create PDF',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2457C5),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2457C5),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
