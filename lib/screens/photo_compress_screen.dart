
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PhotoCompressScreen extends StatefulWidget {
  const PhotoCompressScreen({super.key});

  @override
  State<PhotoCompressScreen> createState() => _PhotoCompressScreenState();
}

class _PhotoCompressScreenState extends State<PhotoCompressScreen> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  File? compressedImage;

  int quality = 70;
  bool isCompressing = false;

  int? originalSize;
  int? compressedSize;

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
        compressedImage = null;
        originalSize = null;
        compressedSize = null;
      });
    } catch (e) {
      showMessage('Image select nahi ho payi: $e');
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

  Future<void> compressImage() async {
    if (selectedImage == null) {
      showMessage('Pehle photo select kijiye.');
      return;
    }

    setState(() {
      isCompressing = true;
      compressedImage = null;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();

      final saveDirectory = Directory(
        '${directory.path}/DocuMaster/Photo_Compress',
      );

      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      final fileName =
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final outputFile = '${saveDirectory.path}/$fileName';

      final result = await FlutterImageCompress.compressAndGetFile(
        selectedImage!.absolute.path,
        outputFile,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (result == null || !await File(result.path).exists()) {
        throw Exception('Compressed image create nahi hui.');
      }

      final output = File(result.path);

      final oldSize = await selectedImage!.length();
      final newSize = await output.length();

      if (!mounted) return;

      setState(() {
        compressedImage = output;
        originalSize = oldSize;
        compressedSize = newSize;
      });

      showMessage('Photo compression complete!');
    } catch (e) {
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

  Future<void> shareImage() async {
    if (compressedImage == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(compressedImage!.path)],
          text: 'Compressed Photo - DocuMaster',
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
          'Photo Compress',
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
                    Icons.photo_size_select_small,
                    size: 55,
                    color: Color(0xFF2457C5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Reduce Photo Size',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173B83),
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Compress your photos and save storage space.',
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
                onPressed: isCompressing ? null : pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose Photo'),
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
                'Selected Photo',
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
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 150,
                      child: Center(
                        child: Text('Image preview unavailable'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
              'Image Quality',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Compression Quality'),
                      Text(
                        '$quality%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2457C5),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: quality.toDouble(),
                    min: 20,
                    max: 100,
                    divisions: 16,
                    activeColor: const Color(0xFF2457C5),
                    label: '$quality%',
                    onChanged: isCompressing
                        ? null
                        : (value) {
                            setState(() {
                              quality = value.round();
                            });
                          },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Smaller Size',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Better Quality',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isCompressing ? null : compressImage,
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
                  isCompressing ? 'Compressing...' : 'Compress Photo',
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

            if (compressedImage != null) ...[
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
                        compressedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sizeRow('Original Size', originalSize!),
                    const SizedBox(height: 8),
                    _sizeRow('Compressed Size', compressedSize!),
                    const SizedBox(height: 12),
                    if (compressedSize! < originalSize!)
                      Text(
                        'Size reduced by ${((originalSize! - compressedSize!) / originalSize! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        'Is photo ka size kam nahi hua. Original photo pehle se optimized ho sakti hai.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: shareImage,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Compressed Photo'),
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
