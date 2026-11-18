import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoploc/app/ui/main_bottom_nav_screen.dart';


import '../ui/checkout_auth_screen.dart';
import '../ui/onboarding_screen.dart';
import '../ui/otp_screen.dart';
import '../ui/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Register / Login
      // context.push<bool>('/auth', extra: {'isRegister': true, 'fromOnboarding': false});
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final extra = (state.extra as Map<String, dynamic>?) ?? {};
          return CheckoutAuthScreen(
            initialIsRegister: extra['isRegister'] ?? true,
            isFromOnboarding: extra['fromOnboarding'] ?? false,
          );
        },
      ),

      // OTP
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final e = (state.extra as Map<String, dynamic>?) ?? {};
          return OtpScreen(
            userName: (e['name'] ?? '').toString(),
            destination: (e['email'] ?? '').toString(),
            verificationType: (e['type'] ?? 'register').toString(),
          );
        },
      ),

      // Home
      GoRoute(
        path: '/home',
        builder: (context, state) =>
        const MainBottomNavScreen(initialIndex: 0),
      ),
    ],
  );
}