//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/cartbloc/cart_bloc.dart';
// import '../bloc/cartbloc/cart_event.dart';
// import '../bloc/cartbloc/cart_state.dart';
// import '../bloc/productdetailbloc/productdetail_bloc.dart';
// import '../bloc/productdetailbloc/productdetail_event.dart';
// import '../bloc/productdetailbloc/productdetail_state.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../data/models/productdetailmodel.dart';
// import '../data/models/whishlistmodel.dart';
// import '../widgets/appsnackbar.dart';
// import '../core/utils/formatters.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/network_image_with_fallback.dart';
// import '../bloc/whishlistbloc/wishlist_bloc.dart';
// import '../bloc/whishlistbloc/wishlist_event.dart';
// import '../bloc/whishlistbloc/wishlist_state.dart';
//
// class ProductDetailsScreen extends StatelessWidget {
//   final int productId;
//   const ProductDetailsScreen({super.key, required this.productId});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ProductDetailsBloc()
//         ..add(LoadProductDetailsEvent(productId: productId)),
//       child: _View(productId: productId),
//     );
//   }
// }
//
// class _View extends StatefulWidget {
//   final int productId;
//   const _View({required this.productId});
//
//   @override
//   State<_View> createState() => _ViewState();
// }
//
// class _ViewState extends State<_View> {
//   final PageController _imagePageController = PageController();
//   int _activeImageIndex = 0;
//
//   // null = use default (first in-stock colour / size)
//   int? _colorId;
//   String? _size;
//   int _quantity = 1;
//
//   @override
//   void dispose() {
//     _imagePageController.dispose();
//     super.dispose();
//   }
//
//   // ---------- selection helpers ----------
//   int _effColor(ProductDetailsModel p) => _colorId ?? p.defaultColorId;
//   String? _effSize(ProductDetailsModel p) =>
//       _size ?? p.defaultSizeFor(_effColor(p));
//   ProductVariantModel? _variant(ProductDetailsModel p) =>
//       p.findVariant(_effColor(p), _effSize(p));
//
//   void _selectColor(int id) {
//     setState(() {
//       _colorId = id;
//       _size = null;
//       _quantity = 1;
//       _activeImageIndex = 0;
//     });
//     if (_imagePageController.hasClients) _imagePageController.jumpToPage(0);
//   }
//
//   void _snack(String msg, {Color? color, SnackBarAction? action}) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(SnackBar(
//           content: Text(msg), backgroundColor: color, action: action));
//   }
//
//   ProductVariantModel? _validate(ProductDetailsModel p) {
//     final v = _variant(p);
//     if (v == null) {
//       _snack('Please select a size first', color: AppColors.error);
//       return null;
//     }
//     if (!v.inStock || v.stock <= 0) {
//       _snack('This option is out of stock', color: AppColors.error);
//       return null;
//     }
//     return v;
//   }
//
//   void _toggleWishlist(ProductDetailsModel p) {
//     final hasOffer = p.originalPrice > p.price && p.price > 0;
//     context.read<WishlistBloc>().add(ToggleWishlistEvent(
//       productId: p.id,
//       // lets the Wishlist tab update instantly (no extra API call)
//       item: WishlistItemModel(
//         id: p.id,
//         name: p.name,
//         image: p.images.isNotEmpty ? p.images.first.image : '',
//         price: hasOffer ? p.originalPrice : p.price,
//         offerPrice: hasOffer ? p.price : 0,
//       ),
//     ));
//   }
//
//   void _handleAddToCart(ProductDetailsModel p) {
//     final v = _validate(p);
//     if (v == null) return;
//
//     // POST /cart/add  (success / error message comes back through CartBloc)
//     context.read<CartBloc>().add(AddToCartEvent(
//       productId: p.id,
//       colorId: v.colorId,
//       size: v.size,
//       quantity: _quantity,
//     ));
//   }
//
//   void _handleBuyNow(ProductDetailsModel p) {
//     final v = _validate(p);
//     if (v == null) return;
//     // TODO: AddToCart then open CheckoutScreen
//   }
//
//   // ---------- build ----------
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CartBloc, CartState>(
//       // "Added to cart" / failure message (only while this page is on top)
//       listenWhen: (prev, cur) =>
//       cur is CartLoadedState &&
//           cur.message != null &&
//           cur.message!.action == CartAction.add &&
//           (prev is! CartLoadedState || prev.message?.seq != cur.message!.seq),
//       listener: (context, state) {
//         if (ModalRoute.of(context)?.isCurrent != true) return;
//         final m = (state as CartLoadedState).message!;
//         m.isError ? AppSnackbar.error(m.text) : AppSnackbar.success(m.text);
//       },
//       child: _buildBody(),
//     );
//   }
//
//   Widget _buildBody() {
//     return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
//       builder: (context, state) {
//         if (state is ProductDetailsLoadedState) {
//           return _buildLoaded(context, state.product);
//         }
//         if (state is ProductDetailsErrorState) {
//           return _plainScaffold(_ErrorView(
//             message: state.errorMessage,
//             onRetry: () => context.read<ProductDetailsBloc>().add(
//                 LoadProductDetailsEvent(productId: widget.productId)),
//           ));
//         }
//         return _plainScaffold(const Center(
//             child: CircularProgressIndicator(color: AppColors.primary)));
//       },
//     );
//   }
//
//   Widget _plainScaffold(Widget body) => Scaffold(
//     backgroundColor: AppColors.scaffoldBackground,
//     appBar: AppBar(
//       backgroundColor: AppColors.surface,
//       surfaceTintColor: Colors.transparent,
//       scrolledUnderElevation: 1,
//       elevation: 0,
//       systemOverlayStyle: SystemUiOverlayStyle.dark,
//     ),
//     body: body,
//   );
//
//   Widget _buildLoaded(BuildContext context, ProductDetailsModel product) {
//     final size = MediaQuery.of(context).size;
//     final colorId = _effColor(product);
//     final selectedSize = _effSize(product);
//     final variant = _variant(product);
//     final images = product.imagesForColor(colorId);
//     final sizes = product.variantsForColor(colorId);
//     final colors = product.colors;
//     final specs = product.specifications;
//     final about = product.aboutText;
//
//     final stock = variant?.stock ?? 0;
//     final available = variant != null && variant.inStock && stock > 0;
//
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: CircleAvatar(
//             backgroundColor: AppColors.surface.withValues(alpha: 0.9),
//             radius: 18,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new,
//                   size: 16, color: Colors.black),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: CircleAvatar(
//               backgroundColor: AppColors.surface.withValues(alpha: 0.9),
//               radius: 18,
//               child: BlocConsumer<WishlistBloc, WishlistState>(
//                 // snackbar only for this product (and only while this page is on top)
//                 listenWhen: (prev, cur) =>
//                 cur is WishlistLoadedState &&
//                     cur.message != null &&
//                     cur.message!.productId == product.id &&
//                     !cur.message!.fromWishlistScreen &&
//                     (prev is! WishlistLoadedState ||
//                         prev.message?.seq != cur.message!.seq),
//                 listener: (context, ws) {
//                   if (ModalRoute.of(context)?.isCurrent != true) return;
//                   final m = (ws as WishlistLoadedState).message!;
//                   m.isError
//                       ? AppSnackbar.error(m.text)
//                       : AppSnackbar.success(m.text);
//                 },
//                 buildWhen: (a, b) =>
//                 a.isWishlisted(product.id) != b.isWishlisted(product.id),
//                 builder: (context, ws) {
//                   final wished = ws.isWishlisted(product.id);
//                   return IconButton(
//                     icon: Icon(
//                       wished ? Icons.favorite : Icons.favorite_border,
//                       size: 20,
//                       color: wished ? AppColors.error : AppColors.textPrimary,
//                     ),
//                     onPressed: () => _toggleWishlist(product),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Carousel
//             SizedBox(
//               height: (size.height * 0.52).clamp(320.0, 480.0),
//               width: double.infinity,
//               child: Stack(
//                 children: [
//                   if (images.isEmpty)
//                     Container(
//                       color: AppColors.blush,
//                       alignment: Alignment.center,
//                       child: const Icon(Icons.image_outlined,
//                           size: 48, color: AppColors.textTertiary),
//                     )
//                   else
//                     PageView.builder(
//                       key: ValueKey('gallery_$colorId'),
//                       controller: _imagePageController,
//                       itemCount: images.length,
//                       onPageChanged: (i) =>
//                           setState(() => _activeImageIndex = i),
//                       itemBuilder: (context, index) {
//                         return NetworkImageWithFallback(
//                           imageUrl: images[index].image,
//                           fit: BoxFit.cover,
//                         );
//                       },
//                     ),
//                   // Dots Indicator
//                   if (images.length > 1)
//                     Positioned(
//                       bottom: 16,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(images.length, (idx) {
//                           final isActive = idx == _activeImageIndex;
//                           return AnimatedContainer(
//                             duration: const Duration(milliseconds: 250),
//                             margin: const EdgeInsets.symmetric(horizontal: 3),
//                             height: 6,
//                             width: isActive ? 20 : 6,
//                             decoration: BoxDecoration(
//                               color: isActive
//                                   ? AppColors.primary
//                                   : Colors.white.withValues(alpha: 0.7),
//                               borderRadius: BorderRadius.circular(3),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             // Product Details Content Box
//             Container(
//               transform: Matrix4.translationValues(0, -16, 0),
//               decoration: const BoxDecoration(
//                 color: AppColors.scaffoldBackground,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Category & Rating
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           product.category.toUpperCase(),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: AppTextStyle.caption.copyWith(
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 1.2,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ),
//                       if (product.rating > 0) _ratingChip(product.rating),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//
//                   // Product Title
//                   Text(product.name,
//                       style: AppTextStyle.mainHeading.copyWith(fontSize: 22)),
//                   const SizedBox(height: 14),
//
//                   // Price & Discount Row
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: [
//                       Text(
//                         Formatters.formatPrice(product.price),
//                         style: AppTextStyle.productPriceLarge,
//                       ),
//                       const SizedBox(width: 10),
//                       if (product.hasDiscount) ...[
//                         Text(
//                           Formatters.formatPrice(product.originalPrice),
//                           style: AppTextStyle.originalPriceLarge,
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 3),
//                           decoration: BoxDecoration(
//                             color: AppColors.discountBadge,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             '${product.discountPercent}% OFF',
//                             style: AppTextStyle.badgeText,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Divider(),
//                   const SizedBox(height: 16),
//
//                   // Size Selector (small boxes, one row)
//                   if (sizes.any((v) => v.size.isNotEmpty)) ...[
//                     Text('Select Size', style: AppTextStyle.labelLarge),
//                     const SizedBox(height: 10),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: sizes.map((v) {
//                           final isSelected = selectedSize == v.size;
//                           final dim = !v.inStock;
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 10),
//                             child: GestureDetector(
//                               onTap: () => setState(() {
//                                 _size = v.size;
//                                 _quantity = 1;
//                               }),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 constraints: const BoxConstraints(minWidth: 48),
//                                 height: 44,
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 14),
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? AppColors.primary
//                                       : AppColors.surface,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? AppColors.primary
//                                         : AppColors.border,
//                                     width: 1.2,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       v.size,
//                                       style: AppTextStyle.labelMedium.copyWith(
//                                         color: isSelected
//                                             ? AppColors.textLight
//                                             : (dim
//                                             ? AppColors.textTertiary
//                                             : AppColors.textPrimary),
//                                         fontWeight: FontWeight.w700,
//                                         decoration: dim
//                                             ? TextDecoration.lineThrough
//                                             : null,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//
//                   // Color Selector
//                   if (colors.isNotEmpty) ...[
//                     Text('Available Colors', style: AppTextStyle.labelLarge),
//                     const SizedBox(height: 10),
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 8,
//                       children: colors.map((c) {
//                         final isSelected = colorId == c.id;
//                         return ChoiceChip(
//                           label: Text(c.name),
//                           selected: isSelected,
//                           selectedColor: AppColors.primary,
//                           labelStyle: AppTextStyle.caption.copyWith(
//                             color: isSelected
//                                 ? AppColors.textLight
//                                 : AppColors.textPrimary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           onSelected: (_) => _selectColor(c.id),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//
//                   // Quantity Selector & Stock
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Quantity', style: AppTextStyle.labelLarge),
//                           const SizedBox(height: 6),
//                           Row(
//                             children: [
//                               IconButton(
//                                 onPressed: _quantity > 1
//                                     ? () => setState(() => _quantity--)
//                                     : null,
//                                 icon: const Icon(Icons.remove_circle_outline,
//                                     size: 22),
//                                 color: AppColors.textPrimary,
//                               ),
//                               Text('$_quantity',
//                                   style: AppTextStyle.labelLarge),
//                               IconButton(
//                                 onPressed: available && _quantity < stock
//                                     ? () => setState(() => _quantity++)
//                                     : null,
//                                 icon: const Icon(Icons.add_circle_outline,
//                                     size: 22),
//                                 color: AppColors.primary,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       // Stock Status
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: available
//                               ? AppColors.successLight
//                               : AppColors.errorLight,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               available
//                                   ? Icons.check_circle
//                                   : Icons.warning_amber_rounded,
//                               size: 14,
//                               color: available
//                                   ? AppColors.success
//                                   : AppColors.error,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               available
//                                   ? 'In Stock ($stock left)'
//                                   : 'Out of Stock',
//                               style: AppTextStyle.caption.copyWith(
//                                 color: available
//                                     ? AppColors.success
//                                     : AppColors.error,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Divider(),
//                   const SizedBox(height: 16),
//
//                   // Delivery Info
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceVariant,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: AppColors.borderLight),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.local_shipping_outlined,
//                             color: AppColors.primary, size: 22),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Doorstep Delivery',
//                                   style: AppTextStyle.labelMedium),
//                               Text(
//                                 product.freeShipping
//                                     ? 'Free delivery'
//                                     : 'Delivery charge ${Formatters.formatPrice(product.shippingCharge)}',
//                                 style: AppTextStyle.caption,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Product Description
//                   if (about.isNotEmpty) ...[
//                     Text('About This Style',
//                         style: AppTextStyle.sectionHeading),
//                     const SizedBox(height: 8),
//                     Text(about, style: AppTextStyle.bodyLarge),
//                     const SizedBox(height: 24),
//                   ],
//
//                   // Product Specifications
//                   if (specs.isNotEmpty) ...[
//                     Text('Product Specifications',
//                         style: AppTextStyle.sectionHeading),
//                     const SizedBox(height: 10),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.borderLight),
//                       ),
//                       child: Column(
//                         children: specs.map((entry) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 10),
//                             decoration: const BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(color: AppColors.divider)),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(entry.key,
//                                       style: AppTextStyle.labelMuted),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text(entry.value,
//                                       style: AppTextStyle.labelMedium),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: const BoxDecoration(
//           color: AppColors.surface,
//           border: Border(top: BorderSide(color: AppColors.borderLight)),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadowMedium,
//               blurRadius: 10,
//               offset: Offset(0, -4),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               // Add to Cart
//               Expanded(
//                 child: BlocBuilder<CartBloc, CartState>(
//                   buildWhen: (a, b) =>
//                   (a is CartLoadedState && a.isAdding) !=
//                       (b is CartLoadedState && b.isAdding),
//                   builder: (context, cs) => CustomButton(
//                     text: 'Add to Cart',
//                     type: ButtonType.outlined,
//                     icon: Icons.shopping_bag_outlined,
//                     isLoading: cs is CartLoadedState && cs.isAdding,
//                     onPressed: () => _handleAddToCart(product),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // Buy Now
//               Expanded(
//                 child: CustomButton(
//                   text: 'Buy Now',
//                   icon: Icons.flash_on_rounded,
//                   onPressed: () => _handleBuyNow(product),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _ratingChip(double rating) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: AppColors.surface,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: AppColors.borderLight),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF5A623)),
//         const SizedBox(width: 3),
//         Text(
//           rating.toStringAsFixed(1),
//           style: AppTextStyle.caption.copyWith(
//               fontWeight: FontWeight.w700, color: AppColors.textPrimary),
//         ),
//       ],
//     ),
//   );
// }
//
// class _ErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.message, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline,
//                 size: 48, color: AppColors.textTertiary),
//             const SizedBox(height: 12),
//             Text(message,
//                 textAlign: TextAlign.center, style: AppTextStyle.bodyLarge),
//             const SizedBox(height: 16),
//             OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../bloc/productdetailbloc/productdetail_bloc.dart';
import '../bloc/productdetailbloc/productdetail_event.dart';
import '../bloc/productdetailbloc/productdetail_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/productdetailmodel.dart';
import '../data/models/whishlistmodel.dart';
import '../widgets/appsnackbar.dart';
import '../core/utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/network_image_with_fallback.dart';
import '../bloc/whishlistbloc/wishlist_bloc.dart';
import '../bloc/whishlistbloc/wishlist_event.dart';
import '../bloc/whishlistbloc/wishlist_state.dart';
import '../widgets/responsive.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailsBloc()
        ..add(LoadProductDetailsEvent(productId: productId)),
      child: _View(productId: productId),
    );
  }
}

