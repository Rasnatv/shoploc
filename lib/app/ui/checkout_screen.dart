
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../core/utils/object_factory.dart';
import '../data/models/addressmodel.dart';
import '../data/models/checkoutmodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/network_image_with_fallback.dart';
import 'add_edit_address_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  static T? _find<T extends BlocBase<Object?>>(BuildContext c) {
    try {
      return c.read<T>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckout = _find<CheckoutBloc>(context) != null;
    final hasAddress = _find<AddressBloc>(context) != null;

    if (hasCheckout && hasAddress) return const _CheckoutView();

    return MultiBlocProvider(
      providers: [
        if (!hasCheckout)
          BlocProvider<CheckoutBloc>(create: (_) => CheckoutBloc()),
        if (!hasAddress)
          BlocProvider<AddressBloc>(create: (_) => AddressBloc()),
      ],
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView();

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  static const _cod = 'Cash on Delivery';
  static const _online = 'Online Payment';

  String _payment = _cod;

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(const LoadCheckoutEvent());

    final address = context.read<AddressBloc>();
    address.add(address.state is AddressLoadedState
        ? const RefreshAddressesEvent()
        : const LoadAddressesEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<CheckoutBloc>();
    bloc.add(const RefreshCheckoutEvent());
    context.read<AddressBloc>().add(const RefreshAddressesEvent());
    await bloc.stream.first
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  Future<void> _login() async {
    final ok = await context.push<bool>('/auth',
        extra: {'isRegister': false, 'fromOnboarding': false});
    if (ok == true && mounted) {
      setState(() {});
      context.read<CheckoutBloc>().add(const LoadCheckoutEvent());
      context.read<AddressBloc>().add(const LoadAddressesEvent());
    }
  }

  void _addAddress() {
    final addressBloc = context.read<AddressBloc>();
    Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => BlocProvider<AddressBloc>.value(
        value: addressBloc,
        child: const AddEditAddressScreen(),
      ),
    ));
  }

  void _editAddress(AddressModel a) {
    final addressBloc = context.read<AddressBloc>();
    Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => BlocProvider<AddressBloc>.value(
        value: addressBloc,
        child: AddEditAddressScreen(address: a),
      ),
    ));
  }

  AddressModel? get _selectedAddress {
    final s = context.read<AddressBloc>().state;
    return s is AddressLoadedState ? s.selectedAddress : null;
  }

  void _placeOrder() {
    final address = _selectedAddress;
    if (address == null) {
      AppSnackbar.warning('Please select or add a delivery address.');
      return;
    }
    // TODO: call your "place order" API here and send address.id and _payment.
    AppSnackbar.warning('Place order is not connected yet.');
  }

  String _money(double v) => Formatters.formatPrice(v, showDecimals: true);

  // ---------------- DELETE ADDRESS ----------------
  Future<void> _confirmDelete(
      BuildContext dialogContext, AddressBloc bloc, AddressModel a) async {
    final ok = await showDialog<bool>(
      context: dialogContext,
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
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      bloc.add(DeleteAddressEvent(addressId: a.id));
    }
  }

  // ---------------- ADDRESS BOTTOM SHEET ----------------
  void _showAddressSheet() {
    final addressBloc = context.read<AddressBloc>();
    if (addressBloc.state is! AddressLoadedState) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return BlocProvider<AddressBloc>.value(
          value: addressBloc,
          child: BlocConsumer<AddressBloc, AddressState>(
            listenWhen: (prev, cur) =>
            cur is AddressLoadedState &&
                cur.message != null &&
                (cur.message!.action == AddressAction.delete ||
                    cur.message!.isError) &&
                (prev is! AddressLoadedState ||
                    prev.message?.seq != cur.message!.seq),
            listener: (ctx, state) {
              final m = (state as AddressLoadedState).message!;
              if (m.isError) {
                AppSnackbar.error(m.text);
              } else {
                AppSnackbar.success(m.text);
              }
              // nothing left to choose from -> close the sheet
              if (state.addresses.isEmpty && Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            },
            builder: (ctx, state) {
              if (state is! AddressLoadedState) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final addresses = state.addresses;
              final selectedId = state.selectedAddress?.id;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select Delivery Address',
                                style: AppTextStyle.labelLarge.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            TextButton.icon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add New'),
                              onPressed: () {
                                Navigator.pop(sheetCtx);
                                _addAddress();
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: addresses.length,
                          separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final a = addresses[i];
                            final isSelected = a.id == selectedId;
                            final isBusy = state.busyIds.contains(a.id);

                            return ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                              title: Text(a.fullName,
                                  style: AppTextStyle.labelMedium),
                              subtitle: Text(a.formattedAddress,
                                  style: AppTextStyle.caption),
                              trailing: isBusy
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity:
                                    VisualDensity.compact,
                                    tooltip: 'Edit',
                                    icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: AppColors.primary),
                                    onPressed: () {
                                      Navigator.pop(sheetCtx);
                                      _editAddress(a);
                                    },
                                  ),
                                  IconButton(
                                    visualDensity:
                                    VisualDensity.compact,
                                    tooltip: 'Delete',
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: AppColors.error),
                                    onPressed: () => _confirmDelete(
                                        sheetCtx, addressBloc, a),
                                  ),
                                ],
                              ),
                              onTap: isBusy
                                  ? null
                                  : () {
                                addressBloc.add(
                                    SelectAddressEvent(addressId: a.id));
                                Navigator.pop(sheetCtx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text('Checkout', style: AppTextStyle.appBarTitle)),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listenWhen: (prev, cur) =>
        cur is CheckoutLoadedState &&
            cur.message != null &&
            (prev is! CheckoutLoadedState ||
                prev.message?.seq != cur.message!.seq),
        listener: (context, state) =>
            AppSnackbar.error((state as CheckoutLoadedState).message!.text),
        builder: (context, state) {
          if (state is CheckoutLoadedState) {
            return state.isEmpty ? _emptyCart() : _content(state);
          }
          if (state is CheckoutErrorState) {
            return _errorView(state.errorMessage);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _emptyCart() => EmptyStateView(
    icon: Icons.shopping_bag_outlined,
    title: 'Your cart is empty',
    message: 'Add items to your cart to continue.',
    buttonText: 'Go Back',
    onButtonPressed: () => Navigator.of(context).maybePop(),
  );

  Widget _errorView(String message) {
    if (!_loggedIn) {
      return EmptyStateView(
        icon: Icons.lock_outline_rounded,
        title: 'Login required',
        message: message,
        buttonText: 'Login',
        onButtonPressed: _login,
      );
    }
    return EmptyStateView(
      icon: Icons.error_outline_rounded,
      title: 'Could not load checkout',
      message: message,
      buttonText: 'Retry',
      onButtonPressed: () =>
          context.read<CheckoutBloc>().add(const LoadCheckoutEvent()),
    );
  }

  Widget _content(CheckoutLoadedState state) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('1. Delivery Address'),
                  const SizedBox(height: 8),
                  _addressSection(),
                  const SizedBox(height: 24),
                  _sectionTitle(
                      '2. Items in Order (${state.preview.items.length})'),
                  const SizedBox(height: 8),
                  _itemsPreview(state.preview),
                  const SizedBox(height: 24),
                  _sectionTitle('3. Payment Method'),
                  const SizedBox(height: 8),
                  _paymentSection(),
                  const SizedBox(height: 24),
                  _sectionTitle('4. Price Details'),
                  const SizedBox(height: 8),
                  _priceDetails(state.summary),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        _bottomBar(state.summary),
      ],
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: AppTextStyle.labelLarge
        .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderLight),
    boxShadow: const [
      BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  // ---------------- 1. ADDRESS ----------------
  Widget _addressSection() {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        if (state is AddressLoadedState) {
          final selected = state.selectedAddress;
          if (selected == null) return _noAddressCard();
          return _selectedAddressCard(selected);
        }

        if (state is AddressErrorState) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(state.errorMessage,
                        style: AppTextStyle.bodySmall)),
                TextButton(
                  onPressed: () => context
                      .read<AddressBloc>()
                      .add(const LoadAddressesEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 80,
          decoration: _cardDecoration(),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        );
      },
    );
  }

  Widget _noAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined,
              color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('No address found. Please add a delivery address.',
                style: AppTextStyle.bodySmall),
          ),
          TextButton(onPressed: _addAddress, child: const Text('Add')),
        ],
      ),
    );
  }

  Widget _selectedAddressCard(AddressModel a) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'DELIVER TO',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(a.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.labelLarge),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddressSheet,
                tooltip: 'Edit address',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(a.formattedAddress, style: AppTextStyle.bodySmall),
          const SizedBox(height: 4),
          Text('Mobile: ${a.phone}',
              style: AppTextStyle.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ---------------- 2. ITEMS ----------------
  Widget _itemsPreview(OrderPreviewResponse preview) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: preview.items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = preview.items[i];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 50,
                    height: 60,
                    child: NetworkImageWithFallback(
                      imageUrl: item.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySmall
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (item.size.isNotEmpty) 'Size: ${item.size}',
                          'Qty: ${item.quantity}',
                        ].join(' | '),
                        style: AppTextStyle.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(_money(item.itemTotal), style: AppTextStyle.labelMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- 3. PAYMENT ----------------
  Widget _paymentSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _paymentOption(
            title: 'Cash on Delivery (COD)',
            subtitle: 'Pay at your doorstep via cash or UPI',
            icon: Icons.payments_outlined,
            value: _cod,
          ),
          const Divider(height: 12),
          _paymentOption(
            title: 'Online Payment (UPI, Cards, NetBanking)',
            subtitle: 'Instant secure checkout',
            icon: Icons.account_balance_wallet_outlined,
            value: _online,
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = value == _payment;
    return GestureDetector(
      onTap: () => setState(() => _payment = value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.labelMedium),
                  Text(subtitle, style: AppTextStyle.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 4. PRICE ----------------
  Widget _priceDetails(CheckoutSummaryResponse s) {
    final deliveryText = s.isFreeDelivery
        ? 'FREE'
        : (s.deliveryAmount != null ? _money(s.deliveryAmount!) : s.delivery);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _row('Subtotal', _money(s.subtotal)),
          _row('Tax', _money(s.tax)),
          _row('Delivery Charges', deliveryText,
              color: s.isFreeDelivery ? AppColors.success : null),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyle.labelLarge),
              Text(_money(s.totalAmount),
                  style: AppTextStyle.productPriceLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyle.caption
                  .copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- BOTTOM BAR ----------------
  Widget _bottomBar(CheckoutSummaryResponse s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Payable', style: AppTextStyle.caption),
                Text(_money(s.totalAmount),
                    style: AppTextStyle.productPriceLarge),
              ],
            ),
            const Spacer(),
            CustomButton(
              text: 'Place Order',
              width: 170,
              icon: Icons.lock_outline_rounded,
              onPressed: _placeOrder,
            ),
          ],
        ),
      ),
    );
  }
}