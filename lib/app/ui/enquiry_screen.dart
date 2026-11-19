
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/enquiry/enquiry_bloc.dart';
import '../bloc/enquiry/enquiry_event.dart';
import '../bloc/enquiry/enquiry_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../data/models/enquirymodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/responsive.dart';

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

  // Screen-level bloc (no need to register it in main.dart)
  final EnquiryBloc _bloc = EnquiryBloc();

  static const Color _cardBlue = Color(0xFF0082CA);

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  // ---------------- RESPONSIVE HELPERS ----------------

  /// Scale factor for phone widths only (320-480). Responsive.w() keeps
  /// growing on tablets, which would make paddings/inputs oversized there.
  double get _scale =>
      (Responsive.screenWidth.clamp(320.0, 480.0)).toDouble() / 390.0;

  double _w(double designValue) => designValue * _scale;

  /// Max width of the page content on big screens.
  double get _maxContentWidth => Responsive.value(
    mobile: double.infinity,
    tablet: 640.0,
    desktop: 1000.0,
  );

  double get _pagePadding => Responsive.value(
    mobile: _w(16),
    tablet: 24.0,
    desktop: 32.0,
  );

  /// On desktop the contact card and the form sit side by side.
  bool get _twoColumns => Responsive.isDesktop;

  @override
  void initState() {
    super.initState();
    // Logged-in users do not have to type their details again
    if (_loggedIn) {
      _nameController.text = ObjectFactory().prefs.getUserName() ?? '';
      _emailController.text = ObjectFactory().prefs.getUserEmail() ?? '';
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    _bloc.add(SubmitEnquiryEvent(
      request: EnquiryRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      ),
    ));
  }

  void _clearForm() {
    _subjectController.clear();
    _messageController.clear();
    // guests start from an empty form again
    if (!_loggedIn) {
      _nameController.clear();
      _emailController.clear();
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.fromLTRB(_w(24), _w(24), _w(24), _w(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _w(60),
                height: _w(60),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF2E7D32),
                  size: _w(38),
                ),
              ),
              SizedBox(height: _w(16)),
              Text(
                'Enquiry Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.headingFont,
                    fontSize: Responsive.sp(20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: _w(8)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: Responsive.sp(13),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
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
                    fontSize: Responsive.sp(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    AppSnackbar.success('$label copied: $value');
  }

  @override
  Widget build(BuildContext context) {
    // Refresh screen metrics (re-runs on rotation / window resize).
    Responsive.init(context);

    return BlocConsumer<EnquiryBloc, EnquiryState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is EnquirySuccessState) {
          _clearForm();
          _showSuccessDialog(state.message);
        } else if (state is EnquiryErrorState) {
          AppSnackbar.error(state.errorMessage);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is EnquirySubmittingState;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Enquiry & Support',
              style: AppTextStyle.appBarTitle,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              // lets the form scroll away while the keyboard is open
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _pagePadding,
                      vertical: _w(10),
                    ),
                    child: _twoColumns
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildContactCard()),
                        SizedBox(width: _pagePadding),
                        Expanded(child: _buildFormCard(isSubmitting)),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildContactCard(),
                        SizedBox(height: _w(20)),
                        _buildFormCard(isSubmitting),
                        SizedBox(height: _w(24)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- 1. GET IN TOUCH CARD ----------------
  Widget _buildContactCard() {
    return Container(
      padding: EdgeInsets.all(_w(22)),
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
                fontSize: Responsive.sp(25),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: _w(10)),
          Text(
            'Have questions about our products or services? Our team is here to help! We strive to provide the best customer experience possible.',
            style: GoogleFonts.plusJakartaSans(
              textStyle: TextStyle(
                fontFamily: AppTextStyle.bodyFont,
                fontSize: Responsive.sp(13),
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ),
          SizedBox(height: _w(20)),

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
          SizedBox(height: _w(12)),

          // Phone Number Card
          _buildInfoCard(
            icon: Icons.phone_rounded,
            title: 'Phone Number',
            content: '+91 8848 748 469',
            onTap: () =>
                _copyToClipboard('Phone number', '+91 8848 748 469'),
          ),
          SizedBox(height: _w(12)),

          // Email Address Card
          _buildInfoCard(
            icon: Icons.email_rounded,
            title: 'Email Address',
            content: 'razicdeli@gmail.com',
            onTap: () =>
                _copyToClipboard('Email address', 'razicdeli@gmail.com'),
          ),
        ],
      ),
    );
  }

  // ---------------- 2. SEND US A MESSAGE FORM CARD ----------------
  Widget _buildFormCard(bool isSubmitting) {
    return Container(
      padding: EdgeInsets.all(_w(22)),
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
                  fontSize: Responsive.sp(22),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            SizedBox(height: _w(20)),

            // Full Name
            _buildFieldLabel('Full Name'),
            SizedBox(height: _w(6)),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              style: _inputTextStyle(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              decoration: _buildInputDecoration('Enter your full name'),
            ),
            SizedBox(height: _w(16)),

            // Email Address
            _buildFieldLabel('Email Address'),
            SizedBox(height: _w(6)),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: _inputTextStyle(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(val.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: _buildInputDecoration('Enter your email address'),
            ),
            SizedBox(height: _w(16)),

            // Subject
            _buildFieldLabel('Subject'),
            SizedBox(height: _w(6)),
            TextFormField(
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              style: _inputTextStyle(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
              decoration: _buildInputDecoration('What is this regarding?'),
            ),
            SizedBox(height: _w(16)),

            // Message
            _buildFieldLabel('Message'),
            SizedBox(height: _w(6)),
            TextFormField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              style: _inputTextStyle(),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
              decoration: _buildInputDecoration('Type your message here...'),
            ),
            SizedBox(height: _w(24)),

            // SEND MESSAGE Button
            SizedBox(
              width: double.infinity,
              height: Responsive.value(
                mobile: _w(50),
                tablet: 52.0,
                desktop: 52.0,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting ? null : _sendMessage,
                child: isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'SEND MESSAGE',
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontSize: Responsive.sp(14.5),
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
    );
  }

  // ---------------- SHARED PIECES ----------------
  TextStyle _inputTextStyle() => TextStyle(
    fontFamily: AppTextStyle.bodyFont,
    fontSize: Responsive.sp(14),
    color: AppColors.textPrimary,
  );

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        textStyle: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: Responsive.sp(13),
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
          fontSize: Responsive.sp(13.5),
          color: const Color(0xFFA0AEC0),
        ),
      ),
      errorStyle: TextStyle(
        fontFamily: AppTextStyle.bodyFont,
        fontSize: Responsive.sp(12),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFBFD),
      contentPadding:
      EdgeInsets.symmetric(horizontal: _w(16), vertical: _w(14)),
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
    final circle = Responsive.value(
      mobile: _w(40),
      tablet: 44.0,
      desktop: 44.0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _w(14), vertical: _w(12)),
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
              width: circle,
              height: circle,
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
              child: Icon(icon, color: _cardBlue, size: circle * 0.5),
            ),
            SizedBox(width: _w(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontFamily: AppTextStyle.bodyFont,
                        fontSize: Responsive.sp(13.5),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: _w(3)),
                  Text(
                    content,
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontFamily: AppTextStyle.bodyFont,
                        fontSize: Responsive.sp(12.5),
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: _w(8)),
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