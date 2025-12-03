import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class AdjustmentSlider extends StatefulWidget {
  final String label;
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  const AdjustmentSlider({
    super.key,
    required this.label,
    required this.value,
    this.minValue = -100,
    this.maxValue = 100,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<AdjustmentSlider> createState() => _AdjustmentSliderState();
}

class _AdjustmentSliderState extends State<AdjustmentSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(AdjustmentSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppTheme.textSecondary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          // Label and value
          SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _currentValue >= 0 ? '+${_currentValue.toInt()}' : '${_currentValue.toInt()}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Slider
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.primaryOrange,
                inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.3),
                thumbColor: AppTheme.primaryOrange,
                overlayColor: AppTheme.primaryOrange.withOpacity(0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: _currentValue,
                min: widget.minValue,
                max: widget.maxValue,
                onChanged: (value) {
                  setState(() {
                    _currentValue = value.roundToDouble();
                  });
                  HapticFeedback.selectionClick();
                  widget.onChanged(_currentValue);
                },
              ),
            ),
          ),
          // Done button
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Done',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
