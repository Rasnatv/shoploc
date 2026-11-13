import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  static const Color _cardBlue = Color(0xFF0082CA);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final name = _nameController.text.trim();
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enquiry Submitted!',
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.headingFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you, $name! Your message has been received. Our team will contact you shortly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'OK',
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label copied: $value',
          style: TextStyle(fontFamily: AppTextStyle.bodyFont),
        ),
        backgroundColor: _cardBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Enquiry & Support',
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Get In Touch Blue Card (Exact Web Replica)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _cardBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x301E60ED),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get In Touch',
                      style: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.headingFont,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Have questions about our products or services? Our team is here to help! We strive to provide the best customer experience possible.',
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location Card
                    _buildInfoCard(
                      icon: Icons.location_on_rounded,
                      title: 'Our Location',
                      content: 'Deli Kalanad(PO)\nKasaragod-671317, Kerala',
                      onTap: () => _copyToClipboard(
                        'Location',
                        'Deli Kalanad(PO), Kasaragod-671317, Kerala',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone Number Card
                    _buildInfoCard(
                      icon: Icons.phone_rounded,
                      title: 'Phone Number',
                      content: '+91 8848 748 469',
                      onTap: () => _copyToClipboard('Phone number', '+91 8848 748 469'),
                    ),
                    const SizedBox(height: 12),

                    // Email Address Card
                    _buildInfoCard(
                      icon: Icons.email_rounded,
                      title: 'Email Address',
                      content: 'razicdeli@gmail.com',
                      onTap: () => _copyToClipboard('Email address', 'razicdeli@gmail.com'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Send Us a Message Form Card (Exact Web Replica)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
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
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Us a Message',
                        style: GoogleFonts.playfairDisplay(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.headingFont,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      _buildFieldLabel('Full Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration('Enter your full name'),
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      _buildFieldLabel('Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration('Enter your email address'),
                      ),
                      const SizedBox(height: 16),

                      // Subject
                      _buildFieldLabel('Subject'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _subjectController,
                        style: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a subject';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration('What is this regarding?'),
                      ),
                      const SizedBox(height: 16),

                      // Message
                      _buildFieldLabel('Message'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _messageController,
                        minLines: 4,
                        maxLines: 6,
                        style: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your message';
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration('Type your message here...'),
                      ),
                      const SizedBox(height: 24),

                      // SEND MESSAGE Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cardBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _sendMessage,
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'SEND MESSAGE',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: 13.5,
          color: const Color(0xFFA0AEC0),
        ),
      ),
      errorStyle: TextStyle(
        fontFamily: AppTextStyle.bodyFont,
        fontSize: 12,
      ),
      filled: true,
      fillColor: const Color(0xFFFBFBFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _cardBlue, width: 1.5),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: _cardBlue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontFamily: AppTextStyle.bodyFont,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    content,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontFamily: AppTextStyle.bodyFont,
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.copy_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
