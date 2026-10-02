import 'package:flutter/material.dart';
import '../core/appcolors.dart';
import '../core/appimages.dart';
import '../core/apptheme.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';

/// Same palette as the Home / Wishlist / Profile pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
  static const green = Color(0xFF2E9E5B);
  static const greenLight = Color(0xFFDDF3E6);
  static const redLight = Color(0xFFFDE8E8);
}

enum _Status { ongoing, delivered, cancelled }

class _Order {
  final String id;
  final String date;
  final _Status status;
  final int productIndex; // index in AppData.products
  final String size;
  final int step; // 0 placed, 1 packed, 2 shipped, 3 delivered
  final String note;
  const _Order(this.id, this.date, this.status, this.productIndex, this.size,
      this.step, this.note);
}

/// Orders page (list of orders with filters and tracking).
class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage> {
  // Dummy orders – replace with real data later.
  static const List<_Order> _orders = [
    _Order('SL123456', '12 Sep 2025', _Status.ongoing, 1, 'L', 2,
        'Expected delivery: 14 Sep 2025'),
    _Order('SL123401', '02 Sep 2025', _Status.delivered, 0, 'M', 3,
        'Delivered on 05 Sep 2025'),
    _Order('SL123377', '25 Aug 2025', _Status.delivered, 2, 'M', 3,
        'Delivered on 28 Aug 2025'),
    _Order('SL123290', '10 Aug 2025', _Status.cancelled, 3, 'S', 0,
        'Cancelled by you'),
  ];

  static const _filters = ['All', 'Ongoing', 'Delivered', 'Cancelled'];
  int _filter = 0;

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  List<_Order> get _visible {
    if (_filter == 0) return _orders;
    final s =
    [_Status.ongoing, _Status.delivered, _Status.cancelled][_filter - 1];
    return _orders.where((o) => o.status == s).toList();
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

  // ----------------------------------------------------------- empty state
  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 110,
        height: 110,
        decoration: const BoxDecoration(
            color: _C.searchBg, shape: BoxShape.circle),
        child: const Icon(Icons.inventory_2_outlined,
            size: 48, color: _C.blue),
      ),
      const SizedBox(height: 16),
      const Text('No orders here yet',
          style: TextStyle(
              color: _C.navy, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const Text('Your orders will show up here',
          style: TextStyle(color: _C.grey, fontSize: 12)),
    ]),
  );

  // ----------------------------------------------------------- status chip
  (String, Color, Color) _statusStyle(_Order o) {
    switch (o.status) {
      case _Status.ongoing:
        return (o.step >= 2 ? 'Out for Delivery' : 'Processing',
        _C.blue, _C.blueLight);
      case _Status.delivered:
        return ('Delivered', _C.green, _C.greenLight);
      case _Status.cancelled:
        return ('Cancelled', AppColors.red, _C.redLight);
    }
  }

  // -------------------------------------------------------------- tracker
  Widget _dot(IconData icon, String label, bool done) => Column(children: [
    CircleAvatar(
      radius: 13,
      backgroundColor: done ? _C.blue : AppColors.stepInactive,
      child: Icon(icon, size: 14, color: done ? Colors.white : _C.grey),
    ),
    const SizedBox(height: 3),
    Text(label,
        style: TextStyle(
            fontSize: 9.5,
            color: done ? _C.navy : _C.grey,
            fontWeight: done ? FontWeight.w600 : FontWeight.w400)),
  ]);

  Widget _bar(bool done) => Expanded(
    child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: done ? _C.blue : AppColors.border),
  );

  Widget _tracker(int step) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dot(Icons.check, 'Placed', step >= 0),
        _bar(step >= 1),
        _dot(Icons.inventory_2_outlined, 'Packed', step >= 1),
        _bar(step >= 2),
        _dot(Icons.local_shipping_outlined, 'Shipped', step >= 2),
        _bar(step >= 3),
        _dot(Icons.check_circle_outline, 'Delivered', step >= 3),
      ]);

  // --------------------------------------------------------------- buttons
  Widget _filled(String t, VoidCallback onTap) => Expanded(
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: _C.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18))),
      child: Text(t,
          style:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _outlined(String t, VoidCallback onTap) => Expanded(
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          foregroundColor: _C.blue,
          side: const BorderSide(color: _C.blue),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18))),
      child: Text(t,
          style:
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
  );

  // ------------------------------------------------------------ order card
  Widget _orderCard(_Order o) {
    final products = AppData.products;
    final pIdx = o.productIndex < products.length ? o.productIndex : 0;
    final p = products[pIdx];
    final (label, fg, bgc) = _statusStyle(o);
    void noop() {}

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: id + status
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${o.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _C.navy)),
                  const SizedBox(height: 2),
                  Text('Placed on ${o.date}', style: AppText.small),
                ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: bgc, borderRadius: BorderRadius.circular(12)),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
          ),
        ]),
        const Divider(height: 22, color: Color(0xFFF0F0F0)),

        // Product row
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppAssets.productImage(pIdx),
              width: 70,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 84,
                color: _C.blueLight,
                child: const Icon(Icons.checkroom, color: _C.blue, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body),
                  const SizedBox(height: 3),
                  Text('Size ${o.size}  \u2022  Qty 1', style: AppText.small),
                  const SizedBox(height: 6),
                  Text('\u20B9${p.price}', style: AppText.price),
                ]),
          ),
        ]),
        const SizedBox(height: 12),

        // Tracker (ongoing) or note
        if (o.status == _Status.ongoing) ...[
          _tracker(o.step),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.local_shipping, size: 16, color: _C.blue),
            const SizedBox(width: 6),
            Text(o.note, style: AppText.small),
          ]),
        ] else
          Row(children: [
            Icon(
                o.status == _Status.delivered
                    ? Icons.check_circle
                    : Icons.cancel,
                size: 16,
                color: fg),
            const SizedBox(width: 6),
            Text(o.note, style: AppText.small),
          ]),
        const SizedBox(height: 12),

        // Actions
        Row(children: [
          if (o.status == _Status.ongoing) ...[
            _filled('Track Order', noop),
            const SizedBox(width: 10),
            _outlined('View Details', noop),
          ] else if (o.status == _Status.delivered) ...[
            _filled('Buy Again', noop),
            const SizedBox(width: 10),
            _outlined('View Details', noop),
          ] else
            _outlined('View Details', noop),
        ]),
      ]),
    );
  }

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // Back arrow only when this page was opened from another page.
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: _C.navy),
            onPressed: () => Navigator.pop(context))
            : null,
        title: const Text('My Orders',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: _divider(),
      ),
      body: ResponsiveCenter(
        maxWidth: 700,
        child: Column(children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hPad(context), vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final sel = i == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? _C.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? _C.blue : const Color(0xFFE3E7EE)),
                    ),
                    child: Text(_filters[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : _C.navy)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? _emptyState()
                : ListView.separated(
              padding: EdgeInsets.fromLTRB(Responsive.hPad(context), 8,
                  Responsive.hPad(context), 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _orderCard(list[i]),
            ),
          ),
        ]),
      ),
    );
  }
}