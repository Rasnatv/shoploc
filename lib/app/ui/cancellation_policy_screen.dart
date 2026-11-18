import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'enquiry_screen.dart';

class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cancellation Policy',
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
                        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ORDER CANCELLATION GUIDELINES',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cancellation Policy',
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
                      'Last updated: November 13, 2026 · Understanding order cancellations, eligibility windows, and refund procedures.',
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

              // 01 Cancellation Window
              _buildCard(
                number: '01',
                title: 'Customer Cancellation Window',
                children: [
                  _buildText(
                    'You can cancel your order directly through the Shoploc mobile app before the boutique partner accepts, packs, or dispatches your items.',
                  ),
                  const SizedBox(height: 10),
                  _buildHighlight(
                    'Orders can generally be cancelled within 1–2 hours of placement. Once processing begins, cancellation is locked to ensure timely courier dispatch.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 02 Post-Dispatch
              _buildCard(
                number: '02',
                title: 'Post-Dispatch Status',
                children: [
                  _buildText(
                    'Once your order has been packed, handed over to our courier partner, and assigned an AWB tracking number, it cannot be cancelled by the customer.',
                  ),
                  const SizedBox(height: 10),
                  _buildText(
                    'If you no longer require the items, you may politely refuse delivery at your doorstep only if the packaging seal is found visibly damaged or opened.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 03 Cancellation by Shoploc / Seller
              _buildCard(
                number: '03',
                title: 'Cancellation by Shoploc or Seller',
                children: [
                  _buildText(
                    'Under rare circumstances, an order may be cancelled by Shoploc or our partner boutique due to:',
                  ),
                  const SizedBox(height: 8),
                  _buildBullet(
                      'Unexpected stock depletion or fabric defect discovered during quality check.'),
                  _buildBullet(
                      'Logistics disruption or unserviceable delivery pin codes.'),
                  _buildBullet(
                      'Incorrect or incomplete delivery address or unreachable phone verification.'),
                  _buildBullet(
                      'Suspected fraudulent activity or unauthorized payment flag.'),
                  const SizedBox(height: 10),
                  _buildText(
                    'In any such case, the customer will be notified immediately via SMS/Email and a 100% full refund will be initiated instantly.',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 04 Refunds for Cancelled Orders
              _buildCard(
                number: '04',
                title: 'Refund of Cancelled Orders',
                children: [
                  _buildText(
                    'For all orders successfully cancelled within the permissible window:',
                  ),
                  const SizedBox(height: 8),
                  _buildBullet(
                      '100% of the paid order amount will be credited back to your original payment method.'),
                  _buildBullet(
                      'No cancellation penalty or processing fee is charged.'),
                  _buildBullet(
                      'Refunds are processed through Razorpay and reflect in your bank account or UPI wallet within 5–7 business days.'),
                ],
              ),

              const SizedBox(height: 16),

              // 05 How to Request Cancellation
              _buildCard(
                number: '05',
                title: 'How to Request a Cancellation',
                children: [
                  _buildText('You can initiate a cancellation in two ways:'),
                  const SizedBox(height: 10),
                  _buildStep(1,
                      'Go to Profile > My Orders > Select Order > Tap "Cancel Order" (if status is Placed / Pending).'),
                  _buildStep(2,
                      'Contact our support desk immediately at info@shoploc.in or +91 8848 748 469 with your Order ID.'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
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
                      icon: const Icon(Icons.support_agent_rounded, size: 18),
                      label: Text(
                        'Contact Support Desk',
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

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFDC2626)),
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

  Widget _buildStep(int number, String text) {
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
}

