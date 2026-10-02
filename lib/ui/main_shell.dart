import 'package:flutter/material.dart';
import 'package:shoploc/ui/profile.dart';
import '../widgets/app_bottom_nav.dart';
import 'categories_page.dart';
import 'home_page.dart';
import 'orderpage.dart';
import 'wishlist_page.dart';

/// Holds the bottom navigation and the 5 main tabs.
class MainShell extends StatefulWidget {
  final int index;
  const MainShell({super.key, this.index = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.index;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const HomePage(),
            const CategoriesPage(),
            WishlistPage(key: ValueKey('wish$_index')), // refresh when opened
            const Orderpage(), // Orders tab (track order)
            const ProfilePage(), // Profile tab
          ],
        ),
        bottomNavigationBar: AppBottomNav(
            currentIndex: _index, onTap: (i) => setState(() => _index = i)),
      );
}
