
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() =>
      _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  File? convertedImage;

  String selectedFormat = 'JPG';
  bool isConverting = false;

  int? originalSize;
  int? convertedSize;

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        convertedImage = null;
        originalSize = null;
        convertedSize = null;
      });
    } catch (e) {
      showMessage('Image select nahi ho payi: $e');
    }
  }

  CompressFormat getFormat() {
    switch (selectedFormat) {
      case 'PNG':
        return CompressFormat.png;
      case 'WEBP':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  String getExtension() {
    switch (selectedFormat) {
      case 'PNG':
        return 'png';
      case 'WEBP':
        return 'webp';
      default:
        return 'jpg';
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

  Future<void> convertImage() async {
    if (selectedImage == null) {
      showMessage('Pehle image select kijiye.');
      return;
    }

    setState(() {
      isConverting = true;
      convertedImage = null;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();

      final saveDirectory = Directory(
        '${directory.path}/DocuMaster/Image_Converter',
      );

      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      final extension = getExtension();

      final fileName =
          'converted_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final outputPath = '${saveDirectory.path}/$fileName';

      final result = await FlutterImageCompress.compressAndGetFile(
        selectedImage!.absolute.path,
        outputPath,
        quality: 95,
        minWidth: 10000,
        minHeight: 10000,
        format: getFormat(),
        keepExif: false,
      );

      if (result == null || !await File(result.path).exists()) {
        throw Exception('Converted image create nahi hui.');
      }

      final output = File(result.path);
      final oldSize = await selectedImage!.length();
      final newSize = await output.length();

      if (!mounted) return;

      setState(() {
        convertedImage = output;
        originalSize = oldSize;
        convertedSize = newSize;
      });

      showMessage('Image conversion complete!');
    } catch (e) {
      if (mounted) {
        showMessage('Conversion failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isConverting = false;
        });
      }
    }
  }

  Future<void> shareImage() async {
    if (convertedImage == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(convertedImage!.path)],
          text: 'Converted Image - DocuMaster',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text(
          'Image Converter',
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
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.transform,
                    size: 56,
                    color: Color(0xFF2457C5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Convert Image Format',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B83),
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Convert your photos into different image formats.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isConverting ? null : pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2457C5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Selected Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  selectedImage!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<int>(
                future: selectedImage!.length(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    'Original Size: ${formatSize(snapshot.data!)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            const Text(
              'Select Output Format',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _formatCard('JPG', 'JPEG Image'),
                const SizedBox(width: 10),
                _formatCard('PNG', 'PNG Image'),
                const SizedBox(width: 10),
                _formatCard('WEBP', 'WebP Image'),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isConverting ? null : convertImage,
                icon: isConverting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.transform),
                label: Text(
                  isConverting ? 'Converting...' : 'Convert Image',
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

            if (convertedImage != null) ...[
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
                          'Conversion Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        convertedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sizeRow('Original Size', originalSize!),
                    const SizedBox(height: 8),
                    _sizeRow('Converted Size', convertedSize!),
                    const SizedBox(height: 8),
                    Text(
                      'Output Format: $selectedFormat',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2457C5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: shareImage,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Converted Image'),
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

  Widget _formatCard(String format, String subtitle) {
    final selected = selectedFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: isConverting
            ? null
            : () {
                setState(() {
                  selectedFormat = format;
                  convertedImage = null;
                  originalSize = null;
                  convertedSize = null;
                });
              },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE8F0FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2457C5)
                  : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.image,
                size: 28,
                color: selected
                    ? const Color(0xFF2457C5)
                    : Colors.blueGrey,
              ),
              const SizedBox(height: 8),
              Text(
                format,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9),
              ),
              const SizedBox(height: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 18,
                color: const Color(0xFF2457C5),
              ),
            ],
          ),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
