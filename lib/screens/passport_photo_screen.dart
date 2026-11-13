
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PassportPhotoScreen extends StatefulWidget {
  const PassportPhotoScreen({super.key});

  @override
  State<PassportPhotoScreen> createState() =>
      _PassportPhotoScreenState();
}

class _PassportPhotoScreenState extends State<PassportPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  CroppedFile? _croppedPhoto;
  String _selectedSize = 'Indian Passport';
  bool _isProcessing = false;
  String? _savedPath;

  double get _ratio {
    if (_selectedSize == '2 x 2 inch') {
      return 1.0;
    }
    return 35 / 45;
  }

  int get _photoWidth {
    return _selectedSize == '2 x 2 inch' ? 600 : 413;
  }

  int get _photoHeight {
    return _selectedSize == '2 x 2 inch' ? 600 : 531;
  }

  Future<void> _pickAndCrop(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) return;

      setState(() {
        _isProcessing = true;
        _savedPath = null;
      });

      final CroppedFile? croppedFile =
          await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(
          ratioX: _ratio,
          ratioY: 1,
        ),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Passport Photo',
            toolbarColor: const Color(0xFF1746A2),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF2457C5),
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Passport Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (!mounted) return;

      if (croppedFile != null) {
        setState(() {
          _croppedPhoto = croppedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Photo select error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<File> _createPassportPhoto() async {
    if (_croppedPhoto == null) {
      throw Exception('Pehle photo select kijiye.');
    }

    final tempDirectory = await getTemporaryDirectory();

    final tempPath =
        '${tempDirectory.path}/passport_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile =
        await FlutterImageCompress.compressAndGetFile(
      _croppedPhoto!.path,
      tempPath,
      minWidth: _photoWidth,
      minHeight: _photoHeight,
      quality: 95,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      throw Exception('Photo process nahi ho payi.');
    }

    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final saveDirectory = Directory(
      '${documentsDirectory.path}/DocuMaster/Passport_Photos',
    );

    if (!await saveDirectory.exists()) {
      await saveDirectory.create(recursive: true);
    }

    final outputFile = File(
      '${saveDirectory.path}/Passport_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await File(compressedFile.path).copy(outputFile.path);

    return outputFile;
  }

  Future<void> _savePhoto() async {
    if (_croppedPhoto == null) {
      _showMessage('Pehle photo select kijiye.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final file = await _createPassportPhoto();

      if (!mounted) return;

      setState(() {
        _savedPath = file.path;
      });

      _showMessage('Passport photo successfully save ho gayi!');
    } catch (e) {
      if (mounted) {
        _showMessage('Save error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _sharePhoto() async {
    if (_savedPath == null) {
      _showMessage('Pehle photo save kijiye.');
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(_savedPath!)],
          text: 'Passport Photo - DocuMaster',
        ),
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Share error: $e');
      }
    }
  }

  void _showMessage(String message) {
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
          'Passport Photo Maker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1746A2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Passport Photo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose photo size, select your photo and crop it.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 22),

              const Text(
                'Select Photo Size',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              _sizeOption(
                title: 'Indian Passport',
                subtitle: '35 x 45 mm',
                selected: _selectedSize == 'Indian Passport',
                onTap: () {
                  setState(() {
                    _selectedSize = 'Indian Passport';
                    _croppedPhoto = null;
                    _savedPath = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              _sizeOption(
                title: '2 x 2 inch',
                subtitle: '600 x 600 pixels',
                selected: _selectedSize == '2 x 2 inch',
                onTap: () {
                  setState(() {
                    _selectedSize = '2 x 2 inch';
                    _croppedPhoto = null;
                    _savedPath = null;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Your Photo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFDCE5F4),
                  ),
                ),
                child: _croppedPhoto == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 65,
                            color: Color(0xFF8CA4C9),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No photo selected',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(_croppedPhoto!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickAndCrop(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2457C5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _pickAndCrop(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2457C5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _savePhoto,
                  icon: const Icon(Icons.save_alt),
                  label: Text(
                    _isProcessing ? 'Please wait...' : 'Save Passport Photo',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _savedPath == null ? null : _sharePhoto,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Photo'),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF2457C5),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Photo ko official form mein use karne se pehle us form ki photo size, background aur quality requirements zaroor check karein.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF344968),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF2457C5)
                : const Color(0xFFE2E9F5),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: const Color(0xFF2457C5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
