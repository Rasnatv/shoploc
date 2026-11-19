// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shoploc/app/ui/main_bottom_nav_screen.dart';
// import '../ui/checkout_auth_screen.dart';
// import '../ui/onboarding_screen.dart';
// import '../ui/otp_screen.dart';
// import '../ui/splash_screen.dart';
//
// class AppRouter {
//   AppRouter._();
//
//   static final GlobalKey<NavigatorState> navigatorKey =
//   GlobalKey<NavigatorState>();
//
//   static final GoRouter router = GoRouter(
//     navigatorKey: navigatorKey,
//     initialLocation: '/',
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: '/onboarding',
//         builder: (context, state) => const OnboardingScreen(),
//       ),
//
//       // Register / Login
//       // context.push<bool>('/auth', extra: {'isRegister': true, 'fromOnboarding': false});
//       GoRoute(
//         path: '/auth',
//         builder: (context, state) {
//           final extra = (state.extra as Map<String, dynamic>?) ?? {};
//           return CheckoutAuthScreen(
//             initialIsRegister: extra['isRegister'] ?? true,
//             isFromOnboarding: extra['fromOnboarding'] ?? false,
//           );
//         },
//       ),
//
//       // OTP
//       GoRoute(
//         path: '/otp',
//         builder: (context, state) {
//           final e = (state.extra as Map<String, dynamic>?) ?? {};
//           return OtpScreen(
//             userName: (e['name'] ?? '').toString(),
//             destination: (e['email'] ?? '').toString(),
//             verificationType: (e['type'] ?? 'register').toString(),
//           );
//         },
//       ),
//
//       // Home
//       GoRoute(
//         path: '/home',
//         builder: (context, state) =>
//         const MainBottomNavScreen(initialIndex: 0),
//       ),
//     ],
//   );
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shoploc/app/ui/main_bottom_nav_screen.dart';

import '../bloc/addressbloc/address_bloc.dart';
import '../data/models/addressmodel.dart';
import '../ui/add_edit_address_screen.dart';
import '../ui/address_list_screen.dart';
import '../ui/checkout_auth_screen.dart';
import '../ui/onboarding_screen.dart';
import '../ui/otp_screen.dart';
import '../ui/splash_screen.dart';

class AppRouter {
  AppRouter._();

  // ---------------- route paths ----------------
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String otp = '/otp';
  static const String home = '/home';

  /// Saved addresses.
  /// context.push<bool>(AppRouter.addresses, extra: {'selectMode': true});
  static const String addresses = '/addresses';

  /// Add a new address.
  /// context.push<bool>(AppRouter.addressAdd);
  static const String addressAdd = '/address/add';

  /// Edit an address.
  /// context.push<bool>(AppRouter.addressEdit, extra: {'address': addressModel});
  static const String addressEdit = '/address/edit';

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  /// `extra` can optionally carry an `AddressBloc` under the key 'bloc'
  /// (use it only when the bloc is NOT provided above the app).
  static Widget _withAddressBloc(Map<String, dynamic> extra, Widget screen) {
    final bloc = extra['bloc'];
    return bloc is AddressBloc
        ? BlocProvider<AddressBloc>.value(value: bloc, child: screen)
        : screen;
  }

  static Map<String, dynamic> _extra(GoRouterState state) {
    final e = state.extra;
    if (e is Map<String, dynamic>) return e;
    if (e is AddressModel) return {'address': e}; // also accept the model directly
    return const {};
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Register / Login
      // context.push<bool>('/auth', extra: {'isRegister': true, 'fromOnboarding': false});
      GoRoute(
        path: auth,
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
        path: otp,
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
        path: home,
        builder: (context, state) =>
        const MainBottomNavScreen(initialIndex: 0),
      ),

      // ---------------- Addresses ----------------
      GoRoute(
        path: addresses,
        builder: (context, state) {
          final extra = _extra(state);
          return _withAddressBloc(
            extra,
            AddressListScreen(selectMode: extra['selectMode'] == true),
          );
        },
      ),
      GoRoute(
        path: addressAdd,
        builder: (context, state) =>
            _withAddressBloc(_extra(state), const AddEditAddressScreen()),
      ),
      GoRoute(
        path: addressEdit,
        builder: (context, state) {
          final extra = _extra(state);
          return _withAddressBloc(
            extra,
            AddEditAddressScreen(address: extra['address'] as AddressModel?),
          );
        },
      ),
    ],
  );
}