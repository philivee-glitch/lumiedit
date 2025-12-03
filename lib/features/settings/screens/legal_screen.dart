import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum LegalType { terms, privacy }

class LegalScreen extends StatelessWidget {
  final String title;
  final LegalType type;

  const LegalScreen({
    super.key,
    required this.title,
    required this.type,
  });

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
        title: Text(title, style: AppTheme.headlineMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            type == LegalType.terms ? _termsOfService : _privacyPolicy,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  static const String _termsOfService = '''
TERMS OF SERVICE

Last Updated: December 2024

Welcome to LumiEdit. By using our app, you agree to these terms.

1. ACCEPTANCE OF TERMS

By downloading, installing, or using LumiEdit ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the App.

2. DESCRIPTION OF SERVICE

LumiEdit is a photo editing application that provides tools for enhancing, filtering, cropping, and adjusting images. The App processes images locally on your device.

3. USER RESPONSIBILITIES

You agree to:
- Use the App only for lawful purposes
- Not use the App to process illegal, harmful, or offensive content
- Not attempt to reverse engineer, modify, or hack the App
- Not use the App in any way that could damage or impair the service

4. INTELLECTUAL PROPERTY

The App, including its design, features, and content, is owned by CODENestle Pty Ltd. You may not copy, modify, distribute, or create derivative works based on the App without our written permission.

5. USER CONTENT

You retain ownership of all photos and images you edit using the App. We do not claim any ownership rights over your content. The App processes images locally on your device and does not upload your photos to any server.

6. DISCLAIMER OF WARRANTIES

The App is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free, uninterrupted, or meet your specific requirements.

7. LIMITATION OF LIABILITY

To the maximum extent permitted by law, CODENestle Pty Ltd shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App.

8. CHANGES TO TERMS

We may update these terms from time to time. Continued use of the App after changes constitutes acceptance of the new terms.

9. TERMINATION

We reserve the right to terminate or suspend access to the App at any time, without notice, for any reason.

10. GOVERNING LAW

These terms are governed by the laws of Western Australia, Australia.

11. CONTACT

For questions about these Terms, contact us at:
support@codenestle.com

CODENestle Pty Ltd
Perth, Western Australia
''';

  static const String _privacyPolicy = '''
PRIVACY POLICY

Last Updated: December 2024

CODENestle Pty Ltd ("we", "our", or "us") respects your privacy. This policy explains how LumiEdit handles your information.

1. INFORMATION WE COLLECT

LumiEdit is designed with privacy in mind. We collect minimal information:

Device Information:
- Device type and operating system version
- App version
- General usage statistics (anonymised)

We DO NOT collect:
- Your photos or edited images
- Personal identification information
- Location data
- Contact information

2. HOW YOUR PHOTOS ARE HANDLED

All photo processing occurs locally on your device. Your images are never uploaded to our servers. When you edit a photo:
- The image is processed entirely on your device
- Edited images are saved only to your device's photo library
- We have no access to your photos

3. DATA STORAGE

Any app preferences or settings are stored locally on your device using standard iOS storage mechanisms. This data is not transmitted to us.

4. THIRD-PARTY SERVICES

The App may use the following third-party services:
- Apple's StoreKit for in-app purchases (if applicable)
- Apple's crash reporting services

These services have their own privacy policies.

5. CHILDREN'S PRIVACY

LumiEdit does not knowingly collect information from children under 13. The App is intended for general audiences.

6. DATA SECURITY

We implement appropriate security measures to protect any information we collect. However, no method of electronic storage is 100% secure.

7. YOUR RIGHTS

You have the right to:
- Access any personal data we hold about you
- Request deletion of your data
- Opt out of analytics (through device settings)

8. CHANGES TO THIS POLICY

We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy in the App.

9. CONTACT US

If you have questions about this Privacy Policy, please contact us:

Email: support@codenestle.com

CODENestle Pty Ltd
Perth, Western Australia

10. CONSENT

By using LumiEdit, you consent to this Privacy Policy.
''';
}
