
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../bloc/buynowpricesummary/pricysummary_bloc.dart';
import '../bloc/buynowpricesummary/pricysummary_event.dart';
import '../bloc/buynowpricesummary/pricysummary_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../data/models/addressmodel.dart';
import '../router/app_router.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/network_image_with_fallback.dart';
import '../widgets/responsive.dart';

/// Data passed from the product page to the Confirm Order screen:
/// context.push(AppRouter.buyNow, extra: BuyNowArgs(...));
class BuyNowArgs {
  final int productId;
  final String name;
  final String image;
  final int colorId;
  final String colorName;
  final String size;
  final int quantity;

  /// Stock of the selected colour / size (upper limit for the quantity).
  final int maxQuantity;

  /// Price the customer pays for ONE piece (shown on the product card only).
  final double price;

  /// Original (MRP) price of ONE piece. Same as [price] when there is no offer.
  final double originalPrice;

  /// Not used any more: delivery now comes from POST /product/price-summary.
  final double shippingCharge;

  const BuyNowArgs({
    required this.productId,
    required this.name,
    required this.image,
    required this.colorId,
    required this.colorName,
    required this.size,
    required this.quantity,
    required this.maxQuantity,
    required this.price,
    required this.originalPrice,
    required this.shippingCharge,
  });
}

/// "Buy Now" -> Confirm Order:
///   1. Delivery address   2. Product   3. Price details (from the API)
/// The cart is not used, so other cart items never get mixed into this order.
class ConfirmOrderScreen extends StatefulWidget {
  final BuyNowArgs args;
  const ConfirmOrderScreen({super.key, required this.args});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  late int _qty;

  /// Owned by this screen (no change to main.dart needed).
  final PriceSummaryBloc _priceBloc = PriceSummaryBloc();

  BuyNowArgs get _a => widget.args;

  @override
  void initState() {
    super.initState();
    _qty = _a.quantity.clamp(1, _maxQty).toInt();

    final address = context.read<AddressBloc>();
    address.add(address.state is AddressLoadedState
        ? const RefreshAddressesEvent()
        : const LoadAddressesEvent());

    _loadPrice();
  }

  @override
  void dispose() {
    _priceBloc.close();
    super.dispose();
  }

  /// Asks the API for the price of the current quantity.
  void _loadPrice() => _priceBloc
      .add(LoadPriceSummaryEvent(productId: _a.productId, quantity: _qty));

  // ---------------- responsive helpers ----------------
  double get _scale =>
      (Responsive.screenWidth.clamp(320.0, 480.0)).toDouble() / 390.0;
  double _w(double v) => v * _scale;

  double get _maxContentWidth =>
      Responsive.value(mobile: double.infinity, tablet: 640.0, desktop: 720.0);

  double get _pagePadding =>
      Responsive.value(mobile: _w(16), tablet: 24.0, desktop: 24.0);

