//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/cartbloc/cart_bloc.dart';
// import '../bloc/cartbloc/cart_event.dart';
// import '../bloc/whishlistbloc/wishlist_bloc.dart';
// import '../bloc/whishlistbloc/wishlist_event.dart';
// import '../core/theme/app_colors.dart';
// import 'cart_screen.dart';
// import 'categories_screen.dart';
// import 'home_screen.dart';
// import 'profile_screen.dart';
// import 'wishlist_screen.dart';
//
// class MainBottomNavScreen extends StatefulWidget {
//   final int initialIndex;
//   const MainBottomNavScreen({super.key, this.initialIndex = 0});
//
//   @override
//   State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
// }
//
// class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
//   late int _currentIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final screens = <Widget>[
//     //   const HomeScreen(),
//     //   const CategoriesScreen(),
//     //   const WishlistScreen(),
//     //   const CartScreen(),
//     //   const ProfileScreen(),
//     // ];
//     final screens = <Widget>[
//       HomeScreen(
//         onNavigateToCategory: () => setState(() => _currentIndex = 1),
//       ),
//       const CategoriesScreen(),
//       WishlistScreen(onGoShopping: () => setState(() => _currentIndex = 0)),
//       CartScreen(onGoShopping: () => setState(() => _currentIndex = 0)),
//       const ProfileScreen(),
//     ];
//
//     return Scaffold(
//       body: IndexedStack(index: _currentIndex, children: screens),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: AppColors.surface,
//           border: Border(top: BorderSide(color: AppColors.borderLight)),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadow,
//               blurRadius: 10,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _item(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
//                 _item(1, Icons.dashboard_outlined, Icons.dashboard_rounded,
//                     'Categories'),
//                 _item(2, Icons.favorite_border_rounded, Icons.favorite_rounded,
//                     'Wishlist'),
//                 _item(3, Icons.shopping_bag_outlined,
//                     Icons.shopping_bag_rounded, 'Cart'),
//                 _item(4, Icons.person_outline_rounded, Icons.person_rounded,
//                     'Profile'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _item(int index, IconData icon, IconData activeIcon, String label) {
//     final selected = _currentIndex == index;
//     final color = selected ? AppColors.primary : AppColors.textTertiary;
//     return GestureDetector(
//       onTap: () {
//         setState(() => _currentIndex = index);
//         // Wishlist tab: silently re-sync (also picks up a fresh login)
//         if (index == 2) {
//           context.read<WishlistBloc>().add(const RefreshWishlistEvent());
//         }
//         // Cart tab: silently re-sync (also picks up a fresh login)
//         if (index == 3) {
//           context.read<CartBloc>().add(const RefreshCartEvent());
//         }
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(selected ? activeIcon : icon, size: 24, color: color),
//             const SizedBox(height: 3),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/utils/object_factory.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../core/theme/app_colors.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainBottomNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainBottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        onNavigateToCategory: () => setState(() => _currentIndex = 1),
      ),
      const CategoriesScreen(),
      WishlistScreen(onGoShopping: () => setState(() => _currentIndex = 0)),
      CartScreen(onGoShopping: () => setState(() => _currentIndex = 0)),
      const ProfileScreen(),
    ];

    return BlocListener<AuthBloc, AuthState>(
      // login from ANY place (Profile tab, product page, onboarding):
      // reload cart + wishlist so no tab keeps the old guest / error view
      listenWhen: (prev, cur) => cur is AuthenticatedState,
      listener: (context, state) {
        context.read<CartBloc>().add(const LoadCartEvent());
        context.read<WishlistBloc>().add(const LoadWishlistEvent());
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _item(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                  _item(1, Icons.dashboard_outlined, Icons.dashboard_rounded,
                      'Categories'),
                  _item(2, Icons.favorite_border_rounded, Icons.favorite_rounded,
                      'Wishlist'),
                  _item(3, Icons.shopping_bag_outlined,
                      Icons.shopping_bag_rounded, 'Cart'),
                  _item(4, Icons.person_outline_rounded, Icons.person_rounded,
                      'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  /// Tab switch: always show the right thing for the current session.
  /// logged out -> clear old data (guest view); logged in + list on screen ->
  /// silent refresh; logged in + nothing loaded yet -> full load with loader.
  void _syncCart() {
    final bloc = context.read<CartBloc>();
    if (!_loggedIn) {
      bloc.add(const ResetCartEvent());
    } else if (bloc.state is CartLoadedState) {
      bloc.add(const RefreshCartEvent());
    } else {
      bloc.add(const LoadCartEvent());
    }
  }

  void _syncWishlist() {
    final bloc = context.read<WishlistBloc>();
    if (!_loggedIn) {
      bloc.add(const ResetWishlistEvent());
    } else if (bloc.state is WishlistLoadedState) {
      bloc.add(const RefreshWishlistEvent());
    } else {
      bloc.add(const LoadWishlistEvent());
    }
  }

  Widget _item(int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 2) _syncWishlist();
        if (index == 3) _syncCart();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}