class _View extends StatefulWidget {
  final int productId;
  const _View({required this.productId});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  /// At or above this width the page switches to a two-pane layout
  /// (gallery on the left, details on the right).
  static const double _wideBreakpoint = 700;
  static const double _wideMaxWidth = 1100;

  final PageController _imagePageController = PageController();
  int _activeImageIndex = 0;

  // null = use default (first in-stock colour / size)
  int? _colorId;
  String? _size;
  int _quantity = 1;

  // ---------- responsive helpers ----------
  double _scale = 1.0;
  bool get _isWide => Responsive.screenWidth >= _wideBreakpoint;

  /// Scales a design-pixel value (fonts, paddings, radii, icons...).
  double _s(double v) => v * _scale;

  /// Scales the font size of an existing [AppTextStyle] entry.
  TextStyle _ts(TextStyle style) =>
      style.copyWith(fontSize: (style.fontSize ?? 14) * _scale);

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // ---------- selection helpers ----------
  int _effColor(ProductDetailsModel p) => _colorId ?? p.defaultColorId;
  String? _effSize(ProductDetailsModel p) =>
      _size ?? p.defaultSizeFor(_effColor(p));
  ProductVariantModel? _variant(ProductDetailsModel p) =>
      p.findVariant(_effColor(p), _effSize(p));

