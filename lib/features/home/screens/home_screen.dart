import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../editor/screens/editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildHeader(),
                const Spacer(flex: 1),
                _buildActionButtons(context),
                const Spacer(flex: 2),
                _buildFooter(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 28),
        
        // App name
        Text(
          'LumiEdit',
          style: AppTheme.displayLarge.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'AI-Powered Photo Editing',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // New Edit button
        _buildMainButton(
          context,
          icon: Icons.add_photo_alternate_rounded,
          label: 'New Edit',
          subtitle: 'Choose a photo to enhance',
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const EditorScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          isPrimary: true,
        ),
        
        const SizedBox(height: 14),
        
        // Feature cards row
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.face_retouching_natural_rounded,
                label: 'Beauty',
                color: Colors.pink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.filter_vintage_rounded,
                label: 'Filters',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.tune_rounded,
                label: 'Adjust',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.surfaceLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isPrimary ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.primaryOrange,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.8)
                          : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isPrimary ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isPrimary ? Colors.white : AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: AppTheme.textTertiary.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              'Powered by AI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textTertiary.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'CODENestle',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textTertiary.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
