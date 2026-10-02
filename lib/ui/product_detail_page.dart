import 'package:flutter/material.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'checkout_page.dart';

/// Same palette as the other pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
  static const line = Color(0xFFE3E7EE);
  static const red = Color(0xFFE53935);
}

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage(this.product, {super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _colorIdx = 0;
  String _size = 'M';

  CartItem get _item =>
      CartItem(widget.product, AppData.colorOptions[_colorIdx].name, _size);

  /// Same image the product has on the home page.
  int get _imgIndex {
    final idx = AppData.products.indexOf(widget.product);
    return idx < 0 ? 0 : idx;
  }

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  // ------------------------------------------------------------- round btn
  Widget _roundBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle, boxShadow: _shadow),
          child: Icon(icon, color: color, size: 20),
        ),
      );

  // ---------------------------------------------------------------- gallery
  Widget _gallery({required bool wide}) {
    final p = widget.product;
    final liked = AppData.wishlist.contains(p);

    final img = Image.asset(
      AppAssets.productImage(_imgIndex),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: _C.blueLight,
        child: const Center(
            child: Icon(Icons.checkroom, color: _C.blue, size: 70)),
      ),
    );

    final picture = wide
        ? SizedBox.expand(child: img)
        : ClipRRect(
      borderRadius:
      const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: SizedBox(
          height: 400, width: double.infinity, child: img),
    );

    return Stack(children: [
      picture,
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundBtn(Icons.arrow_back_ios_new, _C.navy,
                        () => Navigator.pop(context)),
                _roundBtn(
                    liked ? Icons.favorite : Icons.favorite_border,
                    liked ? _C.red : _C.navy,
                        () => setState(() {
                      liked
                          ? AppData.wishlist.remove(p)
                          : AppData.wishlist.add(p);
                    })),
              ]),
        ),
      ),
    ]);
  }

  // ------------------------------------------------------------ info block
  Widget _label(String t, {Widget? trailing}) => Row(children: [
    Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
          color: _C.orange, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Text(t,
        style: const TextStyle(
            color: _C.navy, fontSize: 14, fontWeight: FontWeight.w700)),
    const Spacer(),
    if (trailing != null) trailing,
  ]);

  Widget _infoCard(IconData icon, Color fg, Color bg, String title, String sub) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _C.searchBg, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: fg, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: _C.navy,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                    Text(sub,
                        style:
                        const TextStyle(color: _C.grey, fontSize: 10)),
                  ]),
            ),
          ]),
        ),
      );

  Widget _info() {
    final p = widget.product;
    final int? discount = p.oldPrice == null
        ? null
        : (p.discountPercent ??
        ((p.oldPrice! - p.price) * 100 / p.oldPrice!).round());

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Name
        Text(p.name,
            style: const TextStyle(
                color: _C.navy, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),

        // Price + discount
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('\u20B9${p.price}',
              style: const TextStyle(
                  color: _C.blue, fontSize: 24, fontWeight: FontWeight.w800)),
          if (p.oldPrice != null) ...[
            const SizedBox(width: 10),
            Text('\u20B9${p.oldPrice}',
                style: const TextStyle(
                    color: _C.grey,
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough)),
          ],
          if (discount != null) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.orange, borderRadius: BorderRadius.circular(10)),
              child: Text('$discount% OFF',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 10),

        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _C.orangeLight, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star, size: 15, color: _C.orange),
            const SizedBox(width: 4),
            Text('${p.rating}',
                style: const TextStyle(
                    color: _C.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text('(${p.reviews} reviews)',
                style: const TextStyle(color: _C.grey, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 20),

        // Colour
        _label('Colour',
            trailing: Text(AppData.colorOptions[_colorIdx].name,
                style: const TextStyle(color: _C.grey, fontSize: 12))),
        const SizedBox(height: 12),
        Row(
          children: List.generate(AppData.colorOptions.length, (i) {
            final sel = i == _colorIdx;
            return GestureDetector(
              onTap: () => setState(() => _colorIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: sel ? _C.blue : Colors.transparent, width: 2)),
                child: CircleAvatar(
                    radius: 13,
                    backgroundColor: AppData.colorOptions[i].color),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Size
        _label('Size',
            trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.straighten, size: 15, color: _C.blue),
              SizedBox(width: 4),
              Text('Size Chart',
                  style: TextStyle(
                      color: _C.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ])),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppData.sizes.map((s) {
            final sel = s == _size;
            return GestureDetector(
              onTap: () => setState(() => _size = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: sel ? _C.blue : Colors.white,
                    border: Border.all(color: sel ? _C.blue : _C.line),
                    borderRadius: BorderRadius.circular(14)),
                child: Text(s,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _C.navy)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // Trust row
        Row(children: [
          _infoCard(Icons.local_shipping_outlined, _C.orange, Colors.white,
              'Free Delivery', 'on all orders'),
          const SizedBox(width: 10),
          _infoCard(Icons.verified, _C.blue, Colors.white, 'Trusted Local',
              'Sellers (Kasaragod)'),
        ]),
      ]),
    );
  }

  // ---------------------------------------------------- add to cart / buy
  Widget _buttons() => Container(
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
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                AppData.cart.add(_item);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                      const SnackBar(content: Text('Added to cart')));
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Add to Cart',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _C.blue,
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: _C.blue, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                AppData.cart.add(_item);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CheckoutPage()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
              child: const Text('Buy Now',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    ),
  );

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final wide = !Responsive.isMobile(context);

    if (wide) {
      // Tablet / desktop: image on the left, details on the right.
      return Scaffold(
        backgroundColor: _C.bg,
        body: Row(children: [
          Expanded(child: _gallery(wide: true)),
          Expanded(
            child: Column(children: [
              Expanded(
                child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(child: _info())),
              ),
              _buttons(),
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: _C.bg,
      body: Column(children: [
        Expanded(
          child: ListView(
              padding: EdgeInsets.zero,
              children: [_gallery(wide: false), _info()]),
        ),
        _buttons(),
      ]),
    );
  }
}