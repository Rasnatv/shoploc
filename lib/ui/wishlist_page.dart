
import 'package:flutter/material.dart';
import '../core/appcolors.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import '../models/cart_item.dart';
import 'product_detail_page.dart';

/// Same palette as the home page.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
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

  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 110,
        height: 110,
        decoration: const BoxDecoration(
            color: _C.searchBg, shape: BoxShape.circle),
        child: const Icon(Icons.favorite_border, size: 48, color: _C.blue),
      ),
      const SizedBox(height: 16),
      const Text('Your wishlist is empty',
          style: TextStyle(
              color: _C.navy, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Tap the heart on items you love',
          style: TextStyle(color: _C.grey, fontSize: 12)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final list = AppData.wishlist;
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
        title: const Text('My Wishlist',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_outline, color: _C.navy),
              onPressed: () => setState(list.clear))
        ],
        bottom: _divider(),
      ),
      body: list.isEmpty
          ? _emptyState()
          : ResponsiveCenter(
        maxWidth: 900,
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _C.orangeLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                    '${list.length} saved ${list.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: _C.navy,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (_, i) {
                final p = list[i];
                // Same image the product has on the home page.
                final idx = AppData.products.indexOf(p);
                final imgIndex = idx < 0 ? i : idx;

                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetailPage(p))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- image + heart + discount
                          Expanded(
                            child: Stack(fit: StackFit.expand, children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.asset(
                                  AppAssets.productImage(imgIndex),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _C.blueLight,
                                    child: const Icon(Icons.checkroom,
                                        color: _C.blue, size: 40),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => list.remove(p)),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.favorite,
                                        color: AppColors.red, size: 18),
                                  ),
                                ),
                              ),
                              if (p.oldPrice != null)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: _C.orange,
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    child: Text(
                                        '${((p.oldPrice! - p.price) * 100 / p.oldPrice!).round()}% OFF',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                            ]),
                          ),

                          // ---------- details
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(10, 8, 10, 10),
                            child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _C.navy)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Text('\u20B9${p.price}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _C.blue)),
                                    if (p.oldPrice != null) ...[
                                      const SizedBox(width: 6),
                                      Text('\u20B9${p.oldPrice}',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: _C.grey,
                                              decoration: TextDecoration
                                                  .lineThrough)),
                                    ],
                                    const Spacer(),
                                    const Icon(Icons.star,
                                        size: 13, color: _C.orange),
                                    const SizedBox(width: 2),
                                    Text('${p.rating}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: _C.navy)),
                                  ]),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        AppData.cart.add(
                                            CartItem(p, 'Default', 'M'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Moved to cart')));
                                        setState(() => list.remove(p));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _C.blue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize:
                                          const Size.fromHeight(34),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  17))),
                                      child: const Text('Move to Cart',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600)),
                                    ),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}