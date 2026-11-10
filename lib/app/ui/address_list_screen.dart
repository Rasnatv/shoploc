import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state_view.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const LoadAddressesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('My Addresses', style: AppTextStyle.appBarTitle),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is AddressLoadedState) {
            if (state.addresses.isEmpty) {
              return EmptyStateView(
                icon: Icons.location_on_outlined,
                title: 'No Addresses Saved',
                message: 'Add your delivery addresses to enjoy faster and easier checkout.',
                buttonText: 'Add New Address',
                onButtonPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                  );
                },
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.addresses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final addr = state.addresses[index];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: addr.isDefault ? AppColors.primary : AppColors.borderLight,
                            width: addr.isDefault ? 1.5 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: addr.isDefault
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    addr.addressType.toUpperCase(),
                                    style: AppTextStyle.badgeText.copyWith(
                                      color: addr.isDefault
                                          ? AppColors.textLight
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(DEFAULT)',
                                    style: AppTextStyle.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddEditAddressScreen(address: addr),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Address?'),
                                        content: Text('Remove "${addr.fullName}" address?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              context.read<AddressBloc>().add(
                                                    DeleteAddressEvent(addressId: addr.id),
                                                  );
                                            },
                                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(addr.fullName, style: AppTextStyle.labelLarge),
                            const SizedBox(height: 4),
                            Text(addr.formattedAddress, style: AppTextStyle.bodySmall),
                            const SizedBox(height: 4),
                            Text('Phone: ${addr.mobileNumber}',
                                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),



                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Add New Address',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
