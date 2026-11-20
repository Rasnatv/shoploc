
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Account', style: AppTextStyle.appBarTitle),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.sp(16),
            vertical: Responsive.sp(12),
          ),
          child: Column(
            children: [
              // User Header Card
              Container(
                padding: EdgeInsets.all(Responsive.sp(16)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.sp(30),
                      backgroundColor: AppColors.primaryMuted,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'G',
                        style: AppTextStyle.mainHeading.copyWith(
                          color: AppColors.primary,
                          fontSize: Responsive.sp(24),
                        ),
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
                                .copyWith(fontSize: Responsive.sp(15)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Responsive.sp(2)),
                          Text(
                            isLoggedIn
                                ? email
                                : 'Sign in for personal boutique recommendations',
                            style: AppTextStyle.caption,
                            maxLines: isLoggedIn ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Edit icon removed. Sign In button only when logged out.
                    if (!isLoggedIn) ...[
                      SizedBox(width: Responsive.sp(10)),
                      CustomButton(
                        text: 'Sign In',
                        width: Responsive.sp(80),
                        height: Responsive.sp(36),
                        onPressed: _openAuth,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: Responsive.sp(20)),

              // Quick Orders & Addresses Menu
              _buildMenuCard(
                children: [
                  _buildTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'My Orders',
                    subtitle: 'Track, view, and reorder past purchases',
                    onTap: () {},
                    // widget.onNavigateToOrders ??
                    //         () => _push(const OrdersScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Addresses',
                    subtitle: 'Manage shipping locations',
                    onTap: ()
                    => _push(const AddressListScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'My Wishlist',
                    subtitle: 'View your saved favorite pieces',
                    onTap: ()=>_push(WishlistScreen())
                    // onTap: widget.onNavigateToWishlist ?? () {},
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Order updates and promotional offers',
                    onTap: () {}
                  ),
                ],
              ),

              SizedBox(height: Responsive.sp(16)),

              // Information & Support
              _buildMenuCard(
                children: [
                  _buildTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Questions',
                    subtitle:
                    'Find quick answers about orders, shipping & payments',
                    onTap: () => _push(const QuestionsScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Help & Customer Support',
                    subtitle: 'Enquiry desk, location, phone & message',
                    onTap: () => _push(const EnquiryScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Refund Policy',
                    subtitle: 'Guidelines on returns, damage & reversals',
                    onTap: () => _push(const RefundPolicyScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.cancel_outlined,
                    title: 'Cancellation Policy',
                    subtitle: 'Order cancellation windows & timelines',
                    onTap: () => _push(const CancellationPolicyScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we respect and protect your data',
                    onTap: () => _push(const PrivacyPolicyScreen()),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Shopping and usage agreements',
                    onTap: () => _push(const TermsConditionsScreen(
                    )),
                  ),
                  const Divider(height: 1),
                  _buildTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Shoploc',
                    subtitle: 'Our mission and regional artisan story',
                    onTap: () => _push(const AboutUsScreen()),
                  ),
                ],
              ),

              SizedBox(height: Responsive.sp(20)),

              // Logout Button (if logged in)
              if (isLoggedIn)
                CustomButton(
                  text: 'Sign Out',
                  type: ButtonType.outlined,
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  icon: Icons.logout_rounded,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                            'Are you sure you want to sign out of Shoploc?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _logout();
                            },
                            child: const Text('Sign Out',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              SizedBox(height: Responsive.sp(18)),
            ],
          ),
        ),
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.sp(14),
        vertical: Responsive.sp(2),
      ),
      leading: Container(
        padding: EdgeInsets.all(Responsive.sp(8)),
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: Responsive.sp(20)),
      ),
      title: Text(title, style: AppTextStyle.labelMedium),
      subtitle: Text(subtitle, style: AppTextStyle.caption),
      trailing: Icon(Icons.chevron_right,
          size: Responsive.sp(18), color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}