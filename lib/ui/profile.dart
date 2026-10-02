
import 'package:flutter/material.dart';
import 'package:shoploc/ui/refund_policy.dart';
import '../core/appimages.dart';
import '../core/responsive.dart';
import 'aboutpage.dart';
import 'cancelation_policypage.dart';
import 'contact_us_page.dart';
import 'orderpage.dart';
import 'wishlist_page.dart';

/// Same blue/navy theme as the Home and Wishlist pages.
class _G {
  static const bg = Color(0xFFFCFCFA);
  static const dark = Color(0xFF2C3A55); // titles (navy)
  static const mid = Color(0xFF2F7BE8); // blue accent
  static const soft = Color(0xFFEAF2FC); // header cards
  static const iconBox = Color(0xFFD6E8FB);
  static const border = Color(0xFFF0F0F0);
  static const grey = Color(0xFF8A94A6);
  static const red = Color(0xFFE53935);
}

/// Put the user's photo here (optional – falls back to an icon).
const String _profilePhoto = 'assets/images/profile.png';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _careOpen = true;
  bool _companyOpen = true;

  // ------------------------------------------------------------------ data
  static const _mainMenu = <(IconData, String, String)>[
    (Icons.inventory_2_outlined, 'My Orders', 'Track, view and manage your orders'),
    (Icons.favorite_border, 'My Wishlist', 'Your favourite styles'),
    (Icons.person_outline, 'My Profile', 'View and edit your profile'),
    (Icons.location_on_outlined, 'Saved Addresses', 'Manage your delivery addresses'),
    (Icons.credit_card_outlined, 'Payment Methods', 'Cards, UPI and more'),
  ];

  static const _careItems = <(IconData, String)>[
    (Icons.mail_outline, 'Contact Us'),
    (Icons.inventory_2_outlined, 'Track My Order'),
    (Icons.help_outline, 'FAQs'),
    (Icons.currency_rupee, 'Refund Policy'),
    (Icons.cancel_outlined, 'Cancellation Policy'),
  ];

  static const _companyItems = <(IconData, String)>[
    (Icons.info_outline, 'About Us'),
    (Icons.description_outlined, 'Terms & Conditions'),
  ];

  // ------------------------------------------------------------ navigation
  /// Opens the page for a Customer Care / Company row.
  void _openItem(String title) {
    Widget? page;
    switch (title) {
      case 'Contact Us':
        page = const ContactPage();
        break;
      case 'Track My Order':
        page = const Orderpage();
        break;
      case 'Cancellation Policy':
        page = const CancellationPolicyPage();
        break;
      case 'Refund Policy':
        page = const RefundPolicyPage();
        break;
    // case 'FAQs': page = const FaqPage(); break;
    case 'About Us': page = const AboutPage(); break;
    // case 'Privacy Policy': page = const PrivacyPage(); break;
    }
    if (page == null) return; // page not built yet
    Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
  }

  // --------------------------------------------------------------- helpers
  Widget _iconBox(IconData icon, {double size = 52}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        color: _G.iconBox, borderRadius: BorderRadius.circular(16)),
    child: Icon(icon, color: _G.mid, size: size * 0.46),
  );

  Widget _whiteCard(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _G.border),
    ),
    child: child,
  );

  // ---------------------------------------------------------------- header
  Widget _topBar() => Row(children: [
    Image.asset(
      AppAssets.logo,
      height: 52,
      errorBuilder: (_, __, ___) => const Text('Shoploc',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontFamily: 'serif',
              color: _G.dark)),
    ),
    const Spacer(),
    Stack(clipBehavior: Clip.none, children: [
      const Icon(Icons.notifications_none, size: 28, color: _G.dark),
      Positioned(
        right: -3,
        top: -3,
        child: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration:
          const BoxDecoration(color: _G.red, shape: BoxShape.circle),
          child: const Text('2',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
    const SizedBox(width: 18),
    const Icon(Icons.settings_outlined, size: 26, color: _G.dark),
  ]);

  Widget _profileCard() => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
      color: _G.soft,
      padding: const EdgeInsets.all(16),
      child: Stack(children: [
        const Positioned(
          right: -6,
          bottom: -14,
          child: Icon(Icons.eco, size: 84, color: Color(0x222F7BE8)),
        ),
        Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  _profilePhoto,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 84,
                    height: 84,
                    color: _G.iconBox,
                    child: const Icon(Icons.person,
                        size: 44, color: _G.mid),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _G.mid,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child:
                const Icon(Icons.edit, size: 13, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rasna Rachu',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _G.dark)),
                  const SizedBox(height: 2),
                  const Text('rasna@gmail.com',
                      style: TextStyle(fontSize: 13, color: _G.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFD6E8FB),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Text('Shoploc Customer',
                        style: TextStyle(
                            fontSize: 12,
                            color: _G.dark,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
          ),
          const Icon(Icons.chevron_right, color: _G.dark),
        ]),
      ]),
    ),
  );

  // ------------------------------------------------------------- main menu
  Widget _mainMenuCard() => _whiteCard(Column(
    children: List.generate(_mainMenu.length, (i) {
      final m = _mainMenu[i];
      return Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (m.$2 == 'My Orders') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Orderpage()));
            } else if (m.$2 == 'My Wishlist') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()));
            }
          },
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              _iconBox(m.$1),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.$2,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _G.dark)),
                      const SizedBox(height: 2),
                      Text(m.$3,
                          style: const TextStyle(
                              fontSize: 12, color: _G.grey)),
                    ]),
              ),
              const Icon(Icons.chevron_right, color: _G.dark, size: 22),
            ]),
          ),
        ),
        if (i != _mainMenu.length - 1)
          const Divider(height: 1, indent: 80, color: _G.border),
      ]);
    }),
  ));

  // ---------------------------------------------------- expandable section
  Widget _section({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool open,
    required VoidCallback onToggle,
    required List<(IconData, String)> items,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _G.border),
        ),
        child: Column(children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              color: _G.soft,
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                _iconBox(icon, size: 54),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _G.dark)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: _G.grey)),
                      ]),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child:
                  const Icon(Icons.keyboard_arrow_down, color: _G.dark),
                ),
              ]),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
            open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            secondChild: const SizedBox(width: double.infinity),
            firstChild: Column(
              children: List.generate(items.length, (i) {
                final it = items[i];
                return Column(children: [
                  InkWell(
                    onTap: () => _openItem(it.$2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        SizedBox(
                            width: 40,
                            child: Icon(it.$1, size: 20, color: _G.mid)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(it.$2,
                              style: const TextStyle(
                                  fontSize: 13.5, color: _G.dark)),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 18, color: _G.dark),
                      ]),
                    ),
                  ),
                  if (i != items.length - 1)
                    const Divider(height: 1, indent: 68, color: _G.border),
                ]);
              }),
            ),
          ),
        ]),
      ),
    );
  }

  // -------------------------------------------------------- stay connected
  Widget _social(Widget child, {Color? color, Gradient? gradient}) =>
      Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color, gradient: gradient, shape: BoxShape.circle),
        child: child,
      );

  Widget _stayConnected() => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Container(
      color: _G.soft,
      padding: const EdgeInsets.all(12),
      child: Stack(children: [
        const Positioned(
          right: -4,
          bottom: -14,
          child: Icon(Icons.eco, size: 70, color: Color(0x222F7BE8)),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _iconBox(Icons.share_outlined, size: 54),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stay Connected',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _G.dark)),
                  const SizedBox(height: 2),
                  const Text('Follow us for latest updates, offers & more',
                      style: TextStyle(fontSize: 12, color: _G.grey)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _social(
                        const Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 22),
                        gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Color(0xFFFEDA75),
                              Color(0xFFFA7E1E),
                              Color(0xFFD62976),
                              Color(0xFF962FBF)
                            ])),
                    const SizedBox(width: 14),
                    _social(
                        const Text('f',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                        color: const Color(0xFF3B5998)),
                    const SizedBox(width: 14),
                    _social(
                        const Icon(Icons.chat,
                            color: Colors.white, size: 22),
                        color: const Color(0xFF3DBE56)),
                    const SizedBox(width: 14),
                    _social(
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 26),
                        color: const Color(0xFFD93025)),
                  ]),
                ]),
          ),
          const Icon(Icons.chevron_right, color: _G.dark),
        ]),
      ]),
    ),
  );

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _G.bg,
      child: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 700,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                Responsive.hPad(context), 8, Responsive.hPad(context), 24),
            children: [
              _topBar(),
              const SizedBox(height: 14),
              _profileCard(),
              const SizedBox(height: 14),
              _mainMenuCard(),
              const SizedBox(height: 14),
              _section(
                icon: Icons.headset_mic_outlined,
                title: 'Customer Care',
                subtitle: 'We\u2019re here to help you',
                open: _careOpen,
                onToggle: () => setState(() => _careOpen = !_careOpen),
                items: _careItems,
              ),
              const SizedBox(height: 14),
              _section(
                icon: Icons.apartment_outlined,
                title: 'Company',
                subtitle: 'Know more about Shoploc',
                open: _companyOpen,
                onToggle: () => setState(() => _companyOpen = !_companyOpen),
                items: _companyItems,
              ),
              const SizedBox(height: 14),
              _stayConnected(),
            ],
          ),
        ),
      ),
    );
  }
}