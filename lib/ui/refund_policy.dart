import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/responsive.dart';
import 'contact_us_page.dart';

/// Same palette as the other pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const body = Color(0xFF4B5770);
  static const grey = Color(0xFF8A94A6);
  static const border = Color(0xFFF0F0F0);
  static const line = Color(0xFFE3E7EE);
}

class RefundPolicyPage extends StatefulWidget {
  const RefundPolicyPage({super.key});

  @override
  State<RefundPolicyPage> createState() => _RefundPolicyPageState();
}

class _RefundPolicyPageState extends State<RefundPolicyPage> {
  static const _tabs = [
    'Overview',
    'No Refund',
    'Exceptions',
    'Damaged / Wrong',
    'Failed Payments',
    'Contact Us',
  ];

  final List<GlobalKey> _keys = List.generate(_tabs.length, (_) => GlobalKey());
  int _active = 0;

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  void _jump(int i) {
    setState(() => _active = i);
    final ctx = _keys[i].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.0);
    }
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied')));
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

  // ------------------------------------------------------- content blocks
  Widget _para(String t, {bool muted = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t,
        style: TextStyle(
            color: muted ? _C.grey : _C.body,
            fontSize: 13,
            height: 1.55,
            fontStyle: muted ? FontStyle.italic : FontStyle.normal)),
  );

  Widget _bullets(List<String> items) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      children: [
        for (final t in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: _C.blue, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            color: _C.body, fontSize: 13, height: 1.5)),
                  ),
                ]),
          ),
      ],
    ),
  );

  Widget _steps(List<String> items) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: _C.blueLight, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: _C.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(items[i],
                          style: const TextStyle(
                              color: _C.body, fontSize: 13, height: 1.5)),
                    ),
                  ),
                ]),
          ),
      ],
    ),
  );

  Widget _callout(String t,
      {IconData icon = Icons.info_outline,
        Color bg = _C.orangeLight,
        Color fg = _C.orange}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration:
        BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t,
                style: const TextStyle(
                    color: _C.navy,
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );

  Widget _contactRow(IconData icon, String label, String value,
      {VoidCallback? onTap, IconData? trailing}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: _C.searchBg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(icon, color: _C.blue, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                color: _C.grey, fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(value,
                            style: const TextStyle(
                                color: _C.navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                ),
                if (trailing != null)
                  Icon(trailing, size: 18, color: _C.grey),
              ]),
            ),
          ),
        ),
      );

  // ----------------------------------------------------------- section card
  Widget _section(int i, String title, List<Widget> children) => KeyedSubtree(
    key: _keys[i],
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: _shadow,
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _C.blueLight,
                borderRadius: BorderRadius.circular(12)),
            child: Text('0${i + 1}',
                style: const TextStyle(
                    color: _C.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: _C.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    ),
  );

  // ------------------------------------------------------------ top notice
  Widget _notice() => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      color: _C.searchBg,
      padding: const EdgeInsets.all(16),
      child: Stack(children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.currency_rupee,
                color: _C.blue, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Refund Policy',
                      style: TextStyle(
                          color: _C.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Last updated: October 02, 2026',
                      style: TextStyle(
                          color: _C.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text(
                      'Please read our refund policy carefully before placing an order.',
                      style: TextStyle(
                          color: _C.grey, fontSize: 11.5, height: 1.35)),
                ]),
          ),
        ]),
      ]),
    ),
  );

  // ------------------------------------------------------------ jump chips
  Widget _chips(double pad) => SizedBox(
    height: 50,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
      itemCount: _tabs.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final sel = i == _active;
        return GestureDetector(
          onTap: () => _jump(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? _C.blue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? _C.blue : _C.line),
            ),
            child: Text(_tabs[i],
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : _C.navy)),
          ),
        );
      },
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
        title: const Text('Refund Policy',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: _divider(),
      ),
      body: ResponsiveCenter(
        maxWidth: 700,
        child: Column(children: [
          _chips(pad),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(pad, 6, pad, 28),
              child: Column(children: [
                _notice(),
                const SizedBox(height: 16),

                // 01 Overview
                _section(0, 'Overview', [
                  _para(
                      'At Shoploc, we take great care to ensure every order is '
                          'packed and delivered correctly. This Refund Policy '
                          'explains the circumstances under which refunds may or '
                          'may not be issued.'),
                  _callout(
                      'All sales on Shoploc are final. We do not accept '
                          'returns or exchanges once an order has been confirmed '
                          'and payment processed.'),
                ]),

                // 02 No Refund Policy
                _section(1, 'No Refund Policy', [
                  _para(
                      'Once an order is placed and payment is successfully '
                          'received, the transaction is considered final. Refunds '
                          'will not be issued for:'),
                  _bullets(const [
                    'Change of mind or incorrect selection by the customer.',
                    'Orders placed by mistake after confirmation.',
                    'Delayed delivery due to courier, logistics, or circumstances beyond our control.',
                    'Minor colour or shade variations due to screen display differences.',
                    'Products that have been used, washed, or altered after delivery.',
                  ]),
                  _para(
                      'We encourage you to review your cart carefully before '
                          'completing your purchase.',
                      muted: true),
                ]),

                // 03 Exceptions
                _section(2, 'Exceptions', [
                  _para(
                      'We will consider refund or replacement requests only '
                          'in the following exceptional cases:'),
                  _bullets(const [
                    'The item delivered is defective or damaged due to our error or during shipping.',
                    'You received an incorrect item that does not match your order.',
                    'The item is missing from your delivered package.',
                  ]),
                  _callout(
                      'All exception requests must be raised within 48 hours '
                          'of delivery with supporting photo or video evidence. '
                          'Requests raised after this window will not be '
                          'entertained.',
                      icon: Icons.timer_outlined,
                      bg: _C.searchBg,
                      fg: _C.blue),
                ]),

                // 04 Damaged / Wrong Items
                _section(3, 'Damaged or Wrong Items', [
                  _para(
                      'If you receive a damaged, defective, or incorrect '
                          'product, please follow these steps:'),
                  _steps(const [
                    'Contact our support team within 48 hours of delivery.',
                    'Share clear photos or a short video showing the issue with the product and the packaging.',
                    'Include your Order ID and registered email or phone number in your message.',
                  ]),
                  _para(
                      'Once we review and verify your claim, we reserve the '
                          'right to offer one of the following resolutions at our '
                          'sole discretion:'),
                  _bullets(const [
                    'A replacement of the same product (subject to availability).',
                    'A store credit for a future purchase.',
                    'A refund to your original payment method in exceptional cases only.',
                  ]),
                  _para(
                      'We review all damage claims individually. Approval is '
                          'not guaranteed and is at the discretion of the Shoploc '
                          'team.',
                      muted: true),
                ]),

                // 05 Failed Payment Reversals
                _section(4, 'Failed Payment Reversals', [
                  _para(
                      'If your payment was deducted but your order was not '
                          'confirmed due to a technical failure or payment '
                          'gateway error:'),
                  _bullets(const [
                    'The amount will be automatically reversed to your original payment method within 5\u20137 business days as per Razorpay\u2019s payment gateway policy.',
                    'If the amount is not reversed after 7 business days, please contact us with your transaction reference number.',
                    'We will coordinate with our payment gateway to resolve the issue promptly.',
                  ]),
                ]),

                // 06 How to Contact Us
                _section(5, 'How to Contact Us', [
                  _para(
                      'To raise a refund or damage claim, please reach out to '
                          'us through any of the following channels:'),
                  _contactRow(Icons.mail_outline, 'Email', 'info@shoploc.in',
                      trailing: Icons.copy_rounded,
                      onTap: () => _copy('info@shoploc.in', 'Email')),
                  _contactRow(
                      Icons.chat_bubble_outline, 'Contact Page', 'shoploc.in/contact',
                      trailing: Icons.chevron_right,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContactPage()))),
                  _contactRow(Icons.schedule, 'Business Hours',
                      'Monday \u2013 Saturday, 9:00 AM \u2013 6:00 PM IST'),
                  const SizedBox(height: 2),
                  _para(
                      'Please include your Order ID, contact details, and a '
                          'clear description of the issue. We aim to respond '
                          'within 2 business days.',
                      muted: true),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}