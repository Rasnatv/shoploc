
import 'package:flutter/material.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import 'search_page.dart';

/// Same palette as the other pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
  static const line = Color(0xFFE3E7EE);
  static const red = Color(0xFFE53935);
}

class ProductListPage extends StatefulWidget {
  final String title;
  final List<Product> products;
  const ProductListPage(
      {super.key, required this.title, required this.products});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  static const _sortNames = [
    'Relevance',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
  ];
  int _sort = 0;

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  List<Product> get _items {
    final list = List<Product>.of(widget.products);
    switch (_sort) {
      case 1:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 2:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 3:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  // --------------------------------------------------------------- divider
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

  // ------------------------------------------------------------- sort sheet
  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.line, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Sort by',
                  style: TextStyle(
                      color: _C.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < _sortNames.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(_sortNames[i],
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                        i == _sort ? FontWeight.w700 : FontWeight.w500,
                        color: i == _sort ? _C.blue : _C.navy)),
                trailing: i == _sort
                    ? const Icon(Icons.check_circle, color: _C.blue, size: 20)
                    : null,
                onTap: () {
                  setState(() => _sort = i);
                  Navigator.pop(context);
                },
              ),
          ]),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ pills
  Widget _pill(IconData icon, String label,
      {bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: active ? _C.blueLight : Colors.white,
          border: Border.all(color: active ? _C.blue : _C.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: active ? _C.blue : _C.navy),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: active ? _C.blue : _C.navy)),
          ],
        ]),
      ),
    );
  }

  // ---------------------------------------------------------- product card
  Widget _card(Product p, int i) {
    // Same image the product has on the home page.
    final idx = AppData.products.indexOf(p);
    final imgIndex = idx < 0 ? i : idx;
    final liked = AppData.wishlist.contains(p);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(p))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _shadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // image + heart + discount
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
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
                  onTap: () => setState(() {
                    liked
                        ? AppData.wishlist.remove(p)
                        : AppData.wishlist.add(p);
                  }),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? _C.red : _C.navy,
                        size: 18),
                  ),
                ),
              ),
              if (p.oldPrice != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.orange,
                        borderRadius: BorderRadius.circular(10)),
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

          // details
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5,
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
                              decoration: TextDecoration.lineThrough)),
                    ],
                    const Spacer(),
                    const Icon(Icons.star, size: 13, color: _C.orange),
                    const SizedBox(width: 2),
                    Text('${p.rating}',
                        style: const TextStyle(fontSize: 11, color: _C.navy)),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ empty state
  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 110,
        height: 110,
        decoration: const BoxDecoration(
            color: _C.searchBg, shape: BoxShape.circle),
        child: const Icon(Icons.checkroom, size: 48, color: _C.blue),
      ),
      const SizedBox(height: 16),
      const Text('No products found',
          style: TextStyle(
              color: _C.navy, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Try another category',
          style: TextStyle(color: _C.grey, fontSize: 12)),
    ]),
  );

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    final cols =
    Responsive.value<int>(context, mobile: 2, tablet: 3, desktop: 4);
    final items = _items;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: _C.navy),
            onPressed: () => Navigator.pop(context))
            : null,
        title: Text(widget.title,
            style: const TextStyle(
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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 6),
            child: Row(children: [
              Expanded(
                  child: _pill(Icons.swap_vert, 'Sort',
                      active: _sort != 0, onTap: _openSort)),
              const SizedBox(width: 10),
              Expanded(child: _pill(Icons.filter_list, 'Filter')),
              const SizedBox(width: 10),
              Expanded(child: _pill(Icons.grid_view, '', active: true)),
            ]),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _C.grey,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? _emptyState()
                : GridView.builder(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 24),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (_, i) => _card(items[i], i),
            ),
          ),
        ]),
      ),
    );
  }
}