  void _selectColor(int id) {
    setState(() {
      _colorId = id;
      _size = null;
      _quantity = 1;
      _activeImageIndex = 0;
    });
    if (_imagePageController.hasClients) _imagePageController.jumpToPage(0);
  }

  // Uses AppSnackbar so validation messages are responsive and consistent
  // with the rest of the app.
  ProductVariantModel? _validate(ProductDetailsModel p) {
    final v = _variant(p);
    if (v == null) {
      AppSnackbar.error('Please select a size first');
      return null;
    }
    if (!v.inStock || v.stock <= 0) {
      AppSnackbar.error('This option is out of stock');
      return null;
    }
    return v;
  }

  void _toggleWishlist(ProductDetailsModel p) {
    final hasOffer = p.originalPrice > p.price && p.price > 0;
    context.read<WishlistBloc>().add(ToggleWishlistEvent(
      productId: p.id,
      // lets the Wishlist tab update instantly (no extra API call)
      item: WishlistItemModel(
        id: p.id,
        name: p.name,
        image: p.images.isNotEmpty ? p.images.first.image : '',
        price: hasOffer ? p.originalPrice : p.price,
        offerPrice: hasOffer ? p.price : 0,
      ),
    ));
  }

  void _handleAddToCart(ProductDetailsModel p) {
    final v = _validate(p);
    if (v == null) return;

    // POST /cart/add  (success / error message comes back through CartBloc)
    context.read<CartBloc>().add(AddToCartEvent(
      productId: p.id,
      colorId: v.colorId,
      size: v.size,
      quantity: _quantity,
    ));
  }

