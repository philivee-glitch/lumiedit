import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/editor_constants.dart';

class FilterPreview extends StatelessWidget {
  final FilterType filter;
  final Uint8List? imageBytes;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterPreview({
    super.key,
    required this.filter,
    required this.imageBytes,
    required this.isSelected,
    required this.onTap,
  });

  List<Color> get _filterGradient {
    switch (filter) {
      case FilterType.none:
        return [Colors.grey.shade700, Colors.grey.shade800];
      case FilterType.aurora:
        return [Colors.teal.shade400, Colors.cyan.shade600];
      case FilterType.velvet:
        return [Colors.orange.shade300, Colors.brown.shade400];
      case FilterType.midnight:
        return [Colors.indigo.shade400, Colors.blue.shade900];
      case FilterType.golden:
        return [Colors.amber.shade400, Colors.orange.shade600];
      case FilterType.arctic:
        return [Colors.lightBlue.shade300, Colors.blue.shade400];
      case FilterType.noir:
        return [Colors.grey.shade600, Colors.grey.shade900];
      case FilterType.bloom:
        return [Colors.pink.shade200, Colors.purple.shade300];
      case FilterType.ember:
        return [Colors.deepOrange.shade400, Colors.red.shade600];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Filter preview circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _filterGradient,
                        ),
                      ),
                    ),
                    // Image thumbnail if available
                    if (imageBytes != null)
                      Opacity(
                        opacity: 0.85,
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    // Filter overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _filterGradient[0].withOpacity(0.3),
                            _filterGradient[1].withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    // Original badge
                    if (filter == FilterType.none)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Filter name
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
