import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoploc/app/core/theme/app_colors.dart';
import 'package:shoploc/app/core/theme/app_text_style.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';
import 'package:shoploc/app/widgets/shoploc_logo.dart';

import '../bloc/authbloc/auth_bloc.dart';


class CheckoutAuthScreen extends StatefulWidget {
  final bool initialIsRegister;
  final bool isFromOnboarding;

  const CheckoutAuthScreen({
    super.key,
    this.initialIsRegister = true,
    this.isFromOnboarding = false,
  });

  @override
  State<CheckoutAuthScreen> createState() => _CheckoutAuthScreenState();
}

class _CheckoutAuthScreenState extends State<CheckoutAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  late bool _isRegisterMode;

  static const Color _themeBlue = AppColors.brandBlue;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialIsRegister;
    _loadInitialReferralCode();
  }

  /// Autofill the code captured from the Play Store install referrer.
  void _loadInitialReferralCode() {
    final code = ObjectFactory().prefs.getReferralCode();
    if (code != null && code.isNotEmpty) _referralController.text = code;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(RegisterRequested(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      referralCode: _referralController.text.trim(),
    ));
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context
        .read<AuthBloc>()
        .add(LoginRequested(email: _emailController.text.trim()));
  }

  Future<void> _openOtp(OtpSentState s) async {
    final verified = await context.push<bool>('/otp', extra: {
      'name': _nameController.text.trim(),
      'email': s.email,
      'type': s.isRegister ? 'register' : 'login',
    });
    if (verified == true && mounted) _onVerified();
  }

  void _onVerified() {
    if (widget.isFromOnboarding) {
      context.go('/home');
    } else {
      context.pop(true);
    }
  }

  void _skip() => context.go('/home');

  // ---------- UI helpers ----------
  TextStyle get _labelStyle => GoogleFonts.plusJakartaSans(
    textStyle: TextStyle(
      fontFamily: AppTextStyle.bodyFont,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  Widget _label(String text, {bool required = false, bool optional = false}) {
    return RichText(
      text: TextSpan(
        text: '$text ',
        style: _labelStyle,
        children: [
          if (required)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          if (optional)
            const TextSpan(
              text: '(Optional)',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint,
      {IconData? icon, double hintSize = 14}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: AppTextStyle.bodyFont,
        color: AppColors.textTertiary,
        fontSize: hintSize,
        letterSpacing: 0,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: icon == null ? null : Icon(icon, color: _themeBlue, size: 20),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(_themeBlue, 1.5),
    );
  }

  Widget _nameField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Full Name', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        style: TextStyle(fontFamily: AppTextStyle.bodyFont),
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Please enter your full name'
            : null,
        decoration: _decoration('Enter your full name'),
      ),
    ],
  );

  Widget _emailField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Email Address', required: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontFamily: AppTextStyle.bodyFont),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return 'Please enter your email address';
          }
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        decoration: _decoration('Enter your email address'),
      ),
    ],
  );

  // Codes are case-sensitive (e.g. n4AXtPSQPq), so no forced capitals.
  Widget _referralField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Referral Code', optional: true),
      const SizedBox(height: 6),
      TextFormField(
        controller: _referralController,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: false,
        style: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
        decoration: _decoration(
          'Enter referral or salesman code',
          icon: Icons.card_giftcard_outlined,
          hintSize: 13,
        ),
      ),
    ],
  );

  Widget _primaryButton(String text, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            textStyle: TextStyle(
              fontFamily: AppTextStyle.bodyFont,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleText(String normal, String bold, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            text: '$normal ',
            style: GoogleFonts.plusJakartaSans(
              textStyle: TextStyle(
                fontFamily: AppTextStyle.bodyFont,
                fontSize: 13.5,
                color: _themeBlue,
              ),
            ),
            children: [
              TextSpan(
                text: bold,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skipButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 10, bottom: 6),
      child: InkWell(
        onTap: _skip,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: GoogleFonts.plusJakartaSans(
                  textStyle: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _themeBlue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: _themeBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _closeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: GestureDetector(
        onTap: () => context.pop(false),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isFromOnboarding,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.isFromOnboarding) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [widget.isFromOnboarding ? _skipButton() : _closeButton()],
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
          ModalRoute.of(context)?.isCurrent ?? false,
          listener: (context, state) {
            if (state is OtpSentState && !state.isResend) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.brandBlue,
                ),
              );
              _openOtp(state);
            } else if (state is AuthErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child:
                            ShoplocLogo(fontSize: 22, showTagline: false),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isRegisterMode ? 'WELCOME' : 'WELCOME BACK',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: _themeBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isRegisterMode ? 'Create Account' : 'User Login',
                            style: GoogleFonts.playfairDisplay(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.headingFont,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRegisterMode
                                ? 'Create your account to continue.'
                                : 'Login with your email to continue.',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (_isRegisterMode) ...[
                            _nameField(),
                            const SizedBox(height: 16),
                            _emailField(),
                            const SizedBox(height: 16),
                            _referralField(),
                            const SizedBox(height: 24),
                            _primaryButton(
                                'Create Account', isLoading, _handleRegister),
                            const SizedBox(height: 18),
                            _toggleText('Already have an account?', 'Login',
                                    () {
                                  _formKey.currentState?.reset();
                                  setState(() => _isRegisterMode = false);
                                }),
                          ] else ...[
                            _emailField(),
                            const SizedBox(height: 24),
                            _primaryButton(
                                'Login with Email', isLoading, _handleLogin),
                            const SizedBox(height: 18),
                            _toggleText("Don't have an account?", 'Sign Up',
                                    () {
                                  _formKey.currentState?.reset();
                                  setState(() => _isRegisterMode = true);
                                  _loadInitialReferralCode();
                                }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}