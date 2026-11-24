// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../bloc/addressbloc/address_bloc.dart';
// import '../core/utils/productlisttype.dart';
// import '../data/models/addressmodel.dart';
// import '../data/models/homemodel.dart';
// import '../ui/add_edit_address_screen.dart';
// import '../ui/address_list_screen.dart';
// import '../ui/bestsellerscreen.dart';
// import '../ui/cancellation_policy_screen.dart';
// import '../ui/categories_screen.dart';
// import '../ui/checkout_auth_screen.dart';
// import '../ui/checkout_screen.dart';
// import '../ui/confirmorder.dart';
// import '../ui/enquiry_screen.dart';
// import '../ui/faq_screen.dart';
// import '../ui/main_bottom_nav_screen.dart';
// import '../ui/newarrivalscreen.dart';
// import '../ui/onboarding_screen.dart';
// import '../ui/orders_screen.dart';
// import '../ui/otp_screen.dart';
// import '../ui/privacy_policy_screen.dart';
// import '../ui/product_details_screen.dart';
// import '../ui/recentviewscreen.dart';
// import '../ui/refund_policy_screen.dart';
// import '../ui/searchscreen.dart';
// import '../ui/splash_screen.dart';
// import '../ui/static_pages.dart';
// import '../ui/subcategory_productscreen.dart';
// import '../ui/termsandcondition.dart';
// import '../ui/trendingscreen.dart';
// import '../ui/wishlist_screen.dart';
//
// /// Central go_router configuration.
// ///
// /// Every screen of the app is registered here. Pages should navigate with
// /// these constants/helpers instead of `Navigator.push(MaterialPageRoute(...))`:
// ///
// /// ```dart
// /// context.push(AppRouter.productPath(12));
// /// context.push(AppRouter.checkout);
// /// context.go(AppRouter.homeTab(AppRouter.tabCart));
// /// ```
// class AppRouter {
//   AppRouter._();
//
//   // ===================== route paths =====================
//
//   // --- start-up / auth ---
//   static const String splash = '/';
//   static const String onboarding = '/onboarding';
//
//   /// context.push<bool>(AppRouter.auth, extra: {'isRegister': true, 'fromOnboarding': false});
//   static const String auth = '/auth';
//
//   /// context.push<bool>(AppRouter.otp, extra: {'name': .., 'email': .., 'type': 'register'|'login'});
//   static const String otp = '/otp';
//
//   // --- main shell (bottom navigation) ---
//   /// `/home?tab=0..4`  (see the tab* constants below)
//   static const String home = '/home';
//   static const String cart = '/cart'; // redirects to the Cart tab
//
//   static const int tabHome = 0;
//   static const int tabCategories = 1;
//   static const int tabWishlist = 2;
//   static const int tabCart = 3;
//   static const int tabProfile = 4;
//
//   // --- shopping ---
//   /// context.push(AppRouter.categories, extra: {'category': categoryApiModel});
//   static const String categories = '/categories';
//
//   /// context.push(AppRouter.subCategoryProducts,
//   ///     extra: {'subCategory': sub, 'parentName': parent.name});
//   static const String subCategoryProducts = '/category/products';
//
//   /// context.push(AppRouter.productPath(id));
//   static const String product = '/product/:id';
//
//   /// context.push(AppRouter.search);   (optional: extra: {'query': 'olive'})
//   static const String search = '/search';
//
//   static const String wishlist = '/wishlist';
//   static const String newArrivals = '/new-arrivals';
//   static const String trending = '/trending';
//   static const String bestSellers = '/best-sellers';
//   static const String recentViews = '/recent-views';
//
//   // --- checkout & addresses ---
//   static const String checkout = '/checkout';
//
//   /// "Buy Now" -> Confirm Order (address + product + price details).
//   /// context.push(AppRouter.buyNow, extra: BuyNowArgs(...));
//   static const String buyNow = '/buy-now';
//
//   /// context.push<bool>(AppRouter.addresses, extra: {'selectMode': true});
//   static const String addresses = '/addresses';
//
//   /// context.push<bool>(AppRouter.addressAdd);
//   static const String addressAdd = '/address/add';
//
//   /// context.push<bool>(AppRouter.addressEdit, extra: {'address': addressModel});
//   static const String addressEdit = '/address/edit';
//
//   // --- info / support pages ---
//   static const String faq = '/faq';
//   static const String enquiry = '/enquiry';
//   static const String refundPolicy = '/refund-policy';
//   static const String cancellationPolicy = '/cancellation-policy';
//   static const String privacyPolicy = '/privacy-policy';
//   static const String terms = '/terms';
//   static const String about = '/about';
//   static const String orders = '/orders';
//
//   // ===================== helpers =====================
//
//   static final GlobalKey<NavigatorState> navigatorKey =
//   GlobalKey<NavigatorState>();
//
//   static String productPath(int id) => '/product/$id';
//
//   static String homeTab(int index) => '$home?tab=$index';
//
//   /// Full "See all" list page for a [ProductListType].
//   static String listPath(ProductListType type) {
//     switch (type) {
//       case ProductListType.newArrivals:
//         return newArrivals;
//       case ProductListType.trending:
//         return trending;
//       case ProductListType.bestSellers:
//         return bestSellers;
//       case ProductListType.recentViews:
//         return recentViews;
//     }
//   }
//
//   /// Safe "back": pops if possible, otherwise goes Home
//   /// (e.g. after a cold start on a deep link).
//   static void back(BuildContext context, [Object? result]) {
//     if (context.canPop()) {
//       context.pop(result);
//     } else {
//       context.go(home);
//     }
//   }
//
//   // ===================== extra helpers =====================
//
//   /// `extra` can optionally carry an `AddressBloc` under the key 'bloc'
//   /// (use it only when the bloc is NOT provided above the app).
//   static Widget _withAddressBloc(Map<String, dynamic> extra, Widget screen) {
//     final bloc = extra['bloc'];
//     return bloc is AddressBloc
//         ? BlocProvider<AddressBloc>.value(value: bloc, child: screen)
//         : screen;
//   }
//
//   static Map<String, dynamic> _extra(GoRouterState state) {
//     final e = state.extra;
//     if (e is Map<String, dynamic>) return e;
//     if (e is AddressModel) return {'address': e}; // accept the model directly
//     if (e is CategoryApiModel) return {'category': e};
//     return const {};
//   }
//
//   // ===================== router =====================
//
//   static final GoRouter router = GoRouter(
//     navigatorKey: navigatorKey,
//     initialLocation: splash,
//     errorBuilder: (context, state) =>
//     const _NotFoundScreen(message: 'This page could not be found.'),
//     routes: [
//       // ---------------- start-up ----------------
//       GoRoute(
//         path: splash,
//         builder: (context, state) => const SplashScreen(),
//       ),
//       GoRoute(
//         path: onboarding,
//         builder: (context, state) => const OnboardingScreen(),
//       ),
//
//       // ---------------- auth ----------------
//       GoRoute(
//         path: auth,
//         builder: (context, state) {
//           final extra = _extra(state);
//           return CheckoutAuthScreen(
//             initialIsRegister: extra['isRegister'] ?? true,
//             isFromOnboarding: extra['fromOnboarding'] ?? false,
//           );
//         },
//       ),
//       GoRoute(
//         path: otp,
//         builder: (context, state) {
//           final e = _extra(state);
//           return OtpScreen(
//             userName: (e['name'] ?? '').toString(),
//             destination: (e['email'] ?? '').toString(),
//             verificationType: (e['type'] ?? 'register').toString(),
//           );
//         },
//       ),
//
//       // ---------------- main shell ----------------
//       GoRoute(
//         path: home,
//         builder: (context, state) {
//           final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
//           return MainBottomNavScreen(initialIndex: tab.clamp(0, 4).toInt());
//         },
//       ),
//       GoRoute(
//         path: cart,
//         redirect: (context, state) => homeTab(tabCart),
//       ),
//
//       // ---------------- shopping ----------------
//       GoRoute(
//         path: categories,
//         builder: (context, state) => CategoriesScreen(
//           initialCategory: _extra(state)['category'] as CategoryApiModel?,
//         ),
//       ),
//       GoRoute(
//         path: subCategoryProducts,
//         builder: (context, state) {
//           final extra = _extra(state);
//           final sub = extra['subCategory'];
//           if (sub is! CategoryApiModel) {
//             return const _NotFoundScreen(message: 'Category not found.');
//           }
//           return SubCategoryProductsScreen(
//             subCategory: sub,
//             parentName: extra['parentName'] as String?,
//           );
//         },
//       ),
//       GoRoute(
//         path: product,
//         builder: (context, state) {
//           final id = int.tryParse(state.pathParameters['id'] ?? '');
//           if (id == null) {
//             return const _NotFoundScreen(message: 'Product not found.');
//           }
//           return ProductDetailsScreen(productId: id);
//         },
//       ),
//       GoRoute(
//         path: search,
//         builder: (context, state) => SearchScreen(
//           initialQuery: (_extra(state)['query'] ?? '').toString(),
//         ),
//       ),
//       GoRoute(
//         path: wishlist,
//         builder: (context, state) =>
//             WishlistScreen(onGoShopping: () => context.go(home)),
//       ),
//       GoRoute(
//         path: newArrivals,
//         builder: (context, state) => const NewArrivalsScreen(),
//       ),
//       GoRoute(
//         path: trending,
//         builder: (context, state) => const TrendingScreen(),
//       ),
//       GoRoute(
//         path: bestSellers,
//         builder: (context, state) => const BestSellersScreen(),
//       ),
//       GoRoute(
//         path: recentViews,
//         builder: (context, state) => const RecentViewsScreen(),
//       ),
//
//       // ---------------- checkout ----------------
//       GoRoute(
//         path: checkout,
//         builder: (context, state) => const CheckoutScreen(),
//       ),
//
//       GoRoute(
//         path: buyNow,
//         builder: (context, state) {
//           final args = state.extra;
//           if (args is! BuyNowArgs) {
//             return const _NotFoundScreen(message: 'No product selected.');
//           }
//           return ConfirmOrderScreen(args: args);
//         },
//       ),
//
//       // ---------------- addresses ----------------
//       GoRoute(
//         path: addresses,
//         builder: (context, state) {
//           final extra = _extra(state);
//           return _withAddressBloc(
//             extra,
//             AddressListScreen(selectMode: extra['selectMode'] == true),
//           );
//         },
//       ),
//       GoRoute(
//         path: addressAdd,
//         builder: (context, state) =>
//             _withAddressBloc(_extra(state), const AddEditAddressScreen()),
//       ),
//       GoRoute(
//         path: addressEdit,
//         builder: (context, state) {
//           final extra = _extra(state);
//           return _withAddressBloc(
//             extra,
//             AddEditAddressScreen(address: extra['address'] as AddressModel?),
//           );
//         },
//       ),
//
//       // ---------------- info / support ----------------
//       GoRoute(path: faq, builder: (context, state) => const FaqScreen()),
//       GoRoute(
//         path: enquiry,
//         builder: (context, state) => const EnquiryScreen(),
//       ),
//       GoRoute(
//         path: refundPolicy,
//         builder: (context, state) => const RefundPolicyScreen(),
//       ),
//       GoRoute(
//         path: cancellationPolicy,
//         builder: (context, state) => const CancellationPolicyScreen(),
//       ),
//       GoRoute(
//         path: privacyPolicy,
//         builder: (context, state) => const PrivacyPolicyScreen(),
//       ),
//       GoRoute(
//         path: terms,
//         builder: (context, state) => const TermsConditionsScreen(),
//       ),
//       GoRoute(
//         path: about,
//         builder: (context, state) => const AboutUsScreen(),
//       ),
//       GoRoute(
//         path: orders,
//         builder: (context, state) => const OrdersScreen(),
//       ),
//     ],
//   );
// }
//
// /// Shown for unknown URLs or when a route is opened without the data it needs.
// class _NotFoundScreen extends StatelessWidget {
//   final String message;
//   const _NotFoundScreen({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Oops')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.search_off_rounded, size: 56),
//               const SizedBox(height: 12),
//               Text(message, textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               FilledButton(
//                 onPressed: () => context.go(AppRouter.home),
//                 child: const Text('Go to Home'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/addressbloc/address_bloc.dart';
import '../core/utils/productlisttype.dart';
import '../data/models/addressmodel.dart';
import '../data/models/homemodel.dart';
import '../ui/add_edit_address_screen.dart';
import '../ui/address_list_screen.dart';
import '../ui/bestsellerscreen.dart';
import '../ui/cancellation_policy_screen.dart';
import '../ui/categories_screen.dart';
import '../ui/checkout_auth_screen.dart';
import '../ui/checkout_screen.dart';
import '../ui/confirmorder.dart';
import '../ui/enquiry_screen.dart';
import '../ui/faq_screen.dart';
import '../ui/main_bottom_nav_screen.dart';
import '../ui/newarrivalscreen.dart';
import '../ui/notifications_screen.dart';
import '../ui/onboarding_screen.dart';
import '../ui/orders_screen.dart';
import '../ui/otp_screen.dart';
import '../ui/privacy_policy_screen.dart';
import '../ui/product_details_screen.dart';
import '../ui/recentviewscreen.dart';
import '../ui/refund_policy_screen.dart';
import '../ui/searchscreen.dart';
import '../ui/splash_screen.dart';
import '../ui/static_pages.dart';
import '../ui/subcategory_productscreen.dart';
import '../ui/termsandcondition.dart';
import '../ui/trendingscreen.dart';
import '../ui/wishlist_screen.dart';

