import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'enquiry_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DATA PROTECTION & PRIVACY',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Privacy Policy',
                      style: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.headingFont,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: November 13, 2026 · We value your trust and are committed to safeguarding your personal data.',
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 01 Information We Collect
              _buildCard(
                number: '01',
                title: 'Information We Collect',
                children: [
                  _buildText(
                    'When you create an account, browse products, or place an order on Shoploc (shoploc.in), we collect essential information necessary to serve you:',
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(
                      'Identity Data: Full Name, email address, and mobile phone number for authentication and OTP verification.'),
                  _buildBullet(
                      'Delivery Data: Doorstep shipping address, postal pin code, and recipient contact details.'),
                  _buildBullet(
                      'Transaction Details: Order IDs, purchased product sizes/variants, payment confirmation status, and transaction reference numbers.'),
                  _buildBullet(
                      'Device & App Data: Operating system version, app logs, and install referrer tokens (for partner/staff attribution).'),
                ],
              ),

              const SizedBox(height: 16),

              // 02 How We Use Your Information
              _buildCard(
                number: '02',
                title: 'How We Use Your Information',
                children: [
                  _buildText(
                    'Your data is utilized strictly for lawful e-commerce fulfillment purposes:',
                  ),
                  const SizedBox(height: 8),
                  _buildBullet(
                      'Processing, packing, and dispatching your boutique clothing orders.'),
                  _buildBullet(
                      'Sending real-time SMS, Email, and Push Notifications regarding order milestones and dispatch tracking.'),
                  _buildBullet(
                      'Providing proactive customer support, resolving order queries, and processing replacement requests.'),
                  _buildBullet(
                      'Preventing fraudulent transactions and ensuring overall platform security.'),
                ],
              ),

              const SizedBox(height: 16),

              // 03 Payment Security
              _buildCard(
                number: '03',
                title: 'Payment Security & Encryption',
                children: [
                  _buildText(
                    'All financial transactions on Shoploc are routed through RBI-licensed payment aggregators (e.g., Razorpay) via bank-grade 128-bit SSL encrypted channels.',
                  ),
                  const SizedBox(height: 10),
                  _buildHighlight(
                    'Shoploc does NOT collect, store, or view your debit/credit card numbers, CVVs, UPI PINs, or net banking passwords on our servers.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 04 Data Sharing & Third Parties
              _buildCard(
                number: '04',
                title: 'Third-Party Data Sharing',
                children: [
                  _buildText(
                    'We never sell, rent, or trade your personal data to advertising agencies or unauthorized third parties. We share data only with verified partners strictly required for order fulfillment:',
                  ),
                  const SizedBox(height: 8),
                  _buildBullet(
                      'Logistics Partners: Verified national courier services (e.g. Delhivery, Bluedart, India Post) receive your shipping name, address, and contact number for doorstep delivery.'),
                  _buildBullet(
                      'Payment Gateways: Encrypted transaction payloads sent to Razorpay to verify payment status.'),
                  _buildBullet(
                      'Legal Authorities: Disclosed only when strictly required by applicable Indian law, court order, or governmental mandate.'),
                ],
              ),

              const SizedBox(height: 16),

              // 05 Your Rights & Data Control
              _buildCard(
                number: '05',
                title: 'Your Privacy Rights',
                children: [
                  _buildText('As a valued customer, you have complete control over your personal data:'),
                  const SizedBox(height: 8),
                  _buildBullet('You can view and update your profile details and saved addresses anytime in Profile settings.'),
                  _buildBullet('You can request deletion of your account and personal identifiers by contacting our privacy desk at info@shoploc.in.'),
                  _buildBullet('You can opt-out of non-essential promotional communications at any time.'),
                ],
              ),

              const SizedBox(height: 16),

              // 06 Contact & Grievance Officer
              _buildCard(
                number: '06',
                title: 'Grievance Officer & Contact',
                children: [
                  _buildText(
                    'In accordance with the Information Technology Act 2000 and the Consumer Protection (E-Commerce) Rules, you may address any privacy concerns to:',
                  ),
                  const SizedBox(height: 12),
                  _buildBullet('Platform: Shoploc (shoploc.in)'),
                  _buildBullet('Email: info@shoploc.in / razicdeli@gmail.com'),
                  _buildBullet('Address: Deli Kalanad (PO), Kasaragod – 671317, Kerala, India'),
                  _buildBullet('Support Hours: Monday – Saturday, 9:00 AM – 6:00 PM IST'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EnquiryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: Text(
                        'Contact Grievance Desk',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.headingFont,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: 13.5,
          color: const Color(0xFF374151),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildHighlight(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security_rounded, size: 18, color: AppColors.brandBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontFamily: AppTextStyle.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A8A),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF0D9488)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontFamily: AppTextStyle.bodyFont,
                  fontSize: 13.5,
                  color: const Color(0xFF4B5563),
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

