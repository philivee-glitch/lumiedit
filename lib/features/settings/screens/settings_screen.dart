import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/settings_tile.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text('Settings', style: AppTheme.headlineMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              title: 'About',
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate App',
                  subtitle: 'Love LumiEdit? Rate us!',
                  onTap: () => _rateApp(),
                ),
                SettingsTile(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  subtitle: 'Share with friends',
                  onTap: () => _shareApp(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Legal',
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(
                        title: 'Terms of Service',
                        type: LegalType.terms,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalScreen(
                        title: 'Privacy Policy',
                        type: LegalType.privacy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Support',
              children: [
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQ',
                  onTap: () => _openHelp(),
                ),
                SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Contact Us',
                  subtitle: 'support@codenestle.com',
                  onTap: () => _contactSupport(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    'Made with love by',
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CODENestle',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _rateApp() async {
    // iOS App Store URL - replace with actual app ID when published
    final url = Uri.parse('https://apps.apple.com/app/lumiedit');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    // Will implement with share_plus package
  }

  Future<void> _openHelp() async {
    final url = Uri.parse('https://codenestle.com/lumiedit/help');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _contactSupport() async {
    final url = Uri.parse('mailto:support@codenestle.com?subject=LumiEdit Support');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