/// Central go_router configuration.
///
/// Every screen of the app is registered here. Pages should navigate with
/// these constants/helpers instead of `Navigator.push(MaterialPageRoute(...))`:
///
/// ```dart
/// context.push(AppRouter.productPath(12));
/// context.push(AppRouter.checkout);
/// context.go(AppRouter.homeTab(AppRouter.tabCart));
/// ```
class AppRouter {
  AppRouter._();

  // ===================== route paths =====================

  // --- start-up / auth ---
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  /// context.push<bool>(AppRouter.auth, extra: {'isRegister': true, 'fromOnboarding': false});
  static const String auth = '/auth';

  /// context.push<bool>(AppRouter.otp, extra: {'name': .., 'email': .., 'type': 'register'|'login'});
  static const String otp = '/otp';

  // --- main shell (bottom navigation) ---
  /// `/home?tab=0..4`  (see the tab* constants below)
  static const String home = '/home';
  static const String cart = '/cart'; // redirects to the Cart tab

  static const int tabHome = 0;
  static const int tabCategories = 1;
  static const int tabWishlist = 2;
  static const int tabCart = 3;
  static const int tabProfile = 4;

  // --- shopping ---
  /// context.push(AppRouter.categories, extra: {'category': categoryApiModel});
  static const String categories = '/categories';

