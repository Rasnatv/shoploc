import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/authbloc/auth_event.dart';
import '../bloc/authbloc/auth_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/shoploc_logo.dart';
import 'loginotpscreen.dart';
import 'otp_screen.dart';

class CheckoutAuthScreen extends StatefulWidget {
  final bool initialIsRegister;

  const CheckoutAuthScreen({
    super.key,
    this.initialIsRegister = true,
  });

  @override
  State<CheckoutAuthScreen> createState() => _CheckoutAuthScreenState();
}

class _CheckoutAuthScreenState extends State<CheckoutAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late bool _isRegisterMode;

  static const Color _themeBlue = AppColors.brandBlue;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginOtpScreen(
            userName: name,
            destination: email,
            verificationType: 'register',
          ),
        ),
      );
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final name = email.contains('@') ? email.split('@').first : 'Customer';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginOtpScreen(
            userName: name,
            destination: email,
            verificationType: 'login',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Circular 'X' close button to dismiss back to checkout
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(false),
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
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthenticatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome, ${authState.user.name}! Your account is verified.',
                  style: TextStyle(fontFamily: AppTextStyle.bodyFont),
                ),
                backgroundColor: AppColors.brandBlue,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop(true);
          } else if (authState is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authState.errorMessage,
                  style: TextStyle(fontFamily: AppTextStyle.bodyFont),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, authState) {
          final isAuthLoading = authState is AuthLoadingState;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
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
                        // Shoploc Logo at top of form
                        const Center(
                          child: ShoplocLogo(fontSize: 22, showTagline: false),
                        ),
                        const SizedBox(height: 20),

                        // 1. Tagline: WELCOME / WELCOME BACK (Blue Theme)
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

                        // 2. Title: Create Account / User Login (Shoploc Serif Heading)
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

                        // 3. Subtitle (Shoploc Body Font)
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

                        // 4. Form Fields
                        if (_isRegisterMode) ...[
                          // Full Name *
                          RichText(
                            text: TextSpan(
                              text: 'Full Name ',
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontFamily: AppTextStyle.bodyFont,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(fontFamily: AppTextStyle.bodyFont),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: AppColors.textTertiary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _themeBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Address *
                          RichText(
                            text: TextSpan(
                              text: 'Email Address ',
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontFamily: AppTextStyle.bodyFont,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontFamily: AppTextStyle.bodyFont),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!val.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your email address',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: AppColors.textTertiary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _themeBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Create Account Button (Blue Theme)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isAuthLoading ? null : _handleRegister,
                              child: isAuthLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Text(
                                'Create Account',
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: TextStyle(
                                    fontFamily: AppTextStyle.bodyFont,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Toggle to Login (Blue Theme)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                _formKey.currentState?.reset();
                                setState(() => _isRegisterMode = false);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: TextStyle(
                                      fontFamily: AppTextStyle.bodyFont,
                                      fontSize: 13.5,
                                      color: _themeBlue,
                                    ),
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Login Mode: Email Address only
                          RichText(
                            text: TextSpan(
                              text: 'Email Address ',
                              style: GoogleFonts.plusJakartaSans(
                                textStyle: TextStyle(
                                  fontFamily: AppTextStyle.bodyFont,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontFamily: AppTextStyle.bodyFont),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!val.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter your email address',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: AppColors.textTertiary,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.inputBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _themeBlue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login with Email Button (Blue Theme)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isAuthLoading ? null : _handleLogin,
                              child: isAuthLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Text(
                                'Login with Email',
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: TextStyle(
                                    fontFamily: AppTextStyle.bodyFont,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Toggle to Register (Blue Theme)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                _formKey.currentState?.reset();
                                setState(() => _isRegisterMode = true);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    textStyle: TextStyle(
                                      fontFamily: AppTextStyle.bodyFont,
                                      fontSize: 13.5,
                                      color: _themeBlue,
                                    ),
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
