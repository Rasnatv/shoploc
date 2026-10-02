//
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import '../core/appcolors.dart';
// import '../core/appimages.dart';
// import '../core/responsive.dart';
// import 'main_shell.dart';
//
// /// Onboarding: sky area on top (logo) + photo below + headline and button.
// class OnboardingPage extends StatelessWidget {
//   const OnboardingPage({super.key});
//
//   /// How much of the screen height the photo covers (from the bottom).
//   /// 0.78 = photo starts at 22% from the top, leaving room for the logo.
//   /// Smaller number  -> woman moves DOWN (more space for logo)
//   /// Bigger number   -> woman moves UP
//   static const double photoHeightFactor = 0.78;
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final logoWidth = math.min(Responsive.width(context) * 0.58, 280.0);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF3D6),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // 1. SKY BACKGROUND (fills the top area behind the logo)
//           const DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFBFE3F5), // light blue
//                   Color(0xFFEAF5F8),
//                   Color(0xFFFFF3D6), // warm cream near the horizon
//                 ],
//               ),
//             ),
//           ),
//
//           // 2. PHOTO – placed at the bottom, fades into the sky at the top
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             height: size.height * photoHeightFactor,
//             child: ShaderMask(
//               blendMode: BlendMode.dstIn,
//               shaderCallback: (rect) => const LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 stops: [0.0, 0.22],
//                 colors: [Colors.transparent, Colors.black],
//               ).createShader(rect),
//               child: Image.asset(
//                 AppAssets.splashBg,
//                 fit: BoxFit.cover,
//                 alignment: Alignment.topCenter,
//                 errorBuilder: (context, error, stack) {
//                   debugPrint('BACKGROUND IMAGE ERROR: $error');
//                   return ColoredBox(
//                     color: const Color(0xFF3F5A38),
//                     child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Text(
//                           'Image not loaded\n\n${AppAssets.splashBg}\n\n$error',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                               color: Colors.white70, fontSize: 11),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // 3. Soft dark fade at the bottom only (so white text is readable)
//           DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 stops: const [0.0, 0.55, 0.78, 1.0],
//                 colors: [
//                   Colors.transparent,
//                   Colors.transparent,
//                   Colors.black.withAlpha(90),
//                   Colors.black.withAlpha(185),
//                 ],
//               ),
//             ),
//           ),
//
//           // 4. Content
//           SafeArea(
//             child: ResponsiveCenter(
//               maxWidth: 520,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: Column(children: [
//                         const SizedBox(height: 16),
//                         Image.asset(
//                           AppAssets.logo,
//                           width: logoWidth,
//                           fit: BoxFit.contain,
//                           errorBuilder: (_, __, ___) => const Text('ShopLoc',
//                               style: TextStyle(
//                                   fontSize: 44,
//                                   fontWeight: FontWeight.w800,
//                                   color: Color(0xFF0B7FC4))),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Local Fashion  •  Real People  •  Your Style',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               color: Color(0xFF3A3A3A),
//                               fontSize: 13,
//                               letterSpacing: .3),
//                         ),
//                       ]),
//                     ),
//                     const Spacer(),
//                     Text('Trendy Styles\nfrom Local Sellers',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: Responsive.sp(context, 30),
//                             fontWeight: FontWeight.w500,
//                             height: 1.25,
//                             shadows: const [
//                               Shadow(blurRadius: 8, color: Colors.black38)
//                             ])),
//                     const SizedBox(height: 16),
//                     const Row(children: [
//                       Icon(Icons.location_on, color: Colors.white, size: 22),
//                       SizedBox(width: 10),
//                       Text('Kasaragod & Nearby',
//                           style:
//                           TextStyle(color: Colors.white, fontSize: 15)),
//                     ]),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () => Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const MainShell())),
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.cream,
//                             foregroundColor: AppColors.dark,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30))),
//                         child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text('Get Started',
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600)),
//                               SizedBox(width: 10),
//                               Icon(Icons.arrow_forward, size: 20),
//                             ]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import 'main_shell.dart';

/// Onboarding: ShopLoc logo + tagline + illustration + dots + button.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const Color _bg = Color(0xFFFCFCFA);
  static const Color _blue = Color(0xFF2F7BE8);
  static const Color _orange = Color(0xFFFFA24C);
  static const Color _lightBlue = Color(0xFFD6E8FB);
  static const Color _navy = Color(0xFF2C3A55);

  @override
  Widget build(BuildContext context) {
    final logoWidth = math.min(Responsive.width(context) * 0.62, 300.0);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Corner blobs
          Positioned(
            top: -50,
            left: -60,
            child: _blob(180, 160, _orange,
                const BorderRadius.only(
                    bottomRight: Radius.circular(90),
                    bottomLeft: Radius.circular(10))),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: _blob(200, 180, _lightBlue,
                const BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(10))),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: _blob(210, 180, _orange,
                const BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(10))),
          ),

          // 2. Content
          SafeArea(
            child: ResponsiveCenter(
              maxWidth: 520,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Image.asset(
                      AppAssets.logo,
                      width: logoWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('ShopLoc',
                          style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B7FC4))),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Shop Local',
                            style: TextStyle(
                                fontSize: 17, color: _navy, letterSpacing: .3)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('•',
                              style: TextStyle(fontSize: 17, color: _navy)),
                        ),
                        Text('Choose Better',
                            style: TextStyle(
                                fontSize: 17, color: _navy, letterSpacing: .3)),
                      ],
                    ),

                    // Illustration (phone with dress images, bags, cart)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Image.asset(
                          AppAssets.onboarding,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) {
                            debugPrint('ILLUSTRATION ERROR: $error');
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),


                    const SizedBox(height: 20),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MainShell())),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Get Started',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, size: 20),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _blob(double w, double h, Color c, BorderRadius r) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: c, borderRadius: r),
      );
}