import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class MainBottomNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainBottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNavScreen> createState() => MainBottomNavScreenState();
}

class MainBottomNavScreenState extends State<MainBottomNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToCategory: () => switchTab(1)),
      const CategoriesScreen(),
      WishlistScreen(onGoShopping: () => switchTab(0)),
      CartScreen(onGoShopping: () => switchTab(0)),
      ProfileScreen(
        onNavigateToOrders: () {},
        onNavigateToWishlist: () => switchTab(2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
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
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Categories',
                ),
                _buildWishlistNavItem(index: 2),
                _buildCartNavItem(index: 3),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => switchTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyle.caption.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, state) {
        final count = state is WishlistLoadedState ? state.count : 0;

        return GestureDetector(
          onTap: () => switchTab(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 24,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.badgeText.copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Wishlist',
                  style: AppTextStyle.caption.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final count = state is CartLoadedState ? state.totalItemCount : 0;

        return GestureDetector(
          onTap: () => switchTab(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
                      size: 24,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.badgeText.copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Cart',
                  style: AppTextStyle.caption.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

