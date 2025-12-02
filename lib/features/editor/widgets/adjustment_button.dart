import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/editor_constants.dart';

class AdjustmentButton extends StatelessWidget {
  final AdjustmentType type;
  final double value;
  final VoidCallback onTap;

  const AdjustmentButton({
    super.key,
    required this.type,
    required this.value,
    required this.onTap,
  });

  bool get _hasValue => value != 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _hasValue 
              ? AppTheme.primaryOrange.withOpacity(0.1)
              : AppTheme.surfaceLight.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasValue 
                ? AppTheme.primaryOrange.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow effect when active
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _hasValue 
                    ? AppTheme.primaryOrange.withOpacity(0.15)
                    : AppTheme.textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type.icon,
                size: 22,
                color: _hasValue ? AppTheme.primaryOrange : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              type.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _hasValue ? AppTheme.primaryOrange : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Value indicator
            if (_hasValue) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value > 0 ? '+${value.round()}' : '${value.round()}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
