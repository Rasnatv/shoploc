
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';
import 'package:shoploc/app/ui/termsandcondition.dart';
import 'package:shoploc/app/ui/wishlist_screen.dart';
import 'package:shoploc/app/widgets/appsnackbar.dart';
import 'package:shoploc/app/widgets/responsive.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/custom_button.dart';
import 'address_list_screen.dart';
import 'cancellation_policy_screen.dart';
import 'enquiry_screen.dart';
import 'faq_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'privacy_policy_screen.dart';
import 'refund_policy_screen.dart';
import 'static_pages.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToWishlist;

  const ProfileScreen({
    super.key,
    this.onNavigateToOrders,
    this.onNavigateToWishlist,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = ObjectFactory().prefs;
  bool _loggingOut = false;

  bool get _isLoggedIn => _prefs.isLoggedIn() == true;

  Future<void> _openAuth() async {
    await context.push<bool>('/auth', extra: {
      'isRegister': false,
      'fromOnboarding': false,
    });
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      await _prefs.clearSession(); // token, user id, name, email, isLoggedIn

      if (mounted) {
        context.read<WishlistBloc>().add(const ResetWishlistEvent());
        context.read<CartBloc>().add(const ResetCartEvent());
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }

    if (!mounted) return;
    AppSnackbar.success('Logged out successfully');
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded,
              color: AppColors.error, size: 24),
        ),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to see your orders and wishlist.',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _logout();
                  },
                  child: const Text('Sign out',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final isLoggedIn = _isLoggedIn;
    final name = isLoggedIn ? (_prefs.getUserName() ?? '') : '';
    final email = isLoggedIn ? (_prefs.getUserEmail() ?? '') : '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Account', style: AppTextStyle.appBarTitle),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Responsive.sp(16),
            Responsive.sp(16),
            Responsive.sp(16),
            Responsive.sp(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isLoggedIn: isLoggedIn, name: name, email: email),

              SizedBox(height: Responsive.sp(24)),

              _buildSectionTitle('Shopping'),
              _buildMenuCard(
                children: [
                  _buildTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'My orders',
                    subtitle: 'Track, view and reorder past purchases',
                    onTap: () {},
                    // widget.onNavigateToOrders ??
                    //         () => _push(const OrdersScreen()),
                  ),
                  _buildTile(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery addresses',
                    subtitle: 'Manage your shipping locations',
                    onTap: () => _push(const AddressListScreen()),
                  ),
                  _buildTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'My wishlist',
                    subtitle: 'Pieces you have saved',
                    onTap: () => _push(WishlistScreen()),
                    // onTap: widget.onNavigateToWishlist ?? () {},
                  ),
                  _buildTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Order updates and offers',
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: Responsive.sp(24)),

              _buildSectionTitle('Help and policies'),
              _buildMenuCard(
                children: [
                  _buildTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Questions',
                    subtitle: 'Answers on orders, shipping and payments',
                    onTap: () => _push(const QuestionsScreen()),
                  ),
                  _buildTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Help and customer support',
                    subtitle: 'Enquiry desk, location, phone and message',
                    onTap: () => _push(const EnquiryScreen()),
                  ),
                  _buildTile(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Refund policy',
                    subtitle: 'Returns, damage and reversals',
                    onTap: () => _push(const RefundPolicyScreen()),
                  ),
                  _buildTile(
                    icon: Icons.cancel_outlined,
                    title: 'Cancellation policy',
                    subtitle: 'Cancellation windows and timelines',
                    onTap: () => _push(const CancellationPolicyScreen()),
                  ),
                  _buildTile(
                    icon: Icons.policy_outlined,
                    title: 'Privacy policy',
                    subtitle: 'How we protect your data',
                    onTap: () => _push(const PrivacyPolicyScreen()),
                  ),
                  _buildTile(
                    icon: Icons.description_outlined,
                    title: 'Terms and conditions',
                    subtitle: 'Shopping and usage agreements',
                    onTap: () => _push(const TermsConditionsScreen()),
                  ),
                  _buildTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Shoploc',
                    subtitle: 'Our mission and regional artisan story',
                    onTap: () => _push(const AboutUsScreen()),
                  ),
                ],
              ),

              if (isLoggedIn) ...[
                SizedBox(height: Responsive.sp(24)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: AppColors.error.withAlpha(90)),
                      padding:
                      EdgeInsets.symmetric(vertical: Responsive.sp(14)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _loggingOut ? null : _confirmSignOut,
                    icon: _loggingOut
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Sign out',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildHeader({
    required bool isLoggedIn,
    required String name,
    required String email,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.sp(18)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ring around the avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withAlpha(70), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: Responsive.sp(30),
                  backgroundColor: AppColors.primaryMuted,
                  child: isLoggedIn
                      ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AppTextStyle.mainHeading.copyWith(
                      color: AppColors.primary,
                      fontSize: Responsive.sp(24),
                    ),
                  )
                      : Icon(Icons.person_outline_rounded,
                      color: AppColors.primary, size: Responsive.sp(30)),
                ),
              ),
              SizedBox(width: Responsive.sp(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn
                          ? (name.isNotEmpty ? name : 'User')
                          : 'Welcome to Shoploc',
                      style: AppTextStyle.labelLarge
                          .copyWith(fontSize: Responsive.sp(17)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.sp(3)),
                    Text(
                      isLoggedIn
                          ? email
                          : 'Sign in to get recommendations from local boutiques',
                      style: AppTextStyle.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: isLoggedIn ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLoggedIn) ...[
            SizedBox(height: Responsive.sp(16)),
            CustomButton(
              text: 'Sign in',
              height: Responsive.sp(44),
              onPressed: _openAuth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(
          left: Responsive.sp(4), bottom: Responsive.sp(10)),
      child: Text(
        text,
        style: AppTextStyle.labelLarge.copyWith(
          fontSize: Responsive.sp(14),
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Rounded card that clips tile ripples and puts an inset divider between
  /// tiles (the divider lines up with the text, not the icon).
  Widget _buildMenuCard({required List<Widget> children}) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(Divider(
          height: 1,
          thickness: 1,
          indent: Responsive.sp(14 + 40 + 12),
          color: AppColors.borderLight,
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: spaced),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.sp(14),
          vertical: Responsive.sp(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: AppColors.primary, size: Responsive.sp(20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyle.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: Responsive.sp(22), color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}