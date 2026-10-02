
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
  static const line = Color(0xFFE9EDF3);
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
  static const _steps = [
    ('Order placed', 'We have received your order', Icons.receipt_long_outlined),
    ('Packed', 'Your item is packed and ready', Icons.inventory_2_outlined),
    ('Shipped', 'On its way to you', Icons.local_shipping_outlined),
    ('Delivered', 'Delivered to your address', Icons.check_circle_outline),
  ];

  int _filter = 0;

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x0F1B2A4A), blurRadius: 14, offset: Offset(0, 4)),
  ];

  // ------------------------------------------------------------- data
  List<_Order> _byFilter(int f) {
    if (f == 0) return _orders;
    final s = [_Status.ongoing, _Status.delivered, _Status.cancelled][f - 1];
    return _orders.where((o) => o.status == s).toList();
  }

  List<_Order> get _visible => _byFilter(_filter);

  Future<void> _refresh() async {
    // TODO: reload orders from your backend.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  (String, Color, Color) _statusStyle(_Order o) {
    switch (o.status) {
      case _Status.ongoing:
        return (o.step >= 2 ? 'Out for delivery' : 'Processing', _C.blue,
        _C.blueLight);
      case _Status.delivered:
        return ('Delivered', _C.green, _C.greenLight);
      case _Status.cancelled:
        return ('Cancelled', AppColors.red, _C.redLight);
    }
  }

  // ---------------------------------------------------------- app bar
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

  // ------------------------------------------------------ filter chips
  Widget _filterBar() => SizedBox(
    height: 56,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.hPad(context), vertical: 10),
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final sel = i == _filter;
        final count = _byFilter(i).length;
        return Material(
          color: sel ? _C.blue : Colors.white,
          shape: StadiumBorder(
              side: BorderSide(color: sel ? _C.blue : _C.line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => setState(() => _filter = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_filters[i],
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _C.navy)),
                const SizedBox(width: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white.withOpacity(0.22)
                        : _C.searchBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count',
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : _C.blue)),
                ),
              ]),
            ),
          ),
        );
      },
    ),
  );

  // ------------------------------------------------------ empty state
  Widget _emptyState() => ListView(
    // ListView keeps pull-to-refresh working on an empty list.
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.14),
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
                color: _C.searchBg, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined,
                size: 44, color: _C.blue),
          ),
          const SizedBox(height: 18),
          Text(
              _filter == 0
                  ? 'No orders yet'
                  : 'No ${_filters[_filter].toLowerCase()} orders',
              style: const TextStyle(
                  color: _C.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Orders you place will appear here.',
              style: TextStyle(color: _C.grey, fontSize: 12.5)),
          if (_filter != 0) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _filter = 0),
              child: const Text('View all orders',
                  style: TextStyle(
                      color: _C.blue, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ),
    ],
  );

  // ---------------------------------------------------- progress tracker
  Widget _dot(IconData icon, String label, bool done, bool current) {
    return SizedBox(
      width: 54,
      child: Column(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? _C.blue : AppColors.stepInactive,
            boxShadow: current
                ? [
              BoxShadow(
                  color: _C.blue.withOpacity(0.25),
                  blurRadius: 0,
                  spreadRadius: 4)
            ]
                : null,
          ),
          child: Icon(icon, size: 14, color: done ? Colors.white : _C.grey),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: done ? _C.navy : _C.grey,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }

  Widget _bar(bool done) => Expanded(
    child: Container(
      height: 3,
      margin: const EdgeInsets.only(top: 12.5, left: 2, right: 2),
      decoration: BoxDecoration(
          color: done ? _C.blue : AppColors.border,
          borderRadius: BorderRadius.circular(2)),
    ),
  );

  Widget _tracker(int step) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dot(Icons.check, 'Placed', step >= 0, step == 0),
        _bar(step >= 1),
        _dot(Icons.inventory_2_outlined, 'Packed', step >= 1, step == 1),
        _bar(step >= 2),
        _dot(Icons.local_shipping_outlined, 'Shipped', step >= 2, step == 2),
        _bar(step >= 3),
        _dot(Icons.check_circle_outline, 'Delivered', step >= 3, step == 3),
      ]);

  // ---------------------------------------------------------- buttons
  Widget _filled(String t, VoidCallback onTap) => Expanded(
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: _C.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
      child: Text(t,
          style:
          const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _outlined(String t, VoidCallback onTap) => Expanded(
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          foregroundColor: _C.navy,
          side: const BorderSide(color: Color(0xFFD5DCE8)),
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
      child: Text(t,
          style:
          const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
    ),
  );

  // ---------------------------------------------------------- details
  void _showDetails(_Order o) {
    final p = AppData.products[
    o.productIndex < AppData.products.length ? o.productIndex : 0];
    final (label, fg, bgc) = _statusStyle(o);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _C.line,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: Text('Order #${o.id}',
                        style: const TextStyle(
                            color: _C.navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                  ),
                  _statusPill(label, fg, bgc),
                ]),
                const SizedBox(height: 4),
                Text('Placed on ${o.date}', style: AppText.small),
                const SizedBox(height: 18),
                _detailRow('Item', p.name),
                _detailRow('Size', o.size),
                _detailRow('Quantity', '1'),
                _detailRow('Price', '\u20B9${p.price}'),
                const SizedBox(height: 12),
                if (o.status == _Status.cancelled)
                  _infoBanner(Icons.cancel, o.note, fg, bgc)
                else ...[
                  const Text('Order progress',
                      style: TextStyle(
                          color: _C.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _steps.length; i++)
                    _timelineTile(i, o.step, i == _steps.length - 1),
                  const SizedBox(height: 4),
                  _infoBanner(
                      o.status == _Status.delivered
                          ? Icons.check_circle
                          : Icons.local_shipping,
                      o.note,
                      fg,
                      bgc),
                ],
              ]),
        ),
      ),
    );
  }

  Widget _detailRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 84,
          child: Text(k,
              style: const TextStyle(color: _C.grey, fontSize: 12.5))),
      Expanded(
        child: Text(v,
            style: const TextStyle(
                color: _C.navy,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    ]),
  );

  Widget _timelineTile(int i, int current, bool last) {
    final done = i <= current;
    final s = _steps[i];
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: done ? _C.blue : AppColors.stepInactive,
              child: Icon(done ? Icons.check : s.$3,
                  size: 13, color: done ? Colors.white : _C.grey),
            ),
            if (!last)
              Expanded(
                child: Container(
                    width: 2,
                    color: i < current ? _C.blue : AppColors.border),
              ),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: done ? _C.navy : _C.grey)),
                  const SizedBox(height: 2),
                  Text(s.$2, style: AppText.small),
                ]),
          ),
        ),
      ]),
    );
  }

  // ---------------------------------------------------------- pieces
  Widget _statusPill(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    ]),
  );

  Widget _infoBanner(IconData icon, String text, Color fg, Color bg) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: bg.withOpacity(0.55),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg)),
          ),
        ]),
      );

  // ------------------------------------------------------- order card
  Widget _orderCard(_Order o) {
    final products = AppData.products;
    final pIdx = o.productIndex < products.length ? o.productIndex : 0;
    final p = products[pIdx];
    final (label, fg, bgc) = _statusStyle(o);
    void noop() {}

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
        boxShadow: _shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header band: id + date + status
        Container(
          color: const Color(0xFFF7F9FC),
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${o.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: _C.navy)),
                    const SizedBox(height: 2),
                    Text('Placed on ${o.date}', style: AppText.small),
                  ]),
            ),
            _statusPill(label, fg, bgc),
          ]),
        ),
        const Divider(height: 1, thickness: 1, color: _C.line),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product row
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDetails(o),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        AppAssets.productImage(pIdx),
                        width: 72,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 88,
                          color: _C.blueLight,
                          child: const Icon(Icons.checkroom,
                              color: _C.blue, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body),
                            const SizedBox(height: 6),
                            Row(children: [
                              _meta('Size ${o.size}'),
                              const SizedBox(width: 6),
                              _meta('Qty 1'),
                            ]),
                            const SizedBox(height: 10),
                            Text('\u20B9${p.price}', style: AppText.price),
                          ]),
                    ),
                    const Icon(Icons.chevron_right,
                        color: _C.grey, size: 20),
                  ]),
                ),
                const SizedBox(height: 16),

                // Tracker (ongoing) or note
                if (o.status == _Status.ongoing) ...[
                  _tracker(o.step),
                  const SizedBox(height: 14),
                ],
                _infoBanner(
                    o.status == _Status.ongoing
                        ? Icons.local_shipping
                        : o.status == _Status.delivered
                        ? Icons.check_circle
                        : Icons.cancel,
                    o.note,
                    fg,
                    bgc),
                const SizedBox(height: 14),

                // Actions
                Row(children: [
                  if (o.status == _Status.ongoing) ...[
                    _filled('Track order', () => _showDetails(o)),
                    const SizedBox(width: 10),
                    _outlined('View details', () => _showDetails(o)),
                  ] else if (o.status == _Status.delivered) ...[
                    _filled('Buy again', noop),
                    const SizedBox(width: 10),
                    _outlined('View details', () => _showDetails(o)),
                  ] else
                    _outlined('View details', () => _showDetails(o)),
                ]),
              ]),
        ),
      ]),
    );
  }

  Widget _meta(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: _C.searchBg, borderRadius: BorderRadius.circular(6)),
    child: Text(t,
        style: const TextStyle(
            fontSize: 10.5, color: _C.navy, fontWeight: FontWeight.w600)),
  );

  // ------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    final list = _visible;
    final hPad = Responsive.hPad(context);

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
          _filterBar(),
          Expanded(
            child: RefreshIndicator(
              color: _C.blue,
              onRefresh: _refresh,
              child: list.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 28),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _orderCard(list[i]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}