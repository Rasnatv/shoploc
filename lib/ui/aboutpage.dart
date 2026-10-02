import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/app_data.dart';
import 'product_list_page.dart';

/// Same palette as the other pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueDark = Color(0xFF1F63C8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const body = Color(0xFF4B5770);
  static const grey = Color(0xFF8A94A6);
  static const border = Color(0xFFF0F0F0);
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static const _values = <(IconData, String, String)>[
    (
    Icons.verified_outlined,
    'Quality First',
    'Every product on Shoploc is carefully selected to meet our quality standards before it reaches you.'
    ),
    (
    Icons.visibility_outlined,
    'Honest & Transparent',
    'No hidden charges, no fake discounts. What you see is what you pay \u2014 always.'
    ),
    (
    Icons.local_shipping_outlined,
    'Fast & Reliable Delivery',
    'We work with trusted courier partners to get your orders to you quickly and safely.'
    ),
    (
    Icons.support_agent,
    'Customer First',
    'Our support team is always available to help you with questions, orders, and concerns.'
    ),
  ];

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

  // --------------------------------------------------------------- helpers
  Widget _sectionTitle(String label, String title) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: _C.orange,
                fontSize: 10.5,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Row(children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
                color: _C.orange, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: _C.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ]),
      ]);

  // ------------------------------------------------------------------ hero
  Widget _hero() => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      color: _C.searchBg,
      padding: const EdgeInsets.all(20),
      child: Stack(children: [
        const Positioned(
          right: -6,
          bottom: -16,
          child: Icon(Icons.eco, size: 100, color: Color(0x222F7BE8)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('OUR STORY',
              style: TextStyle(
                  color: _C.orange,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('About Shoploc',
              style: TextStyle(
                  color: _C.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(right: 60),
            child: Text(
                'A local passion for quality products, brought online for everyone across India.',
                style: TextStyle(
                    color: _C.grey, fontSize: 12.5, height: 1.45)),
          ),
        ]),
      ]),
    ),
  );

  // ---------------------------------------------------------------- who we are
  Widget _whoWeAre() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Who we are', 'Born Local, Built for Everyone'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border),
            boxShadow: _shadow,
          ),
          child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Shoploc started with a simple belief \u2014 great products shouldn\u2019t be hard to find. We bring quality goods from trusted local sources directly to your doorstep, making shopping easy, reliable, and personal.',
                    style: TextStyle(
                        color: _C.body, fontSize: 13, height: 1.6)),
                SizedBox(height: 12),
                Text(
                    'Based in Kerala, India, we are a team passionate about connecting customers with the best products at fair prices \u2014 with the care and honesty of a local shop, and the convenience of modern e-commerce.',
                    style: TextStyle(
                        color: _C.body, fontSize: 13, height: 1.6)),
              ]),
        ),
      ]);

  // ----------------------------------------------------------------- quote
  Widget _quote() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: _C.orangeLight, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.shopping_bag_outlined,
            color: _C.orange, size: 24),
      ),
      const SizedBox(width: 14),
      const Expanded(
        child: Text('\u201CQuality you can trust, delivered with care.\u201D',
            style: TextStyle(
                color: _C.navy,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.35)),
      ),
    ]),
  );

  // ----------------------------------------------------------------- stats
  Widget _stat(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: _shadow,
      ),
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                color: _C.blue, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _C.grey, fontSize: 11)),
      ]),
    ),
  );

  Widget _stats() => Row(children: [
    _stat('500+', 'Happy\nCustomers'),
    const SizedBox(width: 10),
    _stat('200+', 'Products\nListed'),
    const SizedBox(width: 10),
    _stat('Kerala', 'Proudly\nLocal'),
  ]);

  // ---------------------------------------------------------------- values
  Widget _valueCard((IconData, String, String) v) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _C.border),
      boxShadow: _shadow,
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: _C.blueLight, borderRadius: BorderRadius.circular(14)),
        child: Icon(v.$1, color: _C.blue, size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.$2,
                  style: const TextStyle(
                      color: _C.navy,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(v.$3,
                  style: const TextStyle(
                      color: _C.grey, fontSize: 12, height: 1.5)),
            ]),
      ),
    ]),
  );

  Widget _valuesSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('What we stand for', 'Our Values'),
        const SizedBox(height: 14),
        for (final v in _values) _valueCard(v),
      ]);

  // ------------------------------------------------------------------- cta
  Widget _cta(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      color: _C.blue,
      padding: const EdgeInsets.all(20),
      child: Stack(children: [
        Positioned(
          right: -30,
          bottom: -40,
          child: Container(
            width: 130,
            height: 110,
            decoration: const BoxDecoration(
              color: _C.orange,
              borderRadius:
              BorderRadius.only(topLeft: Radius.circular(80)),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Start Shopping Today',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Explore our collection and find products you\u2019ll love.',
              style: TextStyle(
                  color: Color(0xE6FFFFFF), fontSize: 12.5, height: 1.4)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductListPage(
                        title: 'All Products',
                        products: AppData.products))),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _C.blue,
                elevation: 0,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            child: const Text('Browse All Products',
                style:
                TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    ),
  );

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
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
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: _C.navy),
            onPressed: () => Navigator.pop(context))
            : null,
        title: const Text('About Us',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: _divider(),
      ),
      body: ResponsiveCenter(
        maxWidth: 700,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 28),
          child: Column(children: [
            _hero(),
            const SizedBox(height: 22),
            _whoWeAre(),
            const SizedBox(height: 14),
            _quote(),
            const SizedBox(height: 14),
            _stats(),
            const SizedBox(height: 24),
            _valuesSection(),
            const SizedBox(height: 10),
            _cta(context),
            const SizedBox(height: 20),
            const Text('\u00A9 2026 Shoploc. All rights reserved.',
                style: TextStyle(color: _C.grey, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}