  Widget _centered(Widget child) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _maxContentWidth),
      child: child,
    ),
  );

  // ---------------- helpers ----------------
  int get _maxQty => _a.maxQuantity > 0 ? _a.maxQuantity : 99;

  String _money(double v) => Formatters.formatPrice(v, showDecimals: true);

  /// The price on screen belongs to the quantity on screen, and is not
  /// being refreshed -> safe to place the order.
  bool get _priceReady {
    final s = _priceBloc.state;
    return s is PriceSummaryLoadedState &&
        !s.isRefreshing &&
        s.quantity == _qty;
  }

  // ---------------- actions ----------------
  void _changeQty(int delta) {
    final next = _qty + delta;
    if (next < 1) return;
    if (next > _maxQty) {
      AppSnackbar.warning('Only $_maxQty available in stock');
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _qty = next);
    _loadPrice(); // price details come from the API
  }

  /// Opens the saved addresses list in "select" mode (tap one to choose it).
  void _changeAddress() => context
      .push<bool>(AppRouter.addresses, extra: {'selectMode': true});

  void _addAddress() => context.push<bool>(AppRouter.addressAdd);

  AddressModel? get _selectedAddress {
    final s = context.read<AddressBloc>().state;
    return s is AddressLoadedState ? s.selectedAddress : null;
  }

  void _confirm() {
    final address = _selectedAddress;
    if (address == null) {
      AppSnackbar.warning('Please select or add a delivery address.');
      return;
    }
    if (!_priceReady) {
      AppSnackbar.warning('Price details are still loading.');
      return;
    }
    // TODO: call your "place order" API with:
    //   address.id, _a.productId, _a.colorId, _a.size, _qty
    AppSnackbar.warning('Place order is not connected yet.');
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 16,
        title: Text('Confirm Order', style: AppTextStyle.appBarTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: _centered(
              SingleChildScrollView(
                padding: EdgeInsets.all(_pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('1. Delivery Address'),
                    SizedBox(height: _w(8)),
                    _addressSection(),
                    SizedBox(height: _w(24)),
                    _sectionTitle('2. Product Details'),
                    SizedBox(height: _w(8)),
                    _productCard(),
                    SizedBox(height: _w(24)),
                    _sectionTitle('3. Price Details'),
                    SizedBox(height: _w(8)),
                    _priceDetails(),
                    SizedBox(height: _w(32)),
                  ],
                ),
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: AppTextStyle.labelLarge
        .copyWith(fontSize: Responsive.sp(15), fontWeight: FontWeight.w700),
  );

  BoxDecoration _card() => BoxDecoration(
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
          return selected == null
              ? _noAddressCard()
              : _selectedAddressCard(selected);
        }

        if (state is AddressErrorState) {
          return Container(
            padding: EdgeInsets.all(_w(16)),
            decoration: _card(),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error),
                SizedBox(width: _w(12)),
                Expanded(
                  child: Text(state.errorMessage,
                      style: AppTextStyle.bodySmall),
                ),
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
          height: _w(80),
          decoration: _card(),
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
      padding: EdgeInsets.all(_w(16)),
      decoration: _card(),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined,
              color: AppColors.textTertiary),
          SizedBox(width: _w(12)),
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
      padding: EdgeInsets.all(_w(14)),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: _w(8), vertical: _w(3)),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DELIVER TO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: Responsive.sp(10),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: _w(8)),
              Expanded(
                child: Text(a.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.labelLarge),
              ),
              TextButton(
                onPressed: _changeAddress,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: _w(8)),
                ),
                child: const Text('Change'),
              ),
            ],
          ),
          SizedBox(height: _w(6)),
          Text(a.formattedAddress, style: AppTextStyle.bodySmall),
          SizedBox(height: _w(4)),
          Text('Mobile: ${a.phone}',
              style: AppTextStyle.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ---------------- 2. PRODUCT ----------------
  Widget _productCard() {
    final imgW = Responsive.value(
        mobile: _w(72), tablet: 84.0, desktop: 90.0);
    final hasOffer = _a.originalPrice > _a.price && _a.price > 0;

    return Container(
      padding: EdgeInsets.all(_w(12)),
      decoration: _card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: imgW,
              height: imgW * 1.2,
              child: NetworkImageWithFallback(
                imageUrl: _a.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: _w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _a.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: _w(4)),
                Text(
                  [
                    if (_a.colorName.isNotEmpty) 'Color: ${_a.colorName}',
                    if (_a.size.isNotEmpty) 'Size: ${_a.size}',
                  ].join(' | '),
                  style: AppTextStyle.caption,
                ),
                SizedBox(height: _w(8)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_money(_a.price), style: AppTextStyle.labelLarge),
                    if (hasOffer) ...[
                      SizedBox(width: _w(8)),
                      Text(
                        _money(_a.originalPrice),
                        style: AppTextStyle.caption.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: _w(10)),
                _qtyStepper(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyStepper() {
    Widget btn(IconData icon, VoidCallback? onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? AppColors.textTertiary
                : AppColors.primary),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, _qty > 1 ? () => _changeQty(-1) : null),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _w(10)),
            child: Text('$_qty', style: AppTextStyle.labelMedium),
          ),
          btn(Icons.add_rounded, _qty < _maxQty ? () => _changeQty(1) : null),
        ],
      ),
    );
  }

  // ---------------- 3. PRICE (from POST /product/price-summary) ----------------
  Widget _priceDetails() {
    return BlocBuilder<PriceSummaryBloc, PriceSummaryState>(
      bloc: _priceBloc,
      builder: (context, state) {
        // ---- loaded ----
        if (state is PriceSummaryLoadedState) {
          final s = state.summary;
          final qty = state.quantity;

          return AnimatedOpacity(
            // dimmed while a new quantity is being priced
            opacity: state.isRefreshing ? 0.45 : 1,
            duration: const Duration(milliseconds: 150),
            child: Container(
              padding: EdgeInsets.all(_w(14)),
              decoration: _card(),
              child: Column(
                children: [
                  _row('Price ($qty ${qty == 1 ? 'item' : 'items'})',
                      _money(s.productPrice)),
                  _row(
                    'Delivery Charges',
                    s.hasDeliveryCharge ? _money(s.deliveryCharge) : s.deliveryText,
                    color: s.hasDeliveryCharge ? null : AppColors.success,
                  ),
                  _row('Tax', _money(s.tax)),          // <-- no "if", always shown

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
            ),
          );
        }

        // ---- error ----
        if (state is PriceSummaryErrorState) {
          return Container(
            padding: EdgeInsets.all(_w(16)),
            decoration: _card(),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error),
                SizedBox(width: _w(12)),
                Expanded(
                  child: Text(state.errorMessage,
                      style: AppTextStyle.bodySmall),
                ),
                TextButton(onPressed: _loadPrice, child: const Text('Retry')),
              ],
            ),
          );
        }

        // ---- first load ----
        return Container(
          height: _w(110),
          decoration: _card(),
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

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _w(4)),
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
  Widget _bottomBar() {
    return Container(
      padding:
      EdgeInsets.symmetric(horizontal: _pagePadding, vertical: _w(12)),
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
        top: false,
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _maxContentWidth.isFinite
                  ? _maxContentWidth - _pagePadding * 2
                  : double.infinity,
            ),
            child: BlocBuilder<PriceSummaryBloc, PriceSummaryState>(
              bloc: _priceBloc,
              builder: (context, state) {
                final loaded =
                state is PriceSummaryLoadedState ? state : null;
                final ready = loaded != null &&
                    !loaded.isRefreshing &&
                    loaded.quantity == _qty;

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total Payable', style: AppTextStyle.caption),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              loaded == null
                                  ? '--'
                                  : _money(loaded.summary.totalAmount),
                              style: AppTextStyle.productPriceLarge.copyWith(
                                color: ready
                                    ? null
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: _w(12)),
                    CustomButton(
                      text: 'Confirm Order',
                      width: Responsive.value(
                          mobile: _w(170), tablet: 220.0, desktop: 240.0),
                      icon: Icons.lock_outline_rounded,
                      // disabled until the API price matches the quantity
                      onPressed: ready ? _confirm : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}