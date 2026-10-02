
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/responsive.dart';

/// Same palette as the Home / Categories / Wishlist / Orders / Profile pages.
class _C {
  static const bg = Color(0xFFFCFCFA);
  static const blue = Color(0xFF2F7BE8);
  static const blueDark = Color(0xFF1F63C8);
  static const blueLight = Color(0xFFD6E8FB);
  static const searchBg = Color(0xFFEAF2FC);
  static const orange = Color(0xFFFFA24C);
  static const orangeLight = Color(0xFFFFE3C9);
  static const navy = Color(0xFF2C3A55);
  static const grey = Color(0xFF8A94A6);
  static const line = Color(0xFFE3E7EE);
  static const error = Color(0xFFD9534F);
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  // Contact details (change here).
  static const _address = 'Deli Kalanad(PO), Kasaragod-671317, Kerala';
  static const _phone = '+91 8848 748 469';
  static const _mail = 'razicdeli@gmail.com';

  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x1A2C3A55), blurRadius: 18, offset: Offset(0, 8)),
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    _toast('$label copied');
  }

  void _send() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    // TODO: send to your backend / email service here.
    _name.clear();
    _email.clear();
    _subject.clear();
    _message.clear();
    _toast('Message sent! We will get back to you soon.');
  }

  Widget _wrap(Widget child) => Center(
    child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700), child: child),
  );

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

  // ------------------------------------------------------------------ hero
  Widget _hero() => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      color: _C.searchBg,
      padding: const EdgeInsets.all(18),
      child: Stack(children: [
        const Positioned(
          right: -6,
          bottom: -14,
          child: Icon(Icons.eco, size: 90, color: Color(0x222F7BE8)),
        ),
        Row(children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.headset_mic_outlined,
                color: _C.blue, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('We\u2019d love to hear\nfrom you',
                      style: TextStyle(
                          color: _C.navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2)),
                  SizedBox(height: 6),
                  Text(
                      'Questions about our products or your order? Our team is here to help.',
                      style: TextStyle(
                          color: _C.grey, fontSize: 12, height: 1.35)),
                ]),
          ),
        ]),
      ]),
    ),
  );

  // --------------------------------------------------------- contact card
  Widget _action(
      IconData icon, String label, String value, Color bg, Color fg,
      VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: fg, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: _C.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(color: _C.grey, fontSize: 10.5)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _contactCard() => Container(
    padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: _shadow,
    ),
    child: Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _action(Icons.phone_in_talk_outlined, 'Call', _phone,
            _C.blueLight, _C.blue, () => _copy(_phone, 'Phone number')),
        _action(Icons.mail_outline, 'Email', _mail, _C.orangeLight,
            _C.orange, () => _copy(_mail, 'Email')),
        _action(Icons.location_on_outlined, 'Visit', 'Kasaragod',
            _C.blueLight, _C.blue, () => _copy(_address, 'Address')),
      ]),
      const SizedBox(height: 14),
      const Divider(height: 1, color: _C.line),
      const SizedBox(height: 12),
      Row(children: [
        const SizedBox(width: 4),
        const Icon(Icons.place, color: _C.orange, size: 18),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(_address,
              style: TextStyle(
                  color: _C.navy, fontSize: 12, height: 1.35)),
        ),
        const SizedBox(width: 8),
        const Text('Tap to copy',
            style: TextStyle(color: _C.grey, fontSize: 10)),
      ]),
    ]),
  );

  // --------------------------------------------------------- section title
  Widget _sectionTitle(String title, String sub) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: _C.orange, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: _C.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(sub,
              style: const TextStyle(color: _C.grey, fontSize: 12)),
        ),
      ]);

  // ------------------------------------------------------------ form field
  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );

  Widget _field(String label, String hint, IconData icon,
      TextEditingController c,
      {TextInputType? type,
        int lines = 1,
        TextInputAction action = TextInputAction.next,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: _C.navy, fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: type,
          minLines: lines,
          maxLines: lines,
          textInputAction: action,
          style: const TextStyle(color: _C.navy, fontSize: 13.5),
          validator: validator ??
                  (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _C.grey, fontSize: 13),
            prefixIcon: lines == 1
                ? Icon(icon, color: _C.blue, size: 20)
                : Padding(
                padding: const EdgeInsets.only(bottom: 72),
                child: Icon(icon, color: _C.blue, size: 20)),
            filled: true,
            fillColor: _C.bg,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            enabledBorder: _border(_C.line),
            focusedBorder: _border(_C.blue, 1.5),
            errorBorder: _border(_C.error),
            focusedErrorBorder: _border(_C.error, 1.5),
          ),
        ),
      ]),
    );
  }

  // ------------------------------------------------------------ send button
  Widget _sendButton() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [
        BoxShadow(
            color: Color(0x4D2F7BE8),
            blurRadius: 14,
            offset: Offset(0, 6)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_C.blue, _C.blueDark]),
          borderRadius: BorderRadius.circular(26),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _send,
          child: const SizedBox(
            height: 52,
            width: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Send Message',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700)),
              SizedBox(width: 8),
              Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ]),
          ),
        ),
      ),
    ),
  );

  // ------------------------------------------------------------- form card
  Widget _formCard() => Container(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: _shadow,
    ),
    child: Form(
      key: _formKey,
      child: Column(children: [
        _field('Full Name', 'Enter your full name', Icons.person_outline,
            _name,
            type: TextInputType.name),
        _field('Email Address', 'Enter your email address',
            Icons.mail_outline, _email,
            type: TextInputType.emailAddress, validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Required';
              final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
              return ok ? null : 'Enter a valid email';
            }),
        _field('Subject', 'What is this regarding?', Icons.edit_outlined,
            _subject),
        _field('Message', 'Type your message here...',
            Icons.chat_bubble_outline, _message,
            type: TextInputType.multiline,
            lines: 5,
            action: TextInputAction.newline),
        const SizedBox(height: 2),
        _sendButton(),
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
        title: const Text('Contact Us',
            style: TextStyle(
                color: _C.navy, fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: _divider(),
      ),
      body: _wrap(SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(pad, 18, pad, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _hero(),
          const SizedBox(height: 16),
          _contactCard(),
          const SizedBox(height: 26),
          _sectionTitle('Send us a message',
              'Fill in the form and we\u2019ll get back to you.'),
          const SizedBox(height: 14),
          _formCard(),
        ]),
      )),
    );
  }
}