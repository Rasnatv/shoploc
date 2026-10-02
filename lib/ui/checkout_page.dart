import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import 'main_shell.dart';

/// ShopLoc palette (same as the home / cart / categories screens).
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

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _pay = 0;
  bool _agree = true;

  static const _methods = <(String, String, IconData)>[
    ('UPI', 'Google Pay, PhonePe, Paytm', Icons.account_balance_wallet_outlined),
    ('Card', 'Credit / Debit Card', Icons.credit_card),
    ('Cash on Delivery', 'Pay when your order arrives', Icons.payments_outlined),
  ];

  int get _total =>
      AppData.cart.fold(0, (s, c) => s + c.product.price * c.qty);

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
    iconTheme: const IconThemeData(color: _C.navy),
    title: const Text('Checkout',
        style: TextStyle(
            color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
    bottom: _divider(),
  );

  // ------------------------------------------------------------ helpers
  static const _cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  Widget _stepHeader(String n, String title, {Widget? trailing}) =>
      Row(children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration:
          const BoxDecoration(color: _C.blue, shape: BoxShape.circle),
          child: Text(n,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: _C.navy)),
        const Spacer(),
        if (trailing != null) trailing,
      ]);

  // ------------------------------------------------------------ address
  Widget _addressCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: _cardShadow,
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: _C.orangeLight, shape: BoxShape.circle),
        child: const Icon(Icons.location_on_outlined,
            color: _C.orange, size: 22),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rasna Rachu',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.navy)),
              SizedBox(height: 4),
              Text('Kalluvathukkal House',
                  style: TextStyle(fontSize: 12, color: _C.grey)),
              Text('Kasaragod, Kerala - 671121',
                  style: TextStyle(fontSize: 12, color: _C.grey)),
              SizedBox(height: 4),
              Text('+91 98765 43210',
                  style: TextStyle(fontSize: 12, color: _C.grey)),
            ]),
      ),
    ]),
  );

  // ------------------------------------------------------------ payment
  Widget _paymentTile(int i) {
    final m = _methods[i];
    final selected = _pay == i;
    return GestureDetector(
      onTap: () => setState(() => _pay = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _C.searchBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _C.blue : Colors.transparent, width: 1.4),
          boxShadow: selected ? null : _cardShadow,
        ),
        child: Row(children: [
          Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? _C.blue : _C.grey,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.$1,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.navy)),
                  if (m.$2.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(m.$2,
                        style:
                        const TextStyle(fontSize: 11, color: _C.grey)),
                  ],
                ]),
          ),
          Icon(m.$3, color: selected ? _C.blue : _C.grey),
        ]),
      ),
    );
  }

  // ------------------------------------------------------------ order
  void _placeOrder() {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please accept the Terms & Conditions')));
      return;
    }
    AppData.cart.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: _C.blueLight, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: _C.blue, size: 44),
        ),
        title: const Text('Order Placed!',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('Thank you for supporting local sellers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _C.grey)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell(index: 3)),
                      (route) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Track Order',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ bottom bar
  Widget _bottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
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
      child: Row(children: [
        Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 11, color: _C.grey)),
              Text('\u20B9$_total',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _C.navy)),
            ]),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Place Order',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    ),
  );

  // ------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _C.bg,
    appBar: _appBar(),
    body: ResponsiveCenter(
      maxWidth: 700,
      child: Column(children: [
        Expanded(
          child: ListView(
              padding: EdgeInsets.all(Responsive.hPad(context)),
              children: [
                _stepHeader('1', 'Delivery Address',
                    trailing: const Text('Change',
                        style: TextStyle(
                            fontSize: 12,
                            color: _C.blue,
                            fontWeight: FontWeight.w600))),
                const SizedBox(height: 12),
                _addressCard(),
                const SizedBox(height: 24),
                _stepHeader('2', 'Payment Method'),
                const SizedBox(height: 12),
                for (var i = 0; i < _methods.length; i++) ...[
                  _paymentTile(i),
                  if (i < _methods.length - 1) const SizedBox(height: 10),
                ],
                const SizedBox(height: 18),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                          value: _agree,
                          activeColor: _C.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (v) =>
                              setState(() => _agree = v ?? false)),
                      const Expanded(
                        child: Text(
                            'I agree to the Terms & Conditions and Privacy Policy',
                            style:
                            TextStyle(fontSize: 11, color: _C.grey)),
                      ),
                    ]),
                const SizedBox(height: 16),
              ]),
        ),
        _bottomBar(),
      ]),
    ),
  );
}