  void _handleBuyNow(ProductDetailsModel p) {
    final v = _validate(p);
    if (v == null) return;
    // TODO: AddToCart then open CheckoutScreen
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    // Refresh responsive values on every build (rotation, resize, etc).
    Responsive.init(context);
    _scale = _isWide ? 1.0 : (Responsive.screenWidth / 390).clamp(0.85, 1.15);

    // Keep the layout intact with very large system font sizes.
    final mq = MediaQuery.of(context);
    final textScaler =
    mq.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);

    return MediaQuery(
      data: mq.copyWith(textScaler: textScaler),
      child: BlocListener<CartBloc, CartState>(
        // "Added to cart" / failure message (only while this page is on top)
        listenWhen: (prev, cur) =>
        cur is CartLoadedState &&
            cur.message != null &&
            cur.message!.action == CartAction.add &&
            (prev is! CartLoadedState ||
                prev.message?.seq != cur.message!.seq),
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          final m = (state as CartLoadedState).message!;
          m.isError ? AppSnackbar.error(m.text) : AppSnackbar.success(m.text);
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, state) {
        if (state is ProductDetailsLoadedState) {
          return _buildLoaded(context, state.product);
        }
        if (state is ProductDetailsErrorState) {
          return _plainScaffold(_ErrorView(
            message: state.errorMessage,
            onRetry: () => context.read<ProductDetailsBloc>().add(
                LoadProductDetailsEvent(productId: widget.productId)),
          ));
        }
        return _plainScaffold(const Center(
            child: CircularProgressIndicator(color: AppColors.primary)));
      },
    );
  }

  Widget _plainScaffold(Widget body) => Scaffold(
    backgroundColor: AppColors.scaffoldBackground,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    body: body,
  );

  // ---------------------------------------------------------------------
  // Loaded page
  // ---------------------------------------------------------------------
  Widget _buildLoaded(BuildContext context, ProductDetailsModel product) {
    final isWide = _isWide;
    final colorId = _effColor(product);
    final selectedSize = _effSize(product);
    final variant = _variant(product);
    final images = product.imagesForColor(colorId);
    final sizes = product.variantsForColor(colorId);

    final stock = variant?.stock ?? 0;
    final available = variant != null && variant.inStock && stock > 0;

    final gallery = _buildGallery(images, colorId, isWide);
    final details = _buildDetails(
      product: product,
      colorId: colorId,
      selectedSize: selectedSize,
      sizes: sizes,
      stock: stock,
      available: available,
    );

    final Widget body;
    if (isWide) {
      // Two panes: gallery left, details right, each scrolling on its own.
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _wideMaxWidth),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: gallery,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 24, 0),
                  child: details,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gallery,
            // Product details content box (overlaps the gallery slightly)
            Container(
              transform: Matrix4.translationValues(0, -_s(16), 0),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(_s(20))),
              ),
              padding: EdgeInsets.fromLTRB(_s(20), _s(20), _s(20), 0),
              child: details,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // Phone: image runs behind the app bar. Wide: normal app bar.
      extendBodyBehindAppBar: !isWide,
      appBar: _buildAppBar(context, product),
      body: body,
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  // ---------- app bar ----------
  PreferredSizeWidget _buildAppBar(
      BuildContext context, ProductDetailsModel product) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: _s(60),
      leading: Padding(
        padding: EdgeInsets.only(left: _s(12)),
        child: CircleAvatar(
          backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          radius: _s(18),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios_new,
                size: _s(16), color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: _s(12)),
          child: CircleAvatar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            radius: _s(18),
            child: BlocConsumer<WishlistBloc, WishlistState>(
              // snackbar only for this product (and only while this page is on top)
              listenWhen: (prev, cur) =>
              cur is WishlistLoadedState &&
                  cur.message != null &&
                  cur.message!.productId == product.id &&
                  !cur.message!.fromWishlistScreen &&
                  (prev is! WishlistLoadedState ||
                      prev.message?.seq != cur.message!.seq),
              listener: (context, ws) {
                if (ModalRoute.of(context)?.isCurrent != true) return;
                final m = (ws as WishlistLoadedState).message!;
                m.isError
                    ? AppSnackbar.error(m.text)
                    : AppSnackbar.success(m.text);
              },
              buildWhen: (a, b) =>
              a.isWishlisted(product.id) != b.isWishlisted(product.id),
              builder: (context, ws) {
                final wished = ws.isWishlisted(product.id);
                return IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    wished ? Icons.favorite : Icons.favorite_border,
                    size: _s(20),
                    color: wished ? AppColors.error : AppColors.textPrimary,
                  ),
                  onPressed: () => _toggleWishlist(product),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------- image gallery ----------
  Widget _buildGallery(List images, int colorId, bool isWide) {
    // Phones: height follows the screen width (so landscape phones don't
    // get a squashed image). Wide: height follows the available height.
    final double height = isWide
        ? (Responsive.screenHeight * 0.72).clamp(360.0, 640.0)
        : (Responsive.screenWidth * 1.1).clamp(300.0, 480.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          if (images.isEmpty)
            Container(
              color: AppColors.blush,
              alignment: Alignment.center,
              child: Icon(Icons.image_outlined,
                  size: _s(48), color: AppColors.textTertiary),
            )
          else
            PageView.builder(
              key: ValueKey('gallery_$colorId'),
              controller: _imagePageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _activeImageIndex = i),
              itemBuilder: (context, index) {
                return NetworkImageWithFallback(
                  imageUrl: images[index].image,
                  fit: BoxFit.cover,
                );
              },
            ),

          // Prev / next arrows (mouse users can't swipe on web / desktop)
          if (isWide && images.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _galleryArrow(Icons.chevron_left, () {
                  _imagePageController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _galleryArrow(Icons.chevron_right, () {
                  _imagePageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }),
              ),
            ),
          ],

          // Dots indicator
          if (images.length > 1)
            Positioned(
              bottom: _s(24),
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (idx) {
                  final isActive = idx == _activeImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: _s(3)),
                    height: _s(6),
                    width: isActive ? _s(20) : _s(6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(_s(3)),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _galleryArrow(IconData icon, VoidCallback onTap) => CircleAvatar(
    radius: 18,
    backgroundColor: AppColors.surface.withValues(alpha: 0.9),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 22, color: AppColors.textPrimary),
      onPressed: onTap,
    ),
  );

  // ---------- details column ----------
  Widget _buildDetails({
    required ProductDetailsModel product,
    required int colorId,
    required String? selectedSize,
    required List<ProductVariantModel> sizes,
    required int stock,
    required bool available,
  }) {
    final colors = product.colors;
    final specs = product.specifications;
    final about = product.aboutText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category & Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product.category.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ts(AppTextStyle.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                )),
              ),
            ),
            if (product.rating > 0) _ratingChip(product.rating),
          ],
        ),
        SizedBox(height: _s(6)),

        // Product title
        Text(product.name,
            style: _ts(AppTextStyle.mainHeading.copyWith(fontSize: 22))),
        SizedBox(height: _s(14)),

        // Price & discount (Wrap so it never overflows on narrow screens)
        Wrap(
          spacing: _s(10),
          runSpacing: _s(6),
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              Formatters.formatPrice(product.price),
              style: _ts(AppTextStyle.productPriceLarge),
            ),
            if (product.hasDiscount) ...[
              Text(
                Formatters.formatPrice(product.originalPrice),
                style: _ts(AppTextStyle.originalPriceLarge),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _s(6), vertical: _s(3)),
                decoration: BoxDecoration(
                  color: AppColors.discountBadge,
                  borderRadius: BorderRadius.circular(_s(4)),
                ),
                child: Text(
                  '${product.discountPercent}% OFF',
                  style: _ts(AppTextStyle.badgeText),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: _s(16)),
        const Divider(),
        SizedBox(height: _s(16)),

        // Size selector (small boxes, one scrollable row)
        if (sizes.any((v) => v.size.isNotEmpty)) ...[
          Text('Select Size', style: _ts(AppTextStyle.labelLarge)),
          SizedBox(height: _s(10)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sizes.map((v) {
                final isSelected = selectedSize == v.size;
                final dim = !v.inStock;
                return Padding(
                  padding: EdgeInsets.only(right: _s(10)),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _size = v.size;
                      _quantity = 1;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: BoxConstraints(minWidth: _s(48)),
                      height: _s(44),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: _s(14)),
                      decoration: BoxDecoration(
                        color:
                        isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(_s(8)),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        v.size,
                        style: _ts(AppTextStyle.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.textLight
                              : (dim
                              ? AppColors.textTertiary
                              : AppColors.textPrimary),
                          fontWeight: FontWeight.w700,
                          decoration:
                          dim ? TextDecoration.lineThrough : null,
                        )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: _s(20)),
        ],

        // Colour selector
        if (colors.isNotEmpty) ...[
          Text('Available Colors', style: _ts(AppTextStyle.labelLarge)),
          SizedBox(height: _s(10)),
          Wrap(
            spacing: _s(10),
            runSpacing: _s(8),
            children: colors.map((c) {
              final isSelected = colorId == c.id;
              return ChoiceChip(
                label: Text(c.name),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: _ts(AppTextStyle.caption.copyWith(
                  color:
                  isSelected ? AppColors.textLight : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                )),
                onSelected: (_) => _selectColor(c.id),
              );
            }).toList(),
          ),
          SizedBox(height: _s(20)),
        ],

        // Quantity selector & stock status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity', style: _ts(AppTextStyle.labelLarge)),
                SizedBox(height: _s(6)),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: Icon(Icons.remove_circle_outline, size: _s(22)),
                      color: AppColors.textPrimary,
                    ),
                    Text('$_quantity', style: _ts(AppTextStyle.labelLarge)),
                    IconButton(
                      onPressed: available && _quantity < stock
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: Icon(Icons.add_circle_outline, size: _s(22)),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: _s(8)),
            // Flexible: pill shrinks instead of overflowing on narrow screens
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _s(12), vertical: _s(6)),
                decoration: BoxDecoration(
                  color: available
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(_s(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      available
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      size: _s(14),
                      color:
                      available ? AppColors.success : AppColors.error,
                    ),
                    SizedBox(width: _s(4)),
                    Flexible(
                      child: Text(
                        available ? 'In Stock ($stock left)' : 'Out of Stock',
                        overflow: TextOverflow.ellipsis,
                        style: _ts(AppTextStyle.caption.copyWith(
                          color: available
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w700,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _s(16)),
        const Divider(),
        SizedBox(height: _s(16)),

        // Delivery info
        Container(
          padding: EdgeInsets.all(_s(12)),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(_s(10)),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  color: AppColors.primary, size: _s(22)),
              SizedBox(width: _s(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doorstep Delivery',
                        style: _ts(AppTextStyle.labelMedium)),
                    Text(
                      product.freeShipping
                          ? 'Free delivery'
                          : 'Delivery charge ${Formatters.formatPrice(product.shippingCharge)}',
                      style: _ts(AppTextStyle.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _s(20)),

        // Product description
        if (about.isNotEmpty) ...[
          Text('About This Style', style: _ts(AppTextStyle.sectionHeading)),
          SizedBox(height: _s(8)),
          Text(about, style: _ts(AppTextStyle.bodyLarge)),
          SizedBox(height: _s(24)),
        ],

        // Product specifications
        if (specs.isNotEmpty) ...[
          Text('Product Specifications',
              style: _ts(AppTextStyle.sectionHeading)),
          SizedBox(height: _s(10)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(_s(12)),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: specs.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: _s(14), vertical: _s(10)),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key,
                            style: _ts(AppTextStyle.labelMuted)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(entry.value,
                            style: _ts(AppTextStyle.labelMedium)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        SizedBox(height: _s(32)),
      ],
    );
  }

  // ---------- bottom bar ----------
  Widget _buildBottomBar(ProductDetailsModel product) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _s(16), vertical: _s(12)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Center(
          // On wide screens keep the buttons a sensible width.
          heightFactor: 1,
          child: ConstrainedBox(
            constraints:
            BoxConstraints(maxWidth: _isWide ? 520 : double.infinity),
            child: Row(
              children: [
                // Add to Cart
                Expanded(
                  child: BlocBuilder<CartBloc, CartState>(
                    buildWhen: (a, b) =>
                    (a is CartLoadedState && a.isAdding) !=
                        (b is CartLoadedState && b.isAdding),
                    builder: (context, cs) => CustomButton(
                      text: 'Add to Cart',
                      type: ButtonType.outlined,
                      icon: Icons.shopping_bag_outlined,
                      isLoading: cs is CartLoadedState && cs.isAdding,
                      onPressed: () => _handleAddToCart(product),
                    ),
                  ),
                ),
                SizedBox(width: _s(12)),
                // Buy Now
                Expanded(
                  child: CustomButton(
                    text: 'Buy Now',
                    icon: Icons.flash_on_rounded,
                    onPressed: () => _handleBuyNow(product),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(double rating) => Container(
    padding: EdgeInsets.symmetric(horizontal: _s(8), vertical: _s(4)),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(_s(20)),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            size: _s(14), color: const Color(0xFFF5A623)),
        SizedBox(width: _s(3)),
        Text(
          rating.toStringAsFixed(1),
          style: _ts(AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          // Don't stretch edge-to-edge on tablets / web.
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(message,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyLarge),
                const SizedBox(height: 16),
                OutlinedButton(
                    onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}