import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CompareSlider extends StatefulWidget {
  final Uint8List originalImage;
  final Uint8List editedImage;

  const CompareSlider({
    super.key,
    required this.originalImage,
    required this.editedImage,
  });

  @override
  State<CompareSlider> createState() => _CompareSliderState();
}

class _CompareSliderState extends State<CompareSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderPosition += details.delta.dx / constraints.maxWidth;
              _sliderPosition = _sliderPosition.clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // Edited image (full width, behind)
              Positioned.fill(
                child: Image.memory(
                  widget.editedImage,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
              
              // Original image (clipped)
              Positioned.fill(
                child: ClipRect(
                  clipper: _ImageClipper(_sliderPosition),
                  child: Image.memory(
                    widget.originalImage,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              
              // Slider line
              Positioned(
                left: constraints.maxWidth * _sliderPosition - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Handle
              Positioned(
                left: constraints.maxWidth * _sliderPosition - 22,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: AppTheme.backgroundDark,
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppTheme.backgroundDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Labels at bottom instead of top to avoid overlap
              Positioned(
                left: 12,
                bottom: 12,
                child: _buildLabel('Before'),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: _buildLabel('After'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double position;

  _ImageClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return position != oldClipper.position;
  }
}
