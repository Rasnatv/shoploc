
import 'package:flutter/material.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import 'product_list_page.dart';
import 'search_page.dart';

/// Same palette as the home page.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const orange = Color(0xFFFFA24C);
  static const navy = Color(0xFF2C3A55);
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  /// Thin line with a short orange accent in the centre.
  PreferredSizeWidget _divider() => PreferredSize(
    preferredSize: const Size.fromHeight(3),
    child: Stack(alignment: Alignment.center, children: [
      const Divider(height: 1, thickness: 1, color: _C.blueLight),
      Container(
        width: 40,
        height: 3,
        decoration: BoxDecoration(
            color: _C.orange, borderRadius: BorderRadius.circular(2)),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final cats = AppData.categories;
    final cols =
    Responsive.value<int>(context, mobile: 2, tablet: 3, desktop: 4);
    final pad = Responsive.hPad(context);

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Categories',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: _C.navy),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchPage())))
        ],
        bottom: _divider(),
      ),
      body: ResponsiveCenter(
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
          itemCount: cats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82),
          itemBuilder: (_, i) {
            final c = cats[i];
            return GestureDetector(
              onTap: () {
                final list = AppData.products
                    .where((p) => p.category == c.name)
                    .toList();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductListPage(
                            title: c.name,
                            products: list.isEmpty ? AppData.products : list)));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(fit: StackFit.expand, children: [
                  Container(color: c.color),
                  Image.asset(
                    AppAssets.categoryImage(i),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                        child:
                        Icon(Icons.checkroom, color: _C.navy, size: 40)),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.45, 1.0],
                          colors: [Color(0x00000000), Color(0xCC000000)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_outward,
                          size: 16, color: _C.blue),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(c.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xE6FFFFFF), fontSize: 11)),
                        ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}