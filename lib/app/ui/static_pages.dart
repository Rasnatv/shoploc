import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/shoploc_logo.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text('About Shoploc', style: AppTextStyle.appBarTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShoplocLogo(fontSize: 26, showTagline: true),
            const SizedBox(height: 24),
            Text(
              'Bridging Local Fashion with Digital Elegance',
              textAlign: TextAlign.center,
              style: AppTextStyle.sectionHeading,
            ),
            const SizedBox(height: 16),
            Text(
              'Shoploc (shoploc.in) is an Indian e-commerce platform dedicated to connecting discerning consumers with trusted regional merchants, artisan boutiques, and traditional weavers across India.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Our curated collections emphasize contemporary women\'s wear—including Co-Ord sets, Kurta sets, Midi dresses, and Tunics—crafted with authentic linen, muslin cotton, and silk blends designed to celebrate your unique grace.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Text('Core Brand Values', style: AppTextStyle.labelLarge),
                  const SizedBox(height: 12),
                  _buildBullet('100% Genuine Quality', 'Directly sourced from verified local sellers.'),
                  _buildBullet('Community Empowerment', 'Supporting local artisan livelihoods.'),
                  _buildBullet('Doorstep Reliability', 'Fast, careful packaging and trackable deliveries.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyle.bodySmall,
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text('Contact Us', style: AppTextStyle.appBarTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We\'d love to hear from you', style: AppTextStyle.sectionHeading),
            const SizedBox(height: 8),
            Text(
              'Have a question about your order, sizing, or styling advice? Our customer support team is always ready to assist.',
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildCard(
              Icons.phone_outlined,
              'Phone Support',
              AppConstants.supportPhone,
              'Mon – Sat, 9:00 AM – 6:00 PM IST',
            ),
            const SizedBox(height: 14),
            _buildCard(
              Icons.mail_outline,
              'Email Support',
              AppConstants.supportEmail,
              'Alternate: ${AppConstants.altEmail}',
            ),
            const SizedBox(height: 14),
            _buildCard(
              Icons.location_on_outlined,
              'Office Address',
              'Shoploc HQ',
              AppConstants.brandAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String main, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(main, style: AppTextStyle.labelLarge),
                const SizedBox(height: 2),
                Text(sub, style: AppTextStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TermsPrivacyScreen extends StatelessWidget {
  final String title;
  final bool isPrivacy;

  const TermsPrivacyScreen({
    super.key,
    required this.title,
    required this.isPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(title, style: AppTextStyle.appBarTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyle.mainHeading.copyWith(fontSize: 22)),
            const SizedBox(height: 6),
            Text('Last updated: November 2026', style: AppTextStyle.caption),
            const SizedBox(height: 18),
            Text(
              isPrivacy
                  ? 'Your privacy is paramount at Shoploc. We collect essential information such as your delivery address, phone number, and contact preferences strictly to process and fulfill your orders seamlessly.'
                  : 'Welcome to Shoploc (shoploc.in). By accessing and placing orders through our mobile application, you agree to our standard terms and conditions.',
              style: AppTextStyle.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('1. Order Processing & Verification', style: AppTextStyle.labelLarge),
            const SizedBox(height: 6),
            Text(
              'All orders are subject to availability and acceptance by our partner boutiques. Shoploc reserves the right to verify customer address and contact details prior to dispatch.',
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('2. Cancellation & Return Guidelines', style: AppTextStyle.labelLarge),
            const SizedBox(height: 6),
            Text(
              'As per Shoploc platform guidelines, our boutique collections follow a verified-item quality check prior to dispatch. If you receive a damaged or incorrect piece, our local support team will resolve it swiftly.',
              style: AppTextStyle.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('3. Data Security', style: AppTextStyle.labelLarge),
            const SizedBox(height: 6),
            Text(
              'We implement standard encryption protocols to safeguard your personal credentials and never share your data with unauthorized third parties.',
              style: AppTextStyle.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

