import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class RadialDial extends StatefulWidget {
  final String label;
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onChanged;
  final VoidCallback onClose;

  const RadialDial({
    super.key,
    required this.label,
    required this.value,
    this.minValue = -100,
    this.maxValue = 100,
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<RadialDial> createState() => _RadialDialState();
}

class _RadialDialState extends State<RadialDial> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  double _currentValue = 0;
  double _startAngle = 0;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details, Size dialSize) {
    final center = Offset(dialSize.width / 2, dialSize.height / 2);
    _startAngle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details, Size dialSize) {
    final center = Offset(dialSize.width / 2, dialSize.height / 2);
    final currentAngle = math.atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );
    
    var angleDiff = currentAngle - _startAngle;
    if (angleDiff > math.pi) angleDiff -= 2 * math.pi;
    if (angleDiff < -math.pi) angleDiff += 2 * math.pi;
    
    final range = widget.maxValue - widget.minValue;
    final valueChange = (angleDiff / math.pi) * range * 0.5;
    
    final newValue = (_currentValue + valueChange).clamp(widget.minValue, widget.maxValue);
    
    if ((newValue - _currentValue).abs() > 0.5) {
      setState(() {
        _currentValue = newValue.roundToDouble();
      });
      _startAngle = currentAngle;
      HapticFeedback.selectionClick();
      widget.onChanged(_currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const dialSize = 200.0;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withOpacity(0.2 * _fadeAnimation.value),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          // Radial dial at bottom
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 20 + _slideAnimation.value,
                left: (screenSize.width - dialSize) / 2,
                child: child!,
              );
            },
            child: GestureDetector(
              onTap: () {},
              onPanStart: (details) => _handlePanStart(details, const Size(dialSize, dialSize)),
              onPanUpdate: (details) => _handlePanUpdate(details, const Size(dialSize, dialSize)),
              child: Container(
                width: dialSize,
                height: dialSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1E),
                  border: Border.all(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _ModernDialPainter(
                    value: _currentValue,
                    minValue: widget.minValue,
                    maxValue: widget.maxValue,
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF222226),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentValue >= 0 
                                ? '+${_currentValue.round()}' 
                                : '${_currentValue.round()}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryOrange,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Quick action buttons
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 20 + _slideAnimation.value,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickButton(
                  icon: Icons.refresh_rounded,
                  label: 'Reset',
                  onTap: () {
                    setState(() => _currentValue = 0);
                    widget.onChanged(0);
                    HapticFeedback.mediumImpact();
                  },
                ),
                const SizedBox(width: 12),
                _buildQuickButton(
                  icon: Icons.remove_rounded,
                  label: '-10',
                  onTap: () {
                    final newVal = (_currentValue - 10).clamp(widget.minValue, widget.maxValue);
                    setState(() => _currentValue = newVal);
                    widget.onChanged(newVal);
                    HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(width: 12),
                _buildQuickButton(
                  icon: Icons.add_rounded,
                  label: '+10',
                  onTap: () {
                    final newVal = (_currentValue + 10).clamp(widget.minValue, widget.maxValue);
                    setState(() => _currentValue = newVal);
                    widget.onChanged(newVal);
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),
          ),
          
          // Done button
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 16 + _slideAnimation.value * 0.3,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Center(
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernDialPainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;

  _ModernDialPainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw tick marks
    final tickPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 2 * math.pi / 36) - math.pi / 2;
      final isMainTick = i % 9 == 0;
      final tickLength = isMainTick ? 12.0 : 6.0;
      
      final innerRadius = radius - 18 - tickLength;
      final outerRadius = radius - 18;
      
      final start = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      
      tickPaint.color = isMainTick 
          ? Colors.white.withOpacity(0.4)
          : Colors.white.withOpacity(0.15);
      
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw value arc
    final normalizedValue = (value - minValue) / (maxValue - minValue);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Background arc
    arcPaint.color = Colors.white.withOpacity(0.1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 30),
      -math.pi / 2,
      2 * math.pi,
      false,
      arcPaint,
    );

    // Value arc
    final startAngle = -math.pi / 2;
    final sweepAngle = (normalizedValue - 0.5) * math.pi * 1.8;
    
    arcPaint.color = AppTheme.primaryOrange;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 30),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw value indicator dot
    final indicatorAngle = startAngle + sweepAngle;
    final indicatorPosition = Offset(
      center.dx + (radius - 30) * math.cos(indicatorAngle),
      center.dy + (radius - 30) * math.sin(indicatorAngle),
    );
    
    // Glow
    final glowPaint = Paint()
      ..color = AppTheme.primaryOrange.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(indicatorPosition, 6, glowPaint);
    
    // Dot
    final dotPaint = Paint()
      ..color = AppTheme.primaryOrange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(indicatorPosition, 5, dotPaint);
    
    // Inner white dot
    dotPaint.color = Colors.white;
    canvas.drawCircle(indicatorPosition, 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ModernDialPainter oldDelegate) {
    return value != oldDelegate.value;
  }
}
