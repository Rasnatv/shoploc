import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/authbloc/auth_state.dart';
import '../core/storage/local_storage_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/shoploc_logo.dart';
import 'main_bottom_nav_screen.dart';
import 'otp_screen.dart';

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

  Future<void> _loadInitialReferralCode() async {
    final storage = await LocalStorageService.getInstance();
    final code = storage.getReferralCode();
    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        _referralController.text = code;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final referralCode = _referralController.text.trim();

      if (referralCode.isNotEmpty) {
        final storage = await LocalStorageService.getInstance();
        await storage.saveReferralCode(referralCode);
        debugPrint(
          '[CheckoutAuth] User entered referral code: $referralCode (Saved to LocalStorageService)',
        );
      }

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
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
          builder: (_) => OtpScreen(
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
    return PopScope(
      canPop: !widget.isFromOnboarding,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.isFromOnboarding) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainBottomNavScreen(initialIndex: 0),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            if (widget.isFromOnboarding)
              // Flipkart-style prominent "Skip >" action button
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 10, bottom: 6),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainBottomNavScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
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
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: _themeBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
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
              if (widget.isFromOnboarding) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainBottomNavScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pop(true);
              }
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
                          const SizedBox(height: 16),

                          // Referral Code (Optional) - Pre-filled from Google Play or entered manually
                          RichText(
                            text: TextSpan(
                              text: 'Referral Code ',
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
                                  text: '(Optional)',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _referralController,
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(
                              fontFamily: AppTextStyle.bodyFont,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter referral or salesman code (e.g. STAFF001)',
                              hintStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                color: AppColors.textTertiary,
                                fontSize: 13,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                              ),
                              prefixIcon: const Icon(
                                Icons.card_giftcard_outlined,
                                color: _themeBlue,
                                size: 20,
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
                                _loadInitialReferralCode();
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
    ),
  );
}
}


//
//
//
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import '../services/referral_service.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _name = TextEditingController();
//   final _phone = TextEditingController();
//   final _password = TextEditingController();
//   final _referral = TextEditingController();
//
//   bool _autoFilled = false; // link വഴി വന്ന കോഡ് ആണോ
//   bool _loading = false;
//
//   final _dio = Dio(BaseOptions(baseUrl: 'https://shoploc.in')); // നിങ്ങളുടെ URL
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCode();
//   }
//
//   Future<void> _loadSavedCode() async {
//     final code = await ReferralService.getSavedCode();
//     if (code != null && code.isNotEmpty) {
//       setState(() {
//         _referral.text = code;
//         _autoFilled = true;
//       });
//     }
//   }
//
//   Future<void> _register() async {
//     setState(() => _loading = true);
//
//     final body = <String, dynamic>{
//       'name': _name.text.trim(),
//       'phone': _phone.text.trim(),
//       'password': _password.text,
//     };
//
//     // കോഡ് ഉണ്ടെങ്കിൽ മാത്രം ചേർക്കുക
//     final code = _referral.text.trim();
//     if (code.isNotEmpty) {
//       body['referral_code'] = code;
//     }
//
//     try {
//       final res = await _dio.post('/api/register', data: body);
//
//       if (res.data['success'] == true) {
//         await ReferralService.clear(); // ഇനി ലോക്കൽ കോഡ് വേണ്ട
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registered successfully')),
//         );
//         // TODO: home screen-ലേക്ക് പോകുക
//       }
//     } on DioException catch (e) {
//       final msg = e.response?.data?['message'] ?? 'Something went wrong';
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             TextField(
//               controller: _name,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: _phone,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'Phone'),
//             ),
//             TextField(
//               controller: _password,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: 'Password'),
//             ),
//             TextField(
//               controller: _referral,
//               readOnly: _autoFilled, // link വഴി വന്നെങ്കിൽ ലോക്ക്
//               decoration: InputDecoration(
//                 labelText: 'Referral code (optional)',
//                 suffixIcon: _autoFilled
//                     ? const Icon(Icons.check_circle, color: Colors.green)
//                     : null,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _loading ? null : _register,
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : const Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }