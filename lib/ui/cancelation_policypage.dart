import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/responsive.dart';

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

class CancellationPolicyPage extends StatefulWidget {
  const CancellationPolicyPage({super.key});

  @override
  State<CancellationPolicyPage> createState() => _CancellationPolicyPageState();
}

class _CancellationPolicyPageState extends State<CancellationPolicyPage> {
  static const _tabs = [
    'Overview',
    'No Cancellation',
    'After Dispatch',
    'By Shoploc',
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
        const Positioned(
          right: -6,
          bottom: -14,
          child: Icon(Icons.eco, size: 80, color: Color(0x222F7BE8)),
        ),
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.cancel_outlined,
                color: _C.blue, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cancellation Policy',
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
                      'Please read carefully before placing your order.',
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
        title: const Text('Cancellation Policy',
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
                      'At Shoploc, all orders are processed immediately after '
                          'payment confirmation. Due to the nature of our '
                          'operations, orders cannot be cancelled, modified, or '
                          'reversed once placed.'),
                  _callout(
                      'All sales are final. We do not accept order '
                          'cancellations, returns, or exchanges under any '
                          'circumstances. Please review your order carefully '
                          'before confirming your purchase.'),
                ]),

                // 02 No Cancellation Policy
                _section(1, 'No Cancellation Policy', [
                  _para(
                      'Once an order is placed and payment is successfully '
                          'processed, the order is considered confirmed and '
                          'cannot be cancelled for any reason, including:'),
                  _bullets(const [
                    'Change of mind or accidental order placement.',
                    'Selecting the wrong product, size, colour, or quantity.',
                    'Finding a lower price elsewhere after ordering.',
                    'Delays in delivery due to courier, logistics, or circumstances beyond our control.',
                    'Personal emergencies or circumstances after order placement.',
                  ]),
                  _para(
                      'We strongly urge all customers to carefully review '
                          'their cart, product details, and delivery address '
                          'before completing checkout.',
                      muted: true),
                ]),

                // 03 After Dispatch
                _section(2, 'After Dispatch', [
                  _para(
                      'Once your order is dispatched and handed over to our '
                          'courier partner, it is entirely in transit and no '
                          'action can be taken on it by Shoploc. Specifically:'),
                  _bullets(const [
                    'We cannot stop, redirect, or recall the shipment.',
                    'Refusing delivery at the door does not entitle you to a refund or cancellation. The order will be marked as undelivered and no further action will be taken.',
                    'Packages returned to us due to an incorrect address or failed delivery attempts will not be re-dispatched or refunded.',
                  ]),
                ]),

                // 04 Cancellation by Shoploc
                _section(3, 'Cancellation by Shoploc', [
                  _para(
                      'In rare circumstances, Shoploc may need to cancel your '
                          'order. This may happen if:'),
                  _bullets(const [
                    'The product goes out of stock after your order was placed.',
                    'There is an error in the product listing, such as an incorrect price or description.',
                    'We are unable to verify your payment or delivery address.',
                    'There are suspicions of fraudulent activity associated with the order.',
                  ]),
                  _para(
                      'In all such cases, you will be notified promptly via '
                          'email and any payment collected will be fully reversed '
                          'to your original payment method within 5\u20137 '
                          'business days.'),
                  _callout(
                      'Cancellations initiated by Shoploc will always result '
                          'in a full reversal of any payment collected. This is '
                          'the only scenario where a payment reversal is issued.',
                      icon: Icons.check_circle_outline,
                      bg: _C.searchBg,
                      fg: _C.blue),
                ]),

                // 05 Failed Payment Reversals
                _section(4, 'Failed Payment Reversals', [
                  _para(
                      'If your payment was deducted but your order was not '
                          'confirmed due to a technical failure or payment '
                          'gateway error, this is not a purchase \u2014 your money '
                          'will be returned automatically:'),
                  _bullets(const [
                    'The amount will be auto-reversed to your original payment method within 5\u20137 business days as per Razorpay\u2019s payment gateway policy.',
                    'If the amount is not reversed after 7 business days, contact us with your transaction reference number and we will coordinate with Razorpay to resolve it.',
                  ]),
                  _callout(
                      'Please note: a failed payment reversal is different '
                          'from an order cancellation. No order is created for '
                          'failed payments.'),
                ]),

                // 06 Contact Us
                _section(5, 'Contact Us', [
                  _para(
                      'If you have questions about your order or a payment '
                          'issue, please reach out to us:'),
                  _contactRow(Icons.mail_outline, 'Email', 'info@shoploc.in',
                      trailing: Icons.copy_rounded,
                      onTap: () => _copy('info@shoploc.in', 'Email')),
                  _contactRow(Icons.chat_bubble_outline, 'Contact Page',
                      'shoploc.in/contact',
                      trailing: Icons.chevron_right,
                      onTap:(){}),
                          // //() => Navigator.push(
                          // context,
                          // MaterialPageRoute(
                          //     builder: (_) => const ContactPage()))),
                  _contactRow(Icons.schedule, 'Business Hours',
                      'Monday \u2013 Saturday, 9:00 AM \u2013 6:00 PM IST'),
                  const SizedBox(height: 2),
                  _para(
                      'We aim to respond to all queries within 2 business '
                          'days.',
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