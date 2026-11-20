
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 26),
        ),
        title: const Text('Delete address?'),
        content: Text(
          'The address for ${a.fullName} will be removed from your saved addresses.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
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
                  onPressed: () => Navigator.of(ctx).pop(false),
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
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Delete',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
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
    HapticFeedback.selectionClick();
    context.read<AddressBloc>().add(SelectAddressEvent(addressId: a.id));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        title: Text(widget.selectMode ? 'Select address' : 'My addresses',
            style: AppTextStyle.appBarTitle),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        // add / update success is handled by the form screen
        listenWhen: (prev, cur) =>
        cur is AddressLoadedState &&
            cur.message != null &&
            (cur.message!.action == AddressAction.delete ||
                cur.message!.isError) &&
            (prev is! AddressLoadedState ||
                prev.message?.seq != cur.message!.seq),
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
              buttonText: 'Try again',
              onButtonPressed: () => context
                  .read<AddressBloc>()
                  .add(const LoadAddressesEvent()),
            )
                : EmptyStateView(
              icon: Icons.lock_outline_rounded,
              title: 'Log in to see your addresses',
              message: state.errorMessage,
              buttonText: 'Log in',
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
        message: 'Save an address once and check out faster every time.',
        buttonText: 'Add address',
        onButtonPressed: _openForm,
      );
    }

    final count = state.addresses.length;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              // +1 for the small header row
              itemCount: count + 1,
              separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 10 : 12),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      widget.selectMode
                          ? 'Choose where to deliver ($count saved)'
                          : '$count saved ${count == 1 ? 'address' : 'addresses'}',
                      style: AppTextStyle.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                final a = state.addresses[i - 1];
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: CustomButton(
              text: 'Add new address',
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
    final radius = BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withAlpha(14)
            : AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: highlight ? AppColors.primary : AppColors.borderLight,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selectMode && !isBusy ? onTap : null,
          child: Opacity(
            opacity: isBusy ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _leadingIcon(highlight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    address.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.labelLarge,
                                  ),
                                ),
                                if (highlight) ...[
                                  const SizedBox(width: 8),
                                  _chip('Delivering here'),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              address.formattedAddress,
                              style: AppTextStyle.bodySmall
                                  .copyWith(height: 1.4),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 15, color: AppColors.textTertiary),
                                const SizedBox(width: 6),
                                Text(
                                  address.phone,
                                  style: AppTextStyle.caption.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                Row(
                  children: [
                    Expanded(
                      child: _action(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: AppColors.textSecondary,
                        onPressed: isBusy ? null : onEdit,
                      ),
                    ),
                    Container(
                        width: 1, height: 24, color: AppColors.borderLight),
                    Expanded(
                      child: _action(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: AppColors.error,
                        busy: isBusy,
                        onPressed: isBusy ? null : onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leadingIcon(bool highlight) {
    final active = selectMode ? isSelected : false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primary.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(
        active ? Icons.check_rounded : Icons.location_on_outlined,
        size: 21,
        color: active ? Colors.white : AppColors.primary,
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool busy = false,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          busy
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}