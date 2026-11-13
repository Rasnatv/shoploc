import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/authbloc/auth_event.dart';
import '../bloc/authbloc/auth_state.dart';
import '../bloc/profilebloc/profile_bloc.dart';
import '../bloc/profilebloc/profile_event.dart';
import '../bloc/profilebloc/profile_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/custom_button.dart';
import 'address_list_screen.dart';
import 'checkout_auth_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'edit_profile_screen.dart';
import 'enquiry_screen.dart';
import 'static_pages.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onNavigateToOrders;
  final VoidCallback onNavigateToWishlist;

  const ProfileScreen({
    super.key,
    required this.onNavigateToOrders,
    required this.onNavigateToWishlist,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Account', style: AppTextStyle.appBarTitle),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isLoggedIn = authState is AuthenticatedState;

          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final user = profileState is ProfileLoadedState
                  ? profileState.user
                  : (authState is AuthenticatedState ? authState.user : null);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // User Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
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
                            radius: 32,
                            backgroundColor: AppColors.primaryMuted,
                            child: Text(
                              (user?.name.isNotEmpty == true)
                                  ? user!.name.substring(0, 1).toUpperCase()
                                  : 'G',
                              style: AppTextStyle.mainHeading.copyWith(
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Welcome to Shoploc',
                                  style: AppTextStyle.labelLarge.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? 'Sign in for personal boutique recommendations',
                                  style: AppTextStyle.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (user != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(user: user),
                                  ),
                                );
                              },
                            )
                          else
                            CustomButton(
                              text: 'Sign In',
                              width: 80,
                              height: 36,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutAuthScreen(initialIsRegister: false),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Orders & Addresses Menu
                    _buildMenuCard(
                      children: [
                        _buildTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'My Orders',
                          subtitle: 'Track, view, and reorder past purchases',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const OrdersScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.location_on_outlined,
                          title: 'Delivery Addresses',
                          subtitle: 'Manage shipping locations',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddressListScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.favorite_border_rounded,
                          title: 'My Wishlist',
                          subtitle: 'View your saved favorite pieces',
                          onTap: widget.onNavigateToWishlist,
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Order updates and promotional offers',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Information & Support
                    _buildMenuCard(
                      children: [
                        _buildTile(
                          icon: Icons.support_agent_outlined,
                          title: 'Help & Customer Support',
                          subtitle: 'Enquiry desk, location, phone & message',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EnquiryScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About Shoploc',
                          subtitle: 'Our mission and regional artisan story',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.policy_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'How we respect and protect your data',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsPrivacyScreen(
                                  title: 'Privacy Policy',
                                  isPrivacy: true,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildTile(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          subtitle: 'Shopping and usage agreements',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsPrivacyScreen(
                                  title: 'Terms & Conditions',
                                  isPrivacy: false,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Logout Button (if logged in)
                    if (isLoggedIn)
                      CustomButton(
                        text: 'Sign Out',
                        type: ButtonType.outlined,
                        backgroundColor: AppColors.error,
                        textColor: AppColors.error,
                        icon: Icons.logout_rounded,
                        onPressed: () {
                          showDialog(
                            context: context,
                              builder: (ctx) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out of Shoploc?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<AuthBloc>().add(const LogoutEvent());
                                  },
                                  child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 18),
                    Text(
                      'Shoploc Version 1.0.0 (Official Build)',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyle.labelMedium),
      subtitle: Text(subtitle, style: AppTextStyle.caption),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

