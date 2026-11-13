
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SignatureMakerScreen extends StatefulWidget {
  const SignatureMakerScreen({super.key});

  @override
  State<SignatureMakerScreen> createState() =>
      _SignatureMakerScreenState();
}

class _SignatureMakerScreenState extends State<SignatureMakerScreen> {
  final GlobalKey _signatureKey = GlobalKey();

  final List<SignatureStroke> _strokes = [];

  Color _selectedColor = Colors.black;
  bool _isSaving = false;

  final List<Color> _colors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  void _undo() {
    if (_strokes.isEmpty) return;

    setState(() {
      _strokes.removeLast();
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  Future<void> _saveSignature() async {
    if (_strokes.isEmpty) {
      _showMessage('Pehle apna signature banaiye.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await WidgetsBinding.instance.endOfFrame;

      final renderObject =
          _signatureKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Signature capture nahi ho paya.');
      }

      final ui.Image image = await renderObject.toImage(
        pixelRatio: 3.0,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();

      if (byteData == null) {
        throw Exception('PNG file create nahi hui.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final saveDirectory = Directory(
        '${directory.path}/DocuMaster/Signatures',
      );

      if (!await saveDirectory.exists()) {
        await saveDirectory.create(recursive: true);
      }

      final file = File(
        '${saveDirectory.path}/Signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );

      if (!mounted) return;

      _showMessage('Signature successfully save ho gaya!');
    } catch (e) {
      if (mounted) {
        _showMessage('Save error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareSignature() async {
    if (_strokes.isEmpty) {
      _showMessage('Pehle signature banaiye.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await WidgetsBinding.instance.endOfFrame;

      final renderObject =
          _signatureKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Signature capture nahi ho paya.');
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();

      if (byteData == null) {
        throw Exception('PNG create nahi hui.');
      }

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/DocuMaster_Signature.png',
      );

      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'My signature - DocuMaster',
        ),
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Share error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Signature Maker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Your Signature',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Neeche box mein apni ungli se signature banaiye.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Text(
                    'Pen Color',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 14),
                  ..._colors.map((color) {
                    final selected = _selectedColor == color;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Colors.orange
                                : Colors.white,
                            width: selected ? 4 : 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        setState(() {
                          _strokes.add(
                            SignatureStroke(
                              color: _selectedColor,
                              points: [details.localPosition],
                            ),
                          );
                        });
                      },
                      onPanUpdate: (details) {
                        if (_strokes.isEmpty) return;

                        setState(() {
                          _strokes.last.points.add(
                            details.localPosition,
                          );
                        });
                      },
                      child: RepaintBoundary(
                        key: _signatureKey,
                        child: SizedBox.expand(
                          child: CustomPaint(
                            painter: SignaturePainter(
                              strokes: _strokes,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _strokes.isEmpty ? null : _undo,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _strokes.isEmpty ? null : _clear,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSignature,
                  icon: const Icon(Icons.save_alt),
                  label: Text(
                    _isSaving ? 'Please wait...' : 'Save PNG',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2457D6),
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
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _shareSignature,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Signature'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2457D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignatureStroke {
  final Color color;
  final List<Offset> points;

  SignatureStroke({
    required this.color,
    required this.points,
  });
}

class SignaturePainter extends CustomPainter {
  final List<SignatureStroke> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path()
          ..moveTo(
            stroke.points.first.dx,
            stroke.points.first.dy,
          );

        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(
            stroke.points[i].dx,
            stroke.points[i].dy,
          );
        }

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return true;
  }
}
