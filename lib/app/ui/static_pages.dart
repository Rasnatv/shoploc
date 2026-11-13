import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/shoploc_logo.dart';
import 'enquiry_screen.dart';

// ---------------------------------------------------------------------------
// Shared design tokens & helpers (same look as EnquiryScreen)
// ---------------------------------------------------------------------------
const Color _cardBlue = Color(0xFF1E60ED);
const Color _pageBg = Color(0xFFF6F8FC);

TextStyle _ts({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = AppColors.textSecondary,
  double? height,
  double? letterSpacing,
}) {
  // Font family comes from the app's AppTextStyle (not Google Fonts)
  final base = size >= 20 ? AppTextStyle.mainHeading : AppTextStyle.bodyMedium;
  return base.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new,
          size: 18, color: AppColors.textPrimary),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
      title,
      style: AppTextStyle.appBarTitle,
    ),
  );
}

/// Blue hero card
BoxDecoration _blueCardDecoration() {
  return BoxDecoration(
    color: _cardBlue,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Color(0x301E60ED),
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );
}

/// White content card
BoxDecoration _whiteCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C000000),
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// About Us
// ---------------------------------------------------------------------------
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(context, 'About Shoploc'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Blue hero card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _blueCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const ShoplocLogo(fontSize: 22, showTagline: true),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bridging Local Fashion with Digital Elegance',
                      style: _ts(
                        size: 24,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Shoploc (shoploc.in) is an Indian e-commerce platform dedicated to connecting discerning consumers with trusted regional merchants, artisan boutiques, and traditional weavers across India.',
                      style: _ts(
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Our collections card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _whiteCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Collections',
                      style: _ts(
                        size: 22,
                        weight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Our curated collections emphasize contemporary women\'s wear—including Co-Ord sets, Kurta sets, Midi dresses, and Tunics—crafted with authentic linen, muslin cotton, and silk blends designed to celebrate your unique grace.',
                      style: _ts(size: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Chip('Co-Ord Sets'),
                        _Chip('Kurta Sets'),
                        _Chip('Midi Dresses'),
                        _Chip('Tunics'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Core brand values card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _whiteCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Brand Values',
                      style: _ts(
                        size: 22,
                        weight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _ValueTile(
                      icon: Icons.verified_rounded,
                      title: '100% Genuine Quality',
                      desc: 'Directly sourced from verified local sellers.',
                    ),
                    const SizedBox(height: 14),
                    const _ValueTile(
                      icon: Icons.groups_rounded,
                      title: 'Community Empowerment',
                      desc: 'Supporting local artisan livelihoods.',
                    ),
                    const SizedBox(height: 14),
                    const _ValueTile(
                      icon: Icons.local_shipping_rounded,
                      title: 'Doorstep Reliability',
                      desc: 'Fast, careful packaging and trackable deliveries.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. CTA
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cardBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EnquiryScreen()),
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 20),
                  label: Text(
                    'CONTACT US',
                    style: _ts(
                      size: 14.5,
                      weight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: _ts(size: 12.5, weight: FontWeight.w700, color: _cardBlue),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ValueTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF0FE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _cardBlue, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _ts(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(desc, style: _ts(size: 12.5, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contact Us (uses the reference screen)
// ---------------------------------------------------------------------------
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EnquiryScreen();
  }
}

// ---------------------------------------------------------------------------
// Terms & Privacy
// ---------------------------------------------------------------------------
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
      backgroundColor: _pageBg,
      appBar: _buildAppBar(context, title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Blue header card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: _blueCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPrivacy
                            ? Icons.privacy_tip_rounded
                            : Icons.description_rounded,
                        color: _cardBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: _ts(
                        size: 24,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last updated: November 2026',
                      style: _ts(
                        size: 12,
                        weight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isPrivacy
                          ? 'Your privacy is paramount at Shoploc. We collect essential information such as your delivery address, phone number, and contact preferences strictly to process and fulfill your orders seamlessly.'
                          : 'Welcome to Shoploc (shoploc.in). By accessing and placing orders through our mobile application, you agree to our standard terms and conditions.',
                      style: _ts(
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const _SectionCard(
                number: '1',
                heading: 'Order Processing & Verification',
                body:
                'All orders are subject to availability and acceptance by our partner boutiques. Shoploc reserves the right to verify customer address and contact details prior to dispatch.',
              ),
              const SizedBox(height: 14),
              const _SectionCard(
                number: '2',
                heading: 'Cancellation & Return Guidelines',
                body:
                'As per Shoploc platform guidelines, our boutique collections follow a verified-item quality check prior to dispatch. If you receive a damaged or incorrect piece, our local support team will resolve it swiftly.',
              ),
              const SizedBox(height: 14),
              const _SectionCard(
                number: '3',
                heading: 'Data Security',
                body:
                'We implement standard encryption protocols to safeguard your personal credentials and never share your data with unauthorized third parties.',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String number;
  final String heading;
  final String body;

  const _SectionCard({
    required this.number,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FE),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: _ts(
                size: 14,
                weight: FontWeight.w800,
                color: _cardBlue,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: _ts(
                    size: 15,
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(body, style: _ts(size: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}