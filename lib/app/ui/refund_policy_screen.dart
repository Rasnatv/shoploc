import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'enquiry_screen.dart';

class RefundPolicyScreen extends StatefulWidget {
  const RefundPolicyScreen({super.key});

  @override
  State<RefundPolicyScreen> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey> _sectionKeys = List.generate(6, (_) => GlobalKey());

  final List<String> _sectionTitles = const [
    '1. Overview',
    '2. No Refund Policy',
    '3. Exceptions',
    '4. Damaged / Wrong Items',
    '5. Failed Payments',
    '6. How to Contact Us',
  ];

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $value',
            style: TextStyle(fontFamily: AppTextStyle.bodyFont)),
        backgroundColor: AppColors.brandBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Refund Policy',
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Title
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
                        color: AppColors.brandBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OFFICIAL STORE POLICY',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.brandBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Refund Policy',
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
                      'Last updated: November 13, 2026 · Please read our refund policy carefully before placing an order.',
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

              const SizedBox(height: 18),

              // Table of Contents Section Pills
              Text(
                'CONTENTS',
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_sectionTitles.length, (index) {
                  return ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    label: Text(
                      _sectionTitles[index],
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ),
                    onPressed: () => _scrollToSection(index),
                  );
                }),
              ),

              const SizedBox(height: 22),

              // 01 Overview
              _buildSectionCard(
                key: _sectionKeys[0],
                number: '01',
                title: 'Overview',
                children: [
                  _buildParagraph(
                    'At Shoploc, we take great care to ensure every order is packed and delivered correctly. This Refund Policy explains the circumstances under which refunds may or may not be issued.',
                  ),
                  const SizedBox(height: 10),
                  _buildHighlightBox(
                    'All sales on Shoploc are final. We do not accept returns or exchanges once an order has been confirmed and payment processed.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 02 No Refund Policy
              _buildSectionCard(
                key: _sectionKeys[1],
                number: '02',
                title: 'No Refund Policy',
                children: [
                  _buildParagraph(
                    'Once an order is placed and payment is successfully received, the transaction is considered final. Refunds will not be issued for:',
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint(
                      'Change of mind or incorrect selection by the customer.'),
                  _buildBulletPoint(
                      'Orders placed by mistake after confirmation.'),
                  _buildBulletPoint(
                      'Delayed delivery due to courier, logistics, or circumstances beyond our control.'),
                  _buildBulletPoint(
                      'Minor colour or shade variations due to screen display differences.'),
                  _buildBulletPoint(
                      'Products that have been used, washed, or altered after delivery.'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                    'We encourage you to review your cart carefully before completing your purchase.',
                    isBold: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 03 Exceptions
              _buildSectionCard(
                key: _sectionKeys[2],
                number: '03',
                title: 'Exceptions',
                children: [
                  _buildParagraph(
                    'We will consider refund or replacement requests only in the following exceptional cases:',
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint(
                      'The item delivered is defective or damaged due to our error or during shipping.'),
                  _buildBulletPoint(
                      'You received an incorrect item that does not match your order.'),
                  _buildBulletPoint(
                      'The item is missing from your delivered package.'),
                  const SizedBox(height: 12),
                  _buildWarningBox(
                    'All exception requests must be raised within 48 hours of delivery with supporting photo or video evidence. Requests raised after this window will not be entertained.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 04 Damaged or Wrong Items
              _buildSectionCard(
                key: _sectionKeys[3],
                number: '04',
                title: 'Damaged or Wrong Items',
                children: [
                  _buildParagraph(
                    'If you receive a damaged, defective, or incorrect product, please follow these steps:',
                  ),
                  const SizedBox(height: 10),
                  _buildNumberedStep(1,
                      'Contact our support team within 48 hours of delivery.'),
                  _buildNumberedStep(2,
                      'Share clear photos or a short video showing the issue with the product and the packaging.'),
                  _buildNumberedStep(3,
                      'Include your Order ID and registered email or phone number in your message.'),
                  const SizedBox(height: 14),
                  _buildParagraph(
                    'Once we review and verify your claim, we reserve the right to offer one of the following resolutions at our sole discretion:',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                      'A replacement of the same product (subject to availability).'),
                  _buildBulletPoint(
                      'A store credit for a future purchase.'),
                  _buildBulletPoint(
                      'A refund to your original payment method in exceptional cases only.'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                    'We review all damage claims individually. Approval is not guaranteed and is at the discretion of the Shoploc team.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 05 Failed Payment Reversals
              _buildSectionCard(
                key: _sectionKeys[4],
                number: '05',
                title: 'Failed Payment Reversals',
                children: [
                  _buildParagraph(
                    'If your payment was deducted but your order was not confirmed due to a technical failure or payment gateway error:',
                  ),
                  const SizedBox(height: 10),
                  _buildBulletPoint(
                      'The amount will be automatically reversed to your original payment method within 5–7 business days as per Razorpay\'s payment gateway policy.'),
                  _buildBulletPoint(
                      'If the amount is not reversed after 7 business days, please contact us with your transaction reference number.'),
                  const SizedBox(height: 10),
                  _buildParagraph(
                    'We will coordinate with our payment gateway to resolve the issue promptly.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 06 How to Contact Us
              _buildSectionCard(
                key: _sectionKeys[5],
                number: '06',
                title: 'How to Contact Us',
                children: [
                  _buildParagraph(
                    'To raise a refund or damage claim, please reach out to us through any of the following channels:',
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'info@shoploc.in',
                    onTap: () => _copyToClipboard('Email', 'info@shoploc.in'),
                  ),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    icon: Icons.language_rounded,
                    label: 'Contact Page',
                    value: 'shoploc.in/contact',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EnquiryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    icon: Icons.access_time_rounded,
                    label: 'Business Hours',
                    value: 'Monday – Saturday, 9:00 AM – 6:00 PM IST',
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  _buildParagraph(
                    'Please include your Order ID, contact details, and a clear description of the issue. We aim to respond within 2 business days.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlue,
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
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        'Open Enquiry Desk',
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

  Widget _buildSectionCard({
    required Key key,
    required String number,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
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
                      fontSize: 19,
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

  Widget _buildParagraph(String text, {bool isBold = false}) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: 13.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: const Color(0xFF374151),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.brandBlue),
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

  Widget _buildNumberedStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontFamily: AppTextStyle.bodyFont,
                  fontSize: 13.5,
                  color: const Color(0xFF374151),
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(String text) {
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
          const Icon(Icons.info_outline, size: 18, color: AppColors.brandBlue),
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

  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontFamily: AppTextStyle.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF92400E),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  fontFamily: AppTextStyle.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 13,
                    color: AppColors.brandBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

