
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoploc/app/core/theme/app_colors.dart';
import 'package:shoploc/app/core/theme/app_text_style.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';
import 'package:shoploc/app/core/utils/validator.dart';
import 'package:shoploc/app/widgets/appsnackbar.dart';
import 'package:shoploc/app/widgets/responsive.dart';
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
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(RegisterRequested(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      referralCode: _referralController.text.trim(),
    ));
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context
        .read<AuthBloc>()
        .add(LoginRequested(email: _emailController.text.trim()));
  }

  /// Opens the OtpScreen (route '/otp') and waits for the verify result.
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
      fontSize: Responsive.sp(13),
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
            TextSpan(
              text: '(Optional)',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: Responsive.sp(12),
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
        fontSize: Responsive.sp(hintSize),
        letterSpacing: 0,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: _themeBlue, size: Responsive.sp(20)),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.sp(16), vertical: Responsive.sp(14)),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(_themeBlue, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  Widget _nameField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Full Name', required: true),
      SizedBox(height: Responsive.sp(6)),
      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        style: TextStyle(
            fontFamily: AppTextStyle.bodyFont, fontSize: Responsive.sp(14)),
        validator: (v) => DValidator.validateName('Full name', v),
        decoration: _decoration('Enter your full name'),
      ),
    ],
  );

  Widget _emailField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Email Address', required: true),
      SizedBox(height: Responsive.sp(6)),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction:
        _isRegisterMode ? TextInputAction.next : TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        // emails never contain spaces
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        onFieldSubmitted: (_) {
          if (!_isRegisterMode) _handleLogin();
        },
        style: TextStyle(
            fontFamily: AppTextStyle.bodyFont, fontSize: Responsive.sp(14)),
        validator: DValidator.validateEmail,
        decoration: _decoration('Enter your email address'),
      ),
    ],
  );

  // Codes are case-sensitive (e.g. n4AXtPSQPq), so no forced capitals.
  Widget _referralField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label('Referral Code', optional: true),
      SizedBox(height: Responsive.sp(6)),
      TextFormField(
        controller: _referralController,
        textCapitalization: TextCapitalization.none,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        onFieldSubmitted: (_) => _handleRegister(),
        style: TextStyle(
          fontFamily: AppTextStyle.bodyFont,
          fontSize: Responsive.sp(14),
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
      height: Responsive.sp(50),
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
              fontSize: Responsive.sp(15.5),
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
                fontSize: Responsive.sp(13.5),
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
      padding: EdgeInsets.only(
          right: Responsive.sp(16), top: Responsive.sp(10), bottom: Responsive.sp(6)),
      child: InkWell(
        onTap: _skip,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.sp(14), vertical: Responsive.sp(6)),
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
                    fontSize: Responsive.sp(13),
                    fontWeight: FontWeight.w700,
                    color: _themeBlue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: Responsive.sp(11), color: _themeBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _closeButton() {
    return Padding(
      padding: EdgeInsets.only(right: Responsive.sp(16), top: Responsive.sp(8)),
      child: GestureDetector(
        onTap: () => context.pop(false),
        child: Container(
          width: Responsive.sp(36),
          height: Responsive.sp(36),
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
          child: Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: Responsive.sp(20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gap = Responsive.sp(16);

    return PopScope(
      canPop: !widget.isFromOnboarding,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.isFromOnboarding) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 1,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleSpacing: 16,
          automaticallyImplyLeading: false,
          actions: [widget.isFromOnboarding ? _skipButton() : _closeButton()],
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
          ModalRoute.of(context)?.isCurrent ?? false,
          listener: (context, state) {
            // OTP sent -> navigate to OtpScreen ('/otp')
            if (state is OtpSentState && !state.isResend) {
              AppSnackbar.success(state.message);
              _openOtp(state);
            } else if (state is AuthErrorState) {
              AppSnackbar.error(state.errorMessage);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoadingState;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                      horizontal: Responsive.sp(20), vertical: Responsive.sp(12)),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.sp(24),
                        vertical: Responsive.sp(26)),
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ShoplocLogo(
                                fontSize: Responsive.sp(22), showTagline: false),
                          ),
                          SizedBox(height: Responsive.sp(20)),
                          Text(
                            _isRegisterMode ? 'WELCOME' : 'WELCOME BACK',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: _themeBlue,
                                fontSize: Responsive.sp(12),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.sp(6)),
                          Text(
                            _isRegisterMode ? 'Create Account' : 'User Login',
                            style: GoogleFonts.playfairDisplay(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.headingFont,
                                fontSize: Responsive.sp(26),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.sp(4)),
                          Text(
                            _isRegisterMode
                                ? 'Create your account to continue.'
                                : 'Login with your email to continue.',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: Responsive.sp(13.5),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.sp(22)),
                          if (_isRegisterMode) ...[
                            _nameField(),
                            SizedBox(height: gap),
                            _emailField(),
                            SizedBox(height: gap),
                            _referralField(),
                            SizedBox(height: Responsive.sp(24)),
                            _primaryButton(
                                'Create Account', isLoading, _handleRegister),
                            SizedBox(height: Responsive.sp(18)),
                            _toggleText('Already have an account?', 'Login',
                                    () {
                                  _formKey.currentState?.reset();
                                  setState(() => _isRegisterMode = false);
                                }),
                          ] else ...[
                            _emailField(),
                            SizedBox(height: Responsive.sp(24)),
                            _primaryButton(
                                'Login with Email', isLoading, _handleLogin),
                            SizedBox(height: Responsive.sp(18)),
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