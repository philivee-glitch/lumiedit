import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Help & FAQ', style: AppTheme.headlineMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection('Getting Started', [
              _buildFAQ(
                'How do I edit a photo?',
                'Tap "Select Photo" on the home screen to choose an image from your gallery, or tap the camera icon to take a new photo. Once selected, you\'ll be taken to the editor.',
              ),
              _buildFAQ(
                'How do I save my edited photo?',
                'After making your edits, tap the "Save" button at the bottom of the screen. Your photo will be saved to your device\'s photo gallery.',
              ),
              _buildFAQ(
                'Can I undo my changes?',
                'Yes! Use the undo and redo buttons in the top right corner of the editor to step back through your changes.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Adjustments', [
              _buildFAQ(
                'What does each adjustment do?',
                '• Light: Overall brightness\n• Contrast: Difference between light and dark\n• Vibrance: Colour intensity\n• Warmth: Colour temperature (warm/cool)\n• Exposure: Light sensitivity\n• Highlights: Bright area adjustment\n• Shadows: Dark area adjustment\n• Sharpness: Edge definition',
              ),
              _buildFAQ(
                'How do I reset an adjustment?',
                'Tap the "Reset" button while an adjustment is selected, or use the undo button to step back.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Beauty Tools', [
              _buildFAQ(
                'What do the beauty tools do?',
                '• Smooth: Softens skin texture\n• Blemish: Reduces spots and imperfections\n• Skin Tone: Evens out skin colour\n• Face Light: Brightens facial areas',
              ),
              _buildFAQ(
                'Why don\'t the beauty tools affect the whole image?',
                'Beauty tools are designed to detect and enhance skin areas only, preserving details in eyes, hair, and background.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Filters & Crop', [
              _buildFAQ(
                'How do I apply a filter?',
                'Go to the Filters tab and tap on any filter preview to apply it. Tap again to remove.',
              ),
              _buildFAQ(
                'How do I crop or rotate my photo?',
                'Go to the Crop tab. Use the Crop button to adjust framing, or use the rotate/flip buttons for orientation.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('AI Enhance', [
              _buildFAQ(
                'What does AI Enhance do?',
                'AI Enhance automatically applies optimised adjustments to improve your photo with one tap. It analyses your image and applies balanced brightness, contrast, and colour corrections.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Premium & Ads', [
              _buildFAQ(
                'How do I remove ads?',
                'Go to Settings and tap "Go Premium". Choose a subscription plan (monthly, annual, or lifetime) to enjoy an ad-free experience.',
              ),
              _buildFAQ(
                'How do I restore my purchase?',
                'Go to Settings > Go Premium and tap "Restore Purchases" at the bottom of the screen.',
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection('Troubleshooting', [
              _buildFAQ(
                'The app is running slowly',
                'Try closing other apps to free up memory. Very large images may take longer to process.',
              ),
              _buildFAQ(
                'My photo didn\'t save',
                'Ensure you have granted photo library access in your device settings. Go to Settings > LumiEdit > Photos and select "Add Photos Only" or "All Photos".',
              ),
              _buildFAQ(
                'Need more help?',
                'Contact us at support@codenestle.com and we\'ll be happy to assist you.',
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
