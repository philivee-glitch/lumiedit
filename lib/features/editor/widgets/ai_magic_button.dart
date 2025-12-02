import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AIMagicButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isProcessing;

  const AIMagicButton({
    super.key,
    required this.onTap,
    this.isProcessing = false,
  });

  @override
  State<AIMagicButton> createState() => _AIMagicButtonState();
}

class _AIMagicButtonState extends State<AIMagicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.3 + _pulseAnimation.value * 0.2),
                blurRadius: 12 + _pulseAnimation.value * 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.isProcessing ? null : widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isProcessing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              const SizedBox(width: 6),
              Text(
                widget.isProcessing ? 'Working...' : 'AI Enhance',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIBeautyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isProcessing;

  const AIBeautyButton({
    super.key,
    required this.onTap,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade400,
              Colors.purple.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(
                Icons.face_retouching_natural_rounded,
                size: 22,
                color: Colors.white,
              ),
            const SizedBox(height: 4),
            Text(
              isProcessing ? 'Wait...' : 'Auto',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