  /// context.push(AppRouter.subCategoryProducts,
  ///     extra: {'subCategory': sub, 'parentName': parent.name});
  static const String subCategoryProducts = '/category/products';

  /// context.push(AppRouter.productPath(id));
  static const String product = '/product/:id';

  /// context.push(AppRouter.search);   (optional: extra: {'query': 'olive'})
  static const String search = '/search';

  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String newArrivals = '/new-arrivals';
  static const String trending = '/trending';
  static const String bestSellers = '/best-sellers';
  static const String recentViews = '/recent-views';

  // --- checkout & addresses ---
  static const String checkout = '/checkout';

  /// "Buy Now" -> Confirm Order (address + product + price details).
  /// context.push(AppRouter.buyNow, extra: BuyNowArgs(...));
  static const String buyNow = '/buy-now';

  /// context.push<bool>(AppRouter.addresses, extra: {'selectMode': true});
  static const String addresses = '/addresses';

  /// context.push<bool>(AppRouter.addressAdd);
  static const String addressAdd = '/address/add';

  /// context.push<bool>(AppRouter.addressEdit, extra: {'address': addressModel});
  static const String addressEdit = '/address/edit';

  // --- info / support pages ---
  static const String faq = '/faq';
  static const String enquiry = '/enquiry';
  static const String refundPolicy = '/refund-policy';
  static const String cancellationPolicy = '/cancellation-policy';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String about = '/about';
  static const String notifications = '/notifications';

