// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/authbloc/auth_bloc.dart';
// import '../bloc/profilebloc/profile_bloc.dart';
// import '../bloc/profilebloc/profile_event.dart';
// import '../bloc/profilebloc/profile_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../widgets/custom_button.dart';
// import 'address_list_screen.dart';
// import 'cancellation_policy_screen.dart';
// import 'checkout_auth_screen.dart';
// import 'edit_profile_screen.dart';
// import 'enquiry_screen.dart';
// import 'faq_screen.dart';
// import 'notifications_screen.dart';
// import 'orders_screen.dart';
// import 'privacy_policy_screen.dart';
// import 'refund_policy_screen.dart';
// import 'static_pages.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final VoidCallback onNavigateToOrders;
//   final VoidCallback onNavigateToWishlist;
//
//   const ProfileScreen({
//     super.key,
//     required this.onNavigateToOrders,
//     required this.onNavigateToWishlist,
//   });
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<ProfileBloc>().add(const LoadProfileEvent());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         title: Text('Account', style: AppTextStyle.appBarTitle),
//       ),
//       body: BlocBuilder<AuthBloc, AuthState>(
//         builder: (context, authState) {
//           final isLoggedIn = authState is AuthenticatedState;
//
//           return BlocBuilder<ProfileBloc, ProfileState>(
//             builder: (context, profileState) {
//               final user = profileState is ProfileLoadedState
//                   ? profileState.user
//                   : (authState is AuthenticatedState ? authState.user : null);
//
//               return SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Column(
//                   children: [
//                     // User Header Card
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: AppColors.borderLight),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: AppColors.shadow,
//                             blurRadius: 8,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 32,
//                             backgroundColor: AppColors.primaryMuted,
//                             // child: Text(
//                             //   (user?.name.isNotEmpty == true)
//                             //       ? user!.name.substring(0, 1).toUpperCase()
//                             //       : 'G',
//                             //   style: AppTextStyle.mainHeading.copyWith(
//                             //     color: AppColors.primary,
//                             //     fontSize: 24,
//                             //   ),
//                             ),
//                           // ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Text(
//                                 //   user?.name ?? 'Welcome to Shoploc',
//                                 //   style: AppTextStyle.labelLarge.copyWith(fontSize: 16),
//                                 // ),
//                                 // const SizedBox(height: 2),
//                                 // Text(
//                                 //   user?.email ?? 'Sign in for personal boutique recommendations',
//                                 //   style: AppTextStyle.caption,
//                                 //   maxLines: 1,
//                                 //   overflow: TextOverflow.ellipsis,
//                                 // ),
//                               ],
//                             ),
//                           ),
//                           if (user != null)
//                             IconButton(
//                               icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
//                               onPressed: () {
//                                 // Navigator.of(context).push(
//                                 //   MaterialPageRoute(
//                                 //     builder: (_) => EditProfileScreen(user: user),
//                                 //   ),
//                                 //);
//                               },
//                             )
//                           else
//                             CustomButton(
//                               text: 'Sign In',
//                               width: 80,
//                               height: 36,
//                               onPressed: () {
//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (_) => const CheckoutAuthScreen(initialIsRegister: false),
//                                   ),
//                                 );
//                               },
//                             ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Quick Orders & Addresses Menu
//                     _buildMenuCard(
//                       children: [
//                         _buildTile(
//                           icon: Icons.receipt_long_outlined,
//                           title: 'My Orders',
//                           subtitle: 'Track, view, and reorder past purchases',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const OrdersScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.location_on_outlined,
//                           title: 'Delivery Addresses',
//                           subtitle: 'Manage shipping locations',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const AddressListScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.favorite_border_rounded,
//                           title: 'My Wishlist',
//                           subtitle: 'View your saved favorite pieces',
//                           onTap: widget.onNavigateToWishlist,
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.notifications_none_rounded,
//                           title: 'Notifications',
//                           subtitle: 'Order updates and promotional offers',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Information & Support
//                     _buildMenuCard(
//                       children: [
//                         _buildTile(
//                           icon: Icons.help_outline_rounded,
//                           title: 'Questions',
//                           subtitle: 'Find quick answers about orders, shipping & payments',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const QuestionsScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.support_agent_outlined,
//                           title: 'Help & Customer Support',
//                           subtitle: 'Enquiry desk, location, phone & message',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const EnquiryScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.currency_rupee_rounded,
//                           title: 'Refund Policy',
//                           subtitle: 'Guidelines on returns, damage & reversals',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const RefundPolicyScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.cancel_outlined,
//                           title: 'Cancellation Policy',
//                           subtitle: 'Order cancellation windows & timelines',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const CancellationPolicyScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.policy_outlined,
//                           title: 'Privacy Policy',
//                           subtitle: 'How we respect and protect your data',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.description_outlined,
//                           title: 'Terms & Conditions',
//                           subtitle: 'Shopping and usage agreements',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => const TermsPrivacyScreen(
//                                   title: 'Terms & Conditions',
//                                   isPrivacy: false,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         const Divider(height: 1),
//                         _buildTile(
//                           icon: Icons.info_outline_rounded,
//                           title: 'About Shoploc',
//                           subtitle: 'Our mission and regional artisan story',
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(builder: (_) => const AboutUsScreen()),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Logout Button (if logged in)
//                     if (isLoggedIn)
//                       CustomButton(
//                         text: 'Sign Out',
//                         type: ButtonType.outlined,
//                         backgroundColor: AppColors.error,
//                         textColor: AppColors.error,
//                         icon: Icons.logout_rounded,
//                         onPressed: () {
//                           showDialog(
//                             context: context,
//                               builder: (ctx) => AlertDialog(
//                               title: const Text('Sign Out'),
//                               content: const Text('Are you sure you want to sign out of Shoploc?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 // TextButton(
//                                 //   onPressed: () {
//                                 //     Navigator.pop(ctx);
//                                 //     context.read<AuthBloc>().add(const LogoutEvent());
//                                 //   },
//                                 //   child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
//                                 // ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//
//                     const SizedBox(height: 18),
//                     Text(
//                       'Shoploc Version 1.0.0 (Official Build)',
//                       style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildMenuCard({required List<Widget> children}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: AppColors.borderLight),
//         boxShadow: const [
//           BoxShadow(
//             color: AppColors.shadow,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }
//
//   Widget _buildTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: const BoxDecoration(
//           color: AppColors.surfaceVariant,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: AppColors.primary, size: 20),
//       ),
//       title: Text(title, style: AppTextStyle.labelMedium),
//       subtitle: Text(subtitle, style: AppTextStyle.caption),
//       trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
//       onTap: onTap,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shoploc/app/core/theme/app_colors.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = ObjectFactory().prefs;

  bool _loggingOut = false;

  bool get _loggedIn => _prefs.isLoggedIn() == true;

  /// Opens the Login / Register screen, then refreshes this page.
  Future<void> _openAuth(bool isRegister) async {
    await context.push<bool>('/auth', extra: {
      'isRegister': isRegister,
      'fromOnboarding': false,
    });
    if (mounted) setState(() {});
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok != true || _loggingOut) return;
    await _logout();
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);

    try {
      // 1. Clear stored session. MUST be awaited, otherwise the UI
      //    rebuilds before the values are actually removed.
      await _prefs.clearSession(); // token, user id, name, email, isLoggedIn

      // 2. If ApiClient caches the token (Dio header / interceptor field),
      //    clear it too. Uncomment once you add this method to ApiClient.
      // ObjectFactory().apiClient.clearToken();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }

    if (!mounted) return;

    // 3. Rebuild this page -> shows the guest view.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    // Optional: if other tabs (Home / Cart) still show old user data,
    // reset the whole stack instead of just calling setState:
    // context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Profile')),
      body: _loggedIn ? _loggedInView() : _guestView(),
    );
  }

  // ---------------- LOGGED IN ----------------
  Widget _loggedInView() {
    final name = _prefs.getUserName() ?? '';
    final email = _prefs.getUserEmail() ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.brandBlue,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Menu items (add real screens later)
        _menuTile(Icons.receipt_long_outlined, 'My Orders', () {}),
        _menuTile(Icons.favorite_border_rounded, 'Wishlist', () {}),
        _menuTile(Icons.location_on_outlined, 'Saved Addresses', () {}),
        _menuTile(Icons.help_outline_rounded, 'Help & Support', () {}),

        const SizedBox(height: 20),

        // Logout button
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _loggingOut ? null : _confirmLogout,
            icon: _loggingOut
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout_rounded),
            label: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brandBlue),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }

  // ---------------- GUEST ----------------
  Widget _guestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            const Text(
              'You are not logged in',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _openAuth(false),
                child: const Text('Login'),
              ),
            ),
            TextButton(
              onPressed: () => _openAuth(true),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}