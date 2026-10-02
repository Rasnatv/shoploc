
import 'package:flutter/material.dart';

/// ShopLoc palette (same as the home screen).
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const grey = Color(0xFF8A94A6);
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav(
      {super.key, required this.currentIndex, required this.onTap});

  static const _items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_filled, 'Home'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Categories'),
    (Icons.favorite_border, Icons.favorite, 'Wishlist'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'Orders'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: _C.bg,
      border: Border(top: BorderSide(color: _C.blueLight)),
      boxShadow: [
        BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2)),
      ],
    ),
    child: SafeArea(
      child: SizedBox(
        height: 62,
        child: Row(
          children: List.generate(_items.length, (i) {
            final sel = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                splashColor: _C.blueLight,
                highlightColor: Colors.transparent,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: sel ? _C.searchBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          sel ? _items[i].$2 : _items[i].$1,
                          size: 22,
                          color: sel ? _C.blue : _C.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(_items[i].$3,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? _C.blue : _C.grey)),
                    ]),
              ),
            );
          }),
        ),
      ),
    ),
  );
}