  // ===================== helpers =====================

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static String productPath(int id) => '/product/$id';

  static String homeTab(int index) => '$home?tab=$index';

  /// Same as [homeTab] but always switches the tab, even when the shell is
  /// already open on that tab number (the extra `t` value is always new).
  static String homeTabFresh(int index) =>
      '$home?tab=$index&t=${DateTime.now().millisecondsSinceEpoch}';

  /// Full "See all" list page for a [ProductListType].
  static String listPath(ProductListType type) {
    switch (type) {
      case ProductListType.newArrivals:
        return newArrivals;
      case ProductListType.trending:
        return trending;
      case ProductListType.bestSellers:
        return bestSellers;
      case ProductListType.recentViews:
        return recentViews;
    }
  }

  /// Safe "back": pops if possible, otherwise goes Home
  /// (e.g. after a cold start on a deep link).
  static void back(BuildContext context, [Object? result]) {
    if (context.canPop()) {
      context.pop(result);
    } else {
      context.go(home);
    }
  }

  // ===================== extra helpers =====================

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
    if (e is AddressModel) return {'address': e}; // accept the model directly
    if (e is CategoryApiModel) return {'category': e};
    return const {};
  }

  // ===================== router =====================

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    errorBuilder: (context, state) =>
    const _NotFoundScreen(message: 'This page could not be found.'),
    routes: [
      // ---------------- start-up ----------------
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ---------------- auth ----------------
      GoRoute(
        path: auth,
        builder: (context, state) {
          final extra = _extra(state);
          return CheckoutAuthScreen(
            initialIsRegister: extra['isRegister'] ?? true,
            isFromOnboarding: extra['fromOnboarding'] ?? false,
          );
        },
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final e = _extra(state);
          return OtpScreen(
            userName: (e['name'] ?? '').toString(),
            destination: (e['email'] ?? '').toString(),
            verificationType: (e['type'] ?? 'register').toString(),
          );
        },
      ),

      // ---------------- main shell ----------------
      GoRoute(
        path: home,
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return MainBottomNavScreen(
            initialIndex: tab.clamp(0, 4).toInt(),
            switchKey: state.uri.queryParameters['t'],
          );
        },
      ),
      GoRoute(
        path: cart,
        redirect: (context, state) => homeTab(tabCart),
      ),

      // ---------------- shopping ----------------
      GoRoute(
        path: categories,
        builder: (context, state) => CategoriesScreen(
          initialCategory: _extra(state)['category'] as CategoryApiModel?,
        ),
      ),
      GoRoute(
        path: subCategoryProducts,
        builder: (context, state) {
          final extra = _extra(state);
          final sub = extra['subCategory'];
          if (sub is! CategoryApiModel) {
            return const _NotFoundScreen(message: 'Category not found.');
          }
          return SubCategoryProductsScreen(
            subCategory: sub,
            parentName: extra['parentName'] as String?,
          );
        },
      ),
      GoRoute(
        path: product,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const _NotFoundScreen(message: 'Product not found.');
          }
          return ProductDetailsScreen(productId: id);
        },
      ),
      GoRoute(
        path: search,
        builder: (context, state) => SearchScreen(
          initialQuery: (_extra(state)['query'] ?? '').toString(),
        ),
      ),
      GoRoute(
        path: wishlist,
        builder: (context, state) =>
            WishlistScreen(onGoShopping: () => context.go(home)),
      ),
      GoRoute(
        path: orders,
        builder: (context, state) =>
            OrdersScreen(onGoShopping: () => context.go(homeTabFresh(tabHome))),
      ),
      GoRoute(
        path: newArrivals,
        builder: (context, state) => const NewArrivalsScreen(),
      ),
      GoRoute(
        path: trending,
        builder: (context, state) => const TrendingScreen(),
      ),
      GoRoute(
        path: bestSellers,
        builder: (context, state) => const BestSellersScreen(),
      ),
      GoRoute(
        path: recentViews,
        builder: (context, state) => const RecentViewsScreen(),
      ),

      // ---------------- checkout ----------------
      GoRoute(
        path: checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),

      GoRoute(
        path: buyNow,
        builder: (context, state) {
          final args = state.extra;
          if (args is! BuyNowArgs) {
            return const _NotFoundScreen(message: 'No product selected.');
          }
          return ConfirmOrderScreen(args: args);
        },
      ),

      // ---------------- addresses ----------------
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

      // ---------------- info / support ----------------
      GoRoute(path: faq, builder: (context, state) => const FaqScreen()),
      GoRoute(
        path: enquiry,
        builder: (context, state) => const EnquiryScreen(),
      ),
      GoRoute(
        path: refundPolicy,
        builder: (context, state) => const RefundPolicyScreen(),
      ),
      GoRoute(
        path: cancellationPolicy,
        builder: (context, state) => const CancellationPolicyScreen(),
      ),
      GoRoute(
        path: privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: terms,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: about,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

/// Shown for unknown URLs or when a route is opened without the data it needs.
class _NotFoundScreen extends StatelessWidget {
  final String message;
  const _NotFoundScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oops')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 56),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(AppRouter.home),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}