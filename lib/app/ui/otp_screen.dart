// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../bloc/authbloc/auth_bloc.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String userName;
//   final String destination; // email
//   final String verificationType; // 'register' | 'login'
//
//   const OtpScreen({
//     super.key,
//     required this.userName,
//     required this.destination,
//     required this.verificationType,
//   });
//
//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   final _otpController = TextEditingController();
//   Timer? _timer;
//   int _secondsLeft = 60;
//
//   bool get _isRegister => widget.verificationType == 'register';
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//     setState(() => _secondsLeft = 60);
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (!mounted) {
//         t.cancel();
//         return;
//       }
//       if (_secondsLeft <= 1) t.cancel();
//       setState(() => _secondsLeft--);
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   void _verify() {
//     final otp = _otpController.text.trim();
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the 6 digit OTP')),
//       );
//       return;
//     }
//     context.read<AuthBloc>().add(VerifyOtpRequested(
//       email: widget.destination,
//       otp: otp,
//       isRegister: _isRegister,
//     ));
//   }
//
//   void _resend() {
//     if (_secondsLeft > 0) return;
//     context.read<AuthBloc>().add(ResendOtpRequested());
//     _startTimer();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: AppColors.textPrimary),
//       ),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthenticatedState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     'Welcome, ${state.user.name}! Your account is verified.'),
//                 backgroundColor: AppColors.brandBlue,
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//             context.pop(true); // CheckoutAuthScreen handles the next navigation
//           } else if (state is OtpSentState && state.isResend) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: AppColors.brandBlue,
//               ),
//             );
//           } else if (state is AuthErrorState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.errorMessage),
//                 backgroundColor: AppColors.error,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final loading = state is AuthLoadingState;
//
//           return SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Verify your email',
//                     style: GoogleFonts.playfairDisplay(
//                       textStyle: TextStyle(
//                         fontFamily: AppTextStyle.headingFont,
//                         fontSize: 26,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'We sent a 6 digit code to\n${widget.destination}',
//                     style: GoogleFonts.plusJakartaSans(
//                       textStyle: TextStyle(
//                         fontFamily: AppTextStyle.bodyFont,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 28),
//                   TextField(
//                     controller: _otpController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 6,
//                     textAlign: TextAlign.center,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 12,
//                     ),
//                     onChanged: (v) {
//                       if (v.length == 6 && !loading) _verify();
//                     },
//                     decoration: InputDecoration(
//                       counterText: '',
//                       hintText: '------',
//                       filled: true,
//                       fillColor: AppColors.inputBackground,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: AppColors.border),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(
//                             color: AppColors.brandBlue, width: 1.5),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.brandBlue,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       onPressed: loading ? null : _verify,
//                       child: loading
//                           ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                           AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                           : Text(
//                         'Verify & Continue',
//                         style: GoogleFonts.plusJakartaSans(
//                           textStyle: const TextStyle(
//                             fontSize: 15.5,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   Center(
//                     child: _secondsLeft > 0
//                         ? Text(
//                       'Resend OTP in ${_secondsLeft}s',
//                       style: TextStyle(
//                         fontFamily: AppTextStyle.bodyFont,
//                         color: AppColors.textSecondary,
//                       ),
//                     )
//                         : GestureDetector(
//                       onTap: loading ? null : _resend,
//                       child: Text(
//                         'Resend OTP',
//                         style: TextStyle(
//                           fontFamily: AppTextStyle.bodyFont,
//                           color: AppColors.brandBlue,
//                           fontWeight: FontWeight.bold,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoploc/app/core/theme/app_colors.dart';
import 'package:shoploc/app/core/theme/app_text_style.dart';
import 'package:shoploc/app/widgets/appsnackbar.dart';
import 'package:shoploc/app/widgets/responsive.dart';
import 'package:shoploc/app/widgets/shoploc_logo.dart';

import '../bloc/authbloc/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String userName;
  final String destination; // email
  final String verificationType; // 'register' | 'login'

  const OtpScreen({
    super.key,
    required this.userName,
    required this.destination,
    required this.verificationType,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;
  static const Color _themeBlue = AppColors.brandBlue;

  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _secondsLeft = 60;

  bool get _isRegister => widget.verificationType == 'register';

  @override
  void initState() {
    super.initState();
    _startTimer();
    _otpController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    if (mounted) setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();
    if (otp.length != _otpLength) {
      AppSnackbar.error('Please enter the 6 digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(VerifyOtpRequested(
      email: widget.destination,
      otp: otp,
      isRegister: _isRegister,
    ));
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _otpController.clear();
    context.read<AuthBloc>().add(ResendOtpRequested());
    _startTimer();
  }

  // ---------- UI helpers ----------
  Widget _backButton() {
    return Padding(
      padding: EdgeInsets.only(left: Responsive.sp(16), top: Responsive.sp(8)),
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
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: Responsive.sp(16)),
        ),
      ),
    );
  }

  Widget _otpBoxes() {
    final text = _otpController.text;
    final activeIndex = text.length.clamp(0, _otpLength - 1);
    final hasFocus = _focusNode.hasFocus;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (i) {
              final filled = i < text.length;
              final isActive = hasFocus && i == activeIndex;
              return Container(
                width: Responsive.sp(42),
                height: Responsive.sp(52),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? _themeBlue
                        : (filled ? _themeBlue.withOpacity(0.5) : AppColors.border),
                    width: isActive ? 1.8 : 1,
                  ),
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontSize: Responsive.sp(22),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
          // Invisible field that actually captures the input / autofill.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _otpController,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: _otpLength,
                autofillHints: const [AutofillHints.oneTimeCode],
                enableInteractiveSelection: false,
                showCursor: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  final loading = context.read<AuthBloc>().state is AuthLoadingState;
                  if (v.length == _otpLength && !loading) _verify();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _resendRow(bool loading) {
    final base = GoogleFonts.plusJakartaSans(
      textStyle: TextStyle(
        fontFamily: AppTextStyle.bodyFont,
        fontSize: Responsive.sp(13.5),
        color: AppColors.textSecondary,
      ),
    );

    return Center(
      child: _secondsLeft > 0
          ? RichText(
        text: TextSpan(
          text: 'Resend code in ',
          style: base,
          children: [
            TextSpan(
              text: '00:${_secondsLeft.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: _themeBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      )
          : GestureDetector(
        onTap: loading ? null : _resend,
        child: RichText(
          text: TextSpan(
            text: "Didn't get the code? ",
            style: base,
            children: const [
              TextSpan(
                text: 'Resend',
                style: TextStyle(
                  color: _themeBlue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: Responsive.sp(60),
        leading: _backButton(),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => ModalRoute.of(context)?.isCurrent ?? false,
        listener: (context, state) {
          if (state is AuthenticatedState) {
            AppSnackbar.success(
                'Welcome, ${state.user.name}! Your account is verified.');
            context.pop(true); // CheckoutAuthScreen handles the next navigation
          } else if (state is OtpSentState && state.isResend) {
            AppSnackbar.success(state.message);
          } else if (state is AuthErrorState) {
            AppSnackbar.error(state.errorMessage);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoadingState;

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ShoplocLogo(
                            fontSize: Responsive.sp(22), showTagline: false),
                      ),
                      SizedBox(height: Responsive.sp(20)),
                      Center(
                        child: Container(
                          width: Responsive.sp(60),
                          height: Responsive.sp(60),
                          decoration: BoxDecoration(
                            color: _themeBlue.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mark_email_read_outlined,
                              color: _themeBlue, size: Responsive.sp(28)),
                        ),
                      ),
                      SizedBox(height: Responsive.sp(18)),
                      Text(
                        'VERIFICATION',
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
                        'Verify your email',
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
                      SizedBox(height: Responsive.sp(6)),
                      RichText(
                        text: TextSpan(
                          text: 'We sent a 6 digit code to\n',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontFamily: AppTextStyle.bodyFont,
                              fontSize: Responsive.sp(13.5),
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          children: [
                            TextSpan(
                              text: widget.destination,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.sp(24)),
                      _otpBoxes(),
                      SizedBox(height: Responsive.sp(24)),
                      _primaryButton('Verify & Continue', loading, _verify),
                      SizedBox(height: Responsive.sp(18)),
                      _resendRow(loading),
                      SizedBox(height: Responsive.sp(10)),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pop(false),
                          child: Text(
                            'Change email',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: Responsive.sp(13),
                                fontWeight: FontWeight.w600,
                                color: _themeBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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