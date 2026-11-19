
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../data/models/addressmodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state_view.dart';
import 'add_edit_address_screen.dart';

/// Saved addresses.
/// [selectMode] = true is used from checkout: tapping an address chooses it
/// as the delivery address and closes the screen.
class AddressListScreen extends StatefulWidget {
  final bool selectMode;

  const AddressListScreen({super.key, this.selectMode = false});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AddressBloc>();
    bloc.add(bloc.state is AddressLoadedState
        ? const RefreshAddressesEvent()
        : const LoadAddressesEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<AddressBloc>();
    bloc.add(const RefreshAddressesEvent());
    // never wait forever if nothing is emitted
    await bloc.stream.first
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  Future<void> _login() async {
    final ok = await context.push<bool>('/auth',
        extra: {'isRegister': false, 'fromOnboarding': false});
    if (ok == true && mounted) {
      setState(() {});
      context.read<AddressBloc>().add(const LoadAddressesEvent());
    }
  }

  void _openForm([AddressModel? address]) {
    final addressBloc = context.read<AddressBloc>();
    Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => BlocProvider<AddressBloc>.value(
        value: addressBloc,
        child: AddEditAddressScreen(address: address),
      ),
    ));
  }

  Future<void> _confirmDelete(AddressModel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: Text('Delete the address of ${a.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AddressBloc>().add(DeleteAddressEvent(addressId: a.id));
    }
  }

  void _choose(AddressModel a) {
    if (!widget.selectMode) return;
    context.read<AddressBloc>().add(SelectAddressEvent(addressId: a.id));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Address' : 'Delivery Addresses',
            style: AppTextStyle.appBarTitle),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        // add / update success is handled by the form screen
        listenWhen: (prev, cur) =>
        cur is AddressLoadedState &&
            cur.message != null &&
            (cur.message!.action == AddressAction.delete || cur.message!.isError) &&
            (prev is! AddressLoadedState || prev.message?.seq != cur.message!.seq),
        listener: (context, state) {
          final m = (state as AddressLoadedState).message!;
          if (m.isError) {
            AppSnackbar.error(m.text);
          } else {
            AppSnackbar.success(m.text);
          }
        },
        builder: (context, state) {
          if (state is AddressLoadedState) return _loaded(state);

          if (state is AddressErrorState) {
            return _loggedIn
                ? EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: 'Could not load addresses',
              message: state.errorMessage,
              buttonText: 'Retry',
              onButtonPressed: () => context
                  .read<AddressBloc>()
                  .add(const LoadAddressesEvent()),
            )
                : EmptyStateView(
              icon: Icons.lock_outline_rounded,
              title: 'Login required',
              message: state.errorMessage,
              buttonText: 'Login',
              onButtonPressed: _login,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _loaded(AddressLoadedState state) {
    if (state.isEmpty) {
      return EmptyStateView(
        icon: Icons.location_off_outlined,
        title: 'No saved addresses',
        message: 'Add a delivery address to speed up checkout.',
        buttonText: 'Add Address',
        onButtonPressed: _openForm,
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = state.addresses[i];
                return _AddressCard(
                  address: a,
                  selectMode: widget.selectMode,
                  isSelected: a.id == state.selectedAddress?.id,
                  isBusy: state.busyIds.contains(a.id),
                  onTap: () => _choose(a),
                  onEdit: () => _openForm(a),
                  onDelete: () => _confirmDelete(a),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: SafeArea(
            top: false,
            child: CustomButton(
              text: 'Add New Address',
              icon: Icons.add_rounded,
              onPressed: _openForm,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool selectMode;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = selectMode && isSelected;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: selectMode ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight ? AppColors.primary : AppColors.borderLight,
              width: highlight ? 1.4 : 1,
            ),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selectMode
                        ? (isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off)
                        : Icons.location_on_outlined,
                    size: 22,
                    color: highlight ? AppColors.primary : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.fullName, style: AppTextStyle.labelLarge),
                        const SizedBox(height: 4),
                        Text(address.formattedAddress, style: AppTextStyle.bodySmall),
                        const SizedBox(height: 4),
                        Text('Mobile: ${address.phone}',
                            style: AppTextStyle.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: isBusy ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: isBusy ? null : onDelete,
                    icon: isBusy
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
