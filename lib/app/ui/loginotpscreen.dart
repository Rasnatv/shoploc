import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/authbloc/auth_event.dart';
import '../bloc/authbloc/auth_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/custom_button.dart';
import '../widgets/shoploc_logo.dart';
import 'main_bottom_nav_screen.dart';

class LoginOtpScreen extends StatefulWidget {
  final String destination;
  final String? userName;
  final String verificationType;

  const LoginOtpScreen({
    super.key,
    required this.destination,
    this.userName,
    this.verificationType = 'register',
  });

  @override
  State<LoginOtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<LoginOtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verifyOtp() {
    final code = _otp;
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter any 4-digit verification code (e.g. 1234)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        otp: code,
        contextType: widget.verificationType,
        userName: widget.userName,
        email: widget.destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verified successfully! Welcome, ${state.user.name}!'),
                backgroundColor: AppColors.brandBlue,
                duration: const Duration(seconds: 2),
              ),
            );
            // Navigate directly to Dashboard (MainBottomNavScreen)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainBottomNavScreen(initialIndex: 0),
              ),
                  (route) => false,
            );
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: ShoplocLogo(fontSize: 24, showTagline: false),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Verification Code',
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
                  const SizedBox(height: 8),

                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      children: [
                        const TextSpan(text: 'We have sent a 4-digit verification code to '),
                        TextSpan(
                          text: widget.destination,
                          style: const TextStyle(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Easy verification hint box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.brandBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Quick verification: enter any 4 digits (e.g. 1234) to proceed.',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 12.5,
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4 OTP Input Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 58,
                        height: 58,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autofocus: index == 0,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.brandBlue, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (_otp.length == 4) {
                              _verifyOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Verify CTA Button
                  CustomButton(
                    text: 'Verify & Go to Dashboard',
                    isLoading: isLoading,
                    backgroundColor: AppColors.brandBlue,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 24),

                  // Resend Countdown
                  Center(
                    child: _resendCountdown > 0
                        ? Text(
                      'Resend code in ${_resendCountdown}s',
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                        : TextButton(
                      onPressed: () {
                        _startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('A fresh code was sent (Use demo code: 1234)'),
                            backgroundColor: AppColors.brandBlue,
                          ),
                        );
                      },
                      child: Text(
                        'Resend Code',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
