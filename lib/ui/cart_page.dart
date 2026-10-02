import 'package:flutter/material.dart';
import '../core/apptheme.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import 'checkout_page.dart';

/// ShopLoc palette (same as the home / onboarding screens).
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

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get _subtotal =>
      AppData.cart.fold(0, (s, c) => s + c.product.price * c.qty);

  int get _itemCount => AppData.cart.fold(0, (s, c) => s + c.qty as int);

  // ------------------------------------------------------------ app bar
  /// Thin line with a short orange accent in the centre (same as Categories).
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

  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: _C.bg,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new)),
    iconTheme: const IconThemeData(color: _C.navy),
    title: const Text('My Cart',
        style: TextStyle(
            color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
    actions: [
      IconButton(
        icon: Icon(Icons.delete_outline,
            color: AppData.cart.isEmpty ? _C.grey : _C.navy),
        onPressed: AppData.cart.isEmpty
            ? null
            : () => setState(AppData.cart.clear),
      ),
    ],
    bottom: _divider(),
  );

  // ------------------------------------------------------------ quantity
  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(7),
      child: Icon(icon, size: 16, color: _C.blue),
    ),
  );

  Widget _qtyStepper(dynamic c, int i) => Container(
    decoration: BoxDecoration(
      color: _C.searchBg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _qtyBtn(Icons.remove, () {
        if (c.qty > 1) {
          setState(() => c.qty--);
        } else {
          setState(() => AppData.cart.removeAt(i));
        }
      }),
      SizedBox(
        width: 22,
        child: Text('${c.qty}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.navy)),
      ),
      _qtyBtn(Icons.add, () => setState(() => c.qty++)),
    ]),
  );

  // ------------------------------------------------------------ cart item
  Widget _cartItem(dynamic c, int i) {
    var imgIndex = AppData.products.indexOf(c.product);
    if (imgIndex < 0) imgIndex = i;

    return Dismissible(
      key: ObjectKey(c),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => setState(() => AppData.cart.removeAt(i)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _C.orangeLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: _C.orange),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              AppAssets.productImage(imgIndex),
              width: 84,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 84,
                height: 96,
                color: _C.blueLight,
                child: const Icon(Icons.checkroom, color: _C.blue, size: 32),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.navy)),
                  const SizedBox(height: 4),
                  Text('${c.color}  |  ${c.size}',
                      style: const TextStyle(fontSize: 11, color: _C.grey)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('\u20B9${c.product.price}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _C.blue)),
                    const Spacer(),
                    _qtyStepper(c, i),
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
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: _C.blueLight),
        child: const Icon(Icons.shopping_cart_outlined,
            size: 42, color: _C.blue),
      ),
      const SizedBox(height: 16),
      const Text('Your cart is empty',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.navy)),
      const SizedBox(height: 6),
      const Text('Add something you like from local sellers.',
          style: TextStyle(fontSize: 12, color: _C.grey)),
      const SizedBox(height: 18),
      SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () => Navigator.maybePop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Start shopping',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );

  // ------------------------------------------------------------ summary
  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) =>
      Row(children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 16 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? _C.navy : _C.grey)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 17 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor ?? _C.navy)),
      ]);

  Widget _summary(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      boxShadow: [
        BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, -4)),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _summaryRow('Subtotal ($_itemCount items)', '\u20B9$_subtotal'),
        const SizedBox(height: 8),
        _summaryRow('Delivery Charges', 'FREE', valueColor: _C.orange),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: _C.blueLight),
        ),
        _summaryRow('Total', '\u20B9$_subtotal', bold: true),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (AppData.cart.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your cart is empty')));
                return;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CheckoutPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Proceed to Checkout',
                style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );

  // ------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final cart = AppData.cart;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Column(children: [
          Expanded(
            child: cart.isEmpty
                ? _emptyState()
                : ListView.separated(
              padding: EdgeInsets.all(Responsive.hPad(context)),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _cartItem(cart[i], i),
            ),
          ),
          if (cart.isNotEmpty) _summary(context),
        ]),
      ),
    );
  }
}