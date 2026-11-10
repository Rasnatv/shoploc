//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/addressbloc/address_bloc.dart';
// import '../bloc/addressbloc/address_event.dart';
// import '../bloc/addressbloc/address_state.dart';
// import '../bloc/authbloc/auth_bloc.dart';
// import '../bloc/authbloc/auth_event.dart';
// import '../bloc/authbloc/auth_state.dart';
// import '../bloc/cartbloc/cart_bloc.dart';
// import '../bloc/cartbloc/cart_event.dart';
// import '../bloc/cartbloc/cart_state.dart';
// import '../bloc/checkoutbloc/checkout_bloc.dart';
// import '../bloc/checkoutbloc/checkout_event.dart';
// import '../bloc/checkoutbloc/checkout_state.dart';
// import '../bloc/ordersbloc/order_bloc.dart';
// import '../bloc/ordersbloc/order_event.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import '../core/utils/app_animations.dart';
// import '../core/utils/formatters.dart';
// import '../data/models/address_model.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/network_image_with_fallback.dart';
// import 'add_edit_address_screen.dart';
// import 'main_bottom_nav_screen.dart';
// import 'order_details_screen.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isRegisterMode = true;
//   bool _obscurePassword = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // Ensure auth status is verified and fresh
//     context.read<AuthBloc>().add(const CheckAuthStatusEvent());
//     context.read<AddressBloc>().add(const LoadAddressesEvent());
//
//     final cartState = context.read<CartBloc>().state;
//     final coupon = cartState is CartLoadedState ? cartState.appliedCoupon : null;
//
//     final addressState = context.read<AddressBloc>().state;
//     AddressModel? defaultAddr;
//     if (addressState is AddressLoadedState) {
//       defaultAddr = addressState.defaultAddress;
//     }
//
//     context.read<CheckoutBloc>().add(
//       InitCheckoutEvent(
//         selectedAddress: defaultAddr,
//         couponCode: coupon,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _handleRegister() {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final password = _passwordController.text.trim();
//
//     if (name.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your full name.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//     if (email.isEmpty || !email.contains('@')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid email address.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//     if (phone.isEmpty || phone.length < 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid 10-digit mobile number.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//     if (password.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Password must be at least 6 characters.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//
//     context.read<AuthBloc>().add(
//       RegisterEvent(
//         name: name,
//         email: email,
//         phone: phone,
//         password: password,
//       ),
//     );
//   }
//
//   void _handleLogin() {
//     final emailOrPhone = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//
//     if (emailOrPhone.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your email or mobile number.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//     if (password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your password.'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//       return;
//     }
//
//     context.read<AuthBloc>().add(
//       LoginEvent(
//         emailOrPhone: emailOrPhone,
//         password: password,
//       ),
//     );
//   }
//
//   void _showOrderSuccessDialog(BuildContext context, dynamic order) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogCtx) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           backgroundColor: AppColors.surface,
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const AnimatedSuccessCheckmark(size: 80),
//                 const SizedBox(height: 20),
//                 Text('Order Placed Successfully!', style: AppTextStyle.sectionHeading),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Order ID: ${order.id}',
//                   style: AppTextStyle.labelLarge.copyWith(color: AppColors.primary),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Thank you for shopping local with Shoploc. Your order has been confirmed and is being hand-packed by our boutique partner.',
//                   textAlign: TextAlign.center,
//                   style: AppTextStyle.description,
//                 ),
//                 const SizedBox(height: 24),
//                 CustomButton(
//                   text: 'View Order Details',
//                   onPressed: () {
//                     Navigator.of(dialogCtx).pop();
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(
//                         builder: (_) => OrderDetailsScreen(order: order),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 CustomButton(
//                   text: 'Continue Shopping',
//                   type: ButtonType.outlined,
//                   onPressed: () {
//                     Navigator.of(dialogCtx).pop();
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(
//                         builder: (_) => const MainBottomNavScreen(initialIndex: 0),
//                       ),
//                           (route) => false,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         title: Text('Checkout', style: AppTextStyle.appBarTitle),
//       ),
//       body: BlocConsumer<CheckoutBloc, CheckoutState>(
//         listener: (context, state) {
//           if (state is CheckoutOrderSuccessState) {
//             context.read<OrderBloc>().add(PlaceOrderEvent(order: state.placedOrder));
//             context.read<CartBloc>().add(const ClearCartEvent());
//             _showOrderSuccessDialog(context, state.placedOrder);
//           } else if (state is CheckoutErrorState) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
//             );
//           }
//         },
//         builder: (context, checkoutState) {
//           final isLoading = checkoutState is CheckoutLoadingState;
//           final readyState = checkoutState is CheckoutReadyState
//               ? checkoutState
//               : const CheckoutReadyState();
//
//           return BlocBuilder<CartBloc, CartState>(
//             builder: (context, cartState) {
//               if (cartState is! CartLoadedState || cartState.isEmpty) {
//                 return Center(
//                   child: Text('Your cart is empty', style: AppTextStyle.sectionHeading),
//                 );
//               }
//
//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // 1. Customer Account & Contact (Register / Login)
//                           _buildSectionTitle('1. Customer Account & Contact'),
//                           const SizedBox(height: 8),
//                           _buildAccountSection(),
//
//                           const SizedBox(height: 24),
//
//                           // 2. Delivery Address Card
//                           _buildSectionTitle('2. Delivery Address'),
//                           const SizedBox(height: 8),
//                           _buildAddressSelector(readyState),
//
//                           const SizedBox(height: 24),
//
//                           // 3. Order Items Review
//                           _buildSectionTitle('3. Items in Order (${cartState.items.length})'),
//                           const SizedBox(height: 8),
//                           _buildItemsPreview(cartState),
//
//                           const SizedBox(height: 24),
//
//                           // 4. Payment Method
//                           _buildSectionTitle('4. Payment Method'),
//                           const SizedBox(height: 8),
//                           _buildPaymentMethodSelector(readyState),
//
//                           const SizedBox(height: 24),
//
//                           // 5. Order Bill Breakdown
//                           _buildSectionTitle('5. Price Details'),
//                           const SizedBox(height: 8),
//                           _buildBillDetails(cartState),
//
//                           const SizedBox(height: 32),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Bottom Place Order Action Bar
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     decoration: const BoxDecoration(
//                       color: AppColors.surface,
//                       border: Border(top: BorderSide(color: AppColors.borderLight)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.shadowMedium,
//                           blurRadius: 8,
//                           offset: Offset(0, -3),
//                         ),
//                       ],
//                     ),
//                     child: SafeArea(
//                       child: Row(
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text('Total Payable', style: AppTextStyle.caption),
//                               Text(
//                                 Formatters.formatPrice(cartState.grandTotal),
//                                 style: AppTextStyle.productPriceLarge,
//                               ),
//                             ],
//                           ),
//                           const Spacer(),
//                           CustomButton(
//                             text: 'Place Order',
//                             width: 170,
//                             isLoading: isLoading,
//                             icon: Icons.lock_outline_rounded,
//                             onPressed: () {
//                               // Verify that customer is registered or logged in
//                               final authState = context.read<AuthBloc>().state;
//                               if (authState is! AuthenticatedState) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please register or sign in with your Name and Email to place your order.'),
//                                     backgroundColor: AppColors.warning,
//                                   ),
//                                 );
//                                 _scrollController.animateTo(
//                                   0,
//                                   duration: const Duration(milliseconds: 350),
//                                   curve: Curves.easeOutCubic,
//                                 );
//                                 return;
//                               }
//
//                               if (readyState.selectedAddress == null) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Please select or add a shipping address.'),
//                                     backgroundColor: AppColors.warning,
//                                   ),
//                                 );
//                                 return;
//                               }
//
//                               context.read<CheckoutBloc>().add(
//                                 SubmitOrderEvent(
//                                   items: cartState.items,
//                                   subtotal: cartState.subtotal,
//                                   discount: cartState.productDiscount,
//                                   deliveryFee: cartState.deliveryFee,
//                                   couponDiscount: cartState.couponDiscount,
//                                   couponCode: cartState.appliedCoupon,
//                                   totalAmount: cartState.grandTotal,
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: AppTextStyle.labelLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
//     );
//   }
//
//   /// Customer Account Section:
//   /// - If ALREADY registered/logged in: Displays clean verified customer profile (name, email, phone).
//   ///   Does NOT show registration or login form ("dont show next like that").
//   /// - If NOT registered: Provides inline Register (Name, Email, Phone, Password) and Sign In tabs.
//   Widget _buildAccountSection() {
//     return BlocConsumer<AuthBloc, AuthState>(
//       listener: (context, authState) {
//         if (authState is AuthenticatedState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Welcome, ${authState.user.name}! Your account is verified.'),
//               backgroundColor: AppColors.success,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         } else if (authState is AuthErrorState) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(authState.errorMessage),
//               backgroundColor: AppColors.error,
//             ),
//           );
//         }
//       },
//       builder: (context, authState) {
//         // CASE A: User IS registered and logged in
//         if (authState is AuthenticatedState) {
//           final user = authState.user;
//           return Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.borderLight),
//               boxShadow: const [
//                 BoxShadow(
//                   color: AppColors.shadow,
//                   blurRadius: 6,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundColor: AppColors.brandBlue.withValues(alpha: 0.12),
//                   child: Text(
//                     user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
//                     style: const TextStyle(
//                       color: AppColors.brandBlue,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Text(
//                               user.name,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: AppColors.successLight,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: const Text(
//                               'REGISTERED',
//                               style: TextStyle(
//                                 color: AppColors.success,
//                                 fontSize: 9.5,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         user.email,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyle.caption.copyWith(color: AppColors.textPrimary),
//                       ),
//                       if (user.phone.isNotEmpty)
//                         Text(
//                           user.phone,
//                           style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
//                         ),
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     context.read<AuthBloc>().add(const LogoutEvent());
//                   },
//                   child: Text(
//                     'Change',
//                     style: AppTextStyle.caption.copyWith(
//                       color: AppColors.brandOrange,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         // CASE B: User is NOT registered / NOT logged in
//         final isAuthLoading = authState is AuthLoadingState;
//
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: AppColors.borderLight),
//             boxShadow: const [
//               BoxShadow(
//                 color: AppColors.shadow,
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Notice banner explaining account verification
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: AppColors.brandOrange.withValues(alpha: 0.12),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.person_add_alt_1_rounded,
//                       color: AppColors.brandOrange,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _isRegisterMode
//                               ? 'New Customer Registration'
//                               : 'Returning Customer Sign In',
//                           style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
//                         ),
//                         Text(
//                           _isRegisterMode
//                               ? 'Enter your name & email to save receipts & order updates.'
//                               : 'Sign in to access your saved details and addresses.',
//                           style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 14),
//
//               // Segmented Toggle between Register and Sign In
//               Container(
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceVariant,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 padding: const EdgeInsets.all(3),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _isRegisterMode = true),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: _isRegisterMode ? AppColors.surface : Colors.transparent,
//                             borderRadius: BorderRadius.circular(18),
//                             boxShadow: _isRegisterMode
//                                 ? const [
//                               BoxShadow(
//                                 color: Color(0x12000000),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 1),
//                               ),
//                             ]
//                                 : null,
//                           ),
//                           child: Text(
//                             'Register (New)',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: _isRegisterMode ? FontWeight.w800 : FontWeight.w600,
//                               color: _isRegisterMode ? AppColors.brandOrange : AppColors.textSecondary,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => setState(() => _isRegisterMode = false),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: !_isRegisterMode ? AppColors.surface : Colors.transparent,
//                             borderRadius: BorderRadius.circular(18),
//                             boxShadow: !_isRegisterMode
//                                 ? const [
//                               BoxShadow(
//                                 color: Color(0x12000000),
//                                 blurRadius: 4,
//                                 offset: Offset(0, 1),
//                               ),
//                             ]
//                                 : null,
//                           ),
//                           child: Text(
//                             'Sign In',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: !_isRegisterMode ? FontWeight.w800 : FontWeight.w600,
//                               color: !_isRegisterMode ? AppColors.brandOrange : AppColors.textSecondary,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 14),
//
//               // Form fields
//               if (_isRegisterMode) ...[
//                 // Register Mode: Name, Email, Phone, Password
//                 CustomTextField(
//                   controller: _nameController,
//                   label: 'Full Name',
//                   hint: 'e.g. Ananya Sharma',
//                   prefixIcon: const Icon(Icons.person_outline, size: 18),
//                 ),
//                 const SizedBox(height: 10),
//                 CustomTextField(
//                   controller: _emailController,
//                   label: 'Email Address',
//                   hint: 'e.g. ananya@example.com',
//                   keyboardType: TextInputType.emailAddress,
//                   prefixIcon: const Icon(Icons.mail_outline, size: 18),
//                 ),
//                 const SizedBox(height: 10),
//                 CustomTextField(
//                   controller: _phoneController,
//                   label: 'Mobile Number',
//                   hint: 'e.g. 9876543210',
//                   keyboardType: TextInputType.phone,
//                   prefixIcon: const Icon(Icons.phone_outlined, size: 18),
//                 ),
//                 const SizedBox(height: 10),
//                 CustomTextField(
//                   controller: _passwordController,
//                   label: 'Create Password',
//                   hint: 'At least 6 characters',
//                   obscureText: _obscurePassword,
//                   prefixIcon: const Icon(Icons.lock_outline, size: 18),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                       size: 18,
//                     ),
//                     onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 CustomButton(
//                   text: 'Register & Continue to Checkout',
//                   isLoading: isAuthLoading,
//                   icon: Icons.check_circle_outline,
//                   onPressed: _handleRegister,
//                 ),
//               ] else ...[
//                 // Sign In Mode: Email/Phone, Password
//                 CustomTextField(
//                   controller: _emailController,
//                   label: 'Email or Mobile Number',
//                   hint: 'e.g. ananya@example.com or 9876543210',
//                   keyboardType: TextInputType.emailAddress,
//                   prefixIcon: const Icon(Icons.mail_outline, size: 18),
//                 ),
//                 const SizedBox(height: 10),
//                 CustomTextField(
//                   controller: _passwordController,
//                   label: 'Password',
//                   hint: 'Enter your password',
//                   obscureText: _obscurePassword,
//                   prefixIcon: const Icon(Icons.lock_outline, size: 18),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                       size: 18,
//                     ),
//                     onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 CustomButton(
//                   text: 'Sign In & Continue',
//                   isLoading: isAuthLoading,
//                   icon: Icons.login_rounded,
//                   onPressed: _handleLogin,
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAddressSelector(CheckoutReadyState state) {
//     return BlocBuilder<AddressBloc, AddressState>(
//       builder: (context, addrState) {
//         final List<AddressModel> addresses =
//         addrState is AddressLoadedState ? addrState.addresses : <AddressModel>[];
//         final selected = state.selectedAddress ??
//             (addrState is AddressLoadedState ? addrState.defaultAddress : null);
//
//         // Fetch current authenticated user to prefill name/phone for new addresses
//         final authState = context.read<AuthBloc>().state;
//         final currentUser = authState is AuthenticatedState ? authState.user : null;
//
//         if (addresses.isEmpty) {
//           return Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.borderLight),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.location_off_outlined, color: AppColors.textTertiary),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'No address found. Please add a shipping address.',
//                     style: AppTextStyle.bodySmall,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => AddEditAddressScreen(
//                           initialFullName: currentUser?.name,
//                           initialPhone: currentUser?.phone,
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text('Add'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: AppColors.surface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: AppColors.borderLight),
//             boxShadow: const [
//               BoxShadow(
//                 color: AppColors.shadow,
//                 blurRadius: 6,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: AppColors.primaryMuted,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           selected?.addressType.toUpperCase() ?? 'HOME',
//                           style: AppTextStyle.badgeText.copyWith(color: AppColors.primary),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         selected?.fullName ?? (currentUser?.name ?? 'Recipient'),
//                         style: AppTextStyle.labelLarge,
//                       ),
//                     ],
//                   ),
//                   TextButton(
//                     onPressed: () => _showAddressSelectionModal(
//                       context,
//                       addresses,
//                       selected,
//                       currentUser?.name,
//                       currentUser?.phone,
//                     ),
//                     child: Text('Change', style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary)),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 selected?.formattedAddress ?? 'No address selected',
//                 style: AppTextStyle.bodySmall,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Mobile: ${selected?.mobileNumber ?? currentUser?.phone ?? ""}',
//                 style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showAddressSelectionModal(
//       BuildContext context,
//       List<AddressModel> addresses,
//       AddressModel? current,
//       String? defaultName,
//       String? defaultPhone,
//       ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (modalCtx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Select Delivery Address', style: AppTextStyle.sectionHeading),
//                       TextButton.icon(
//                         icon: const Icon(Icons.add, size: 16),
//                         label: const Text('Add New'),
//                         onPressed: () {
//                           Navigator.pop(modalCtx);
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (_) => AddEditAddressScreen(
//                                 initialFullName: defaultName,
//                                 initialPhone: defaultPhone,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Divider(),
//                 Flexible(
//                   child: ListView.separated(
//                     shrinkWrap: true,
//                     itemCount: addresses.length,
//                     separatorBuilder: (_, _) => const Divider(height: 1),
//                     itemBuilder: (ctx, index) {
//                       final addr = addresses[index];
//                       final isSelected = current?.id == addr.id;
//
//                       return ListTile(
//                         leading: Icon(
//                           isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//                           color: isSelected ? AppColors.primary : AppColors.textTertiary,
//                         ),
//                         title: Text(
//                           '${addr.fullName} (${addr.addressType})',
//                           style: AppTextStyle.labelMedium,
//                         ),
//                         subtitle: Text(addr.formattedAddress, style: AppTextStyle.caption),
//                         onTap: () {
//                           context.read<CheckoutBloc>().add(
//                             SelectDeliveryAddressEvent(address: addr),
//                           );
//                           Navigator.pop(modalCtx);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildItemsPreview(CartLoadedState cartState) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderLight),
//       ),
//       child: ListView.separated(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: cartState.items.length,
//         separatorBuilder: (_, _) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final item = cartState.items[index];
//           return Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(6),
//                   child: SizedBox(
//                     width: 50,
//                     height: 60,
//                     child: NetworkImageWithFallback(
//                       imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.product.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
//                       ),
//                       Text(
//                         'Size: ${item.selectedSize} | Qty: ${item.quantity}',
//                         style: AppTextStyle.caption,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(Formatters.formatPrice(item.totalPrice), style: AppTextStyle.labelMedium),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodSelector(CheckoutReadyState state) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderLight),
//       ),
//       child: Column(
//         children: [
//           // Cash on Delivery Option
//           _buildPaymentOption(
//             title: 'Cash on Delivery (COD)',
//             subtitle: 'Pay at your doorstep via cash or UPI',
//             icon: Icons.payments_outlined,
//             value: 'Cash on Delivery',
//             selectedValue: state.selectedPaymentMethod,
//           ),
//           const Divider(height: 12),
//           // Online Payment (UPI / Cards / Netbanking)
//           _buildPaymentOption(
//             title: 'Online Payment (UPI, Cards, NetBanking)',
//             subtitle: 'Instant secure checkout placeholder',
//             icon: Icons.account_balance_wallet_outlined,
//             value: 'Online Payment',
//             selectedValue: state.selectedPaymentMethod,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentOption({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required String value,
//     required String selectedValue,
//   }) {
//     final isSelected = value == selectedValue;
//
//     return GestureDetector(
//       onTap: () {
//         context.read<CheckoutBloc>().add(SelectPaymentMethodEvent(paymentMethod: value));
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Row(
//           children: [
//             Icon(
//               isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//               color: isSelected ? AppColors.primary : AppColors.textTertiary,
//               size: 20,
//             ),
//             const SizedBox(width: 10),
//             Icon(icon, color: AppColors.primary, size: 22),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: AppTextStyle.labelMedium),
//                   Text(subtitle, style: AppTextStyle.caption),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBillDetails(CartLoadedState cartState) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderLight),
//       ),
//       child: Column(
//         children: [
//           _buildRow('Items Total', Formatters.formatPrice(cartState.originalSubtotal)),
//           if (cartState.productDiscount > 0)
//             _buildRow('Product Discount', '- ${Formatters.formatPrice(cartState.productDiscount)}',
//                 color: AppColors.success),
//           if (cartState.couponDiscount > 0)
//             _buildRow('Coupon (${cartState.appliedCoupon})',
//                 '- ${Formatters.formatPrice(cartState.couponDiscount)}',
//                 color: AppColors.success),
//           _buildRow(
//             'Delivery Charges',
//             cartState.deliveryFee == 0 ? 'FREE' : Formatters.formatPrice(cartState.deliveryFee),
//             color: cartState.deliveryFee == 0 ? AppColors.success : null,
//           ),
//           const Divider(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Total Amount', style: AppTextStyle.labelLarge),
//               Text(Formatters.formatPrice(cartState.grandTotal), style: AppTextStyle.productPriceLarge),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRow(String label, String value, {Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
//           Text(
//             value,
//             style: AppTextStyle.caption.copyWith(
//               fontWeight: FontWeight.w600,
//               color: color ?? AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../bloc/authbloc/auth_bloc.dart';
import '../bloc/authbloc/auth_event.dart';
import '../bloc/authbloc/auth_state.dart';
import '../bloc/cartbloc/cart_bloc.dart';
import '../bloc/cartbloc/cart_event.dart';
import '../bloc/cartbloc/cart_state.dart';
import '../bloc/checkoutbloc/checkout_bloc.dart';
import '../bloc/checkoutbloc/checkout_event.dart';
import '../bloc/checkoutbloc/checkout_state.dart';
import '../bloc/ordersbloc/order_bloc.dart';
import '../bloc/ordersbloc/order_event.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/app_animations.dart';
import '../core/utils/formatters.dart';
import '../data/models/address_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/network_image_with_fallback.dart';
import 'add_edit_address_screen.dart';
import 'checkout_auth_screen.dart';
import 'main_bottom_nav_screen.dart';
import 'order_details_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure auth status is verified and fresh
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    context.read<AddressBloc>().add(const LoadAddressesEvent());

    final cartState = context.read<CartBloc>().state;
    final coupon = cartState is CartLoadedState ? cartState.appliedCoupon : null;

    final addressState = context.read<AddressBloc>().state;
    AddressModel? defaultAddr;
    if (addressState is AddressLoadedState) {
      defaultAddr = addressState.defaultAddress;
    }

    context.read<CheckoutBloc>().add(
      InitCheckoutEvent(
        selectedAddress: defaultAddr,
        couponCode: coupon,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showOrderSuccessDialog(BuildContext context, dynamic order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedSuccessCheckmark(size: 80),
                const SizedBox(height: 20),
                Text('Order Placed Successfully!', style: AppTextStyle.sectionHeading),
                const SizedBox(height: 8),
                Text(
                  'Order ID: ${order.id}',
                  style: AppTextStyle.labelLarge.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  'Thank you for shopping local with Shoploc. Your order has been confirmed and is being hand-packed by our boutique partner.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.description,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'View Order Details',
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Continue Shopping',
                  type: ButtonType.outlined,
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainBottomNavScreen(initialIndex: 0),
                      ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyle.appBarTitle),
      ),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutOrderSuccessState) {
            context.read<OrderBloc>().add(PlaceOrderEvent(order: state.placedOrder));
            context.read<CartBloc>().add(const ClearCartEvent());
            _showOrderSuccessDialog(context, state.placedOrder);
          } else if (state is CheckoutErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, checkoutState) {
          final isLoading = checkoutState is CheckoutLoadingState;
          final readyState = checkoutState is CheckoutReadyState
              ? checkoutState
              : const CheckoutReadyState();

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoadedState || cartState.isEmpty) {
                return Center(
                  child: Text('Your cart is empty', style: AppTextStyle.sectionHeading),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Customer Account & Contact (Register / Login)
                          _buildSectionTitle('1. Customer Account & Contact'),
                          const SizedBox(height: 8),
                          _buildAccountSection(),

                          const SizedBox(height: 24),

                          // 2. Delivery Address Card
                          _buildSectionTitle('2. Delivery Address'),
                          const SizedBox(height: 8),
                          _buildAddressSelector(readyState),

                          const SizedBox(height: 24),

                          // 3. Order Items Review
                          _buildSectionTitle('3. Items in Order (${cartState.items.length})'),
                          const SizedBox(height: 8),
                          _buildItemsPreview(cartState),

                          const SizedBox(height: 24),

                          // 4. Payment Method
                          _buildSectionTitle('4. Payment Method'),
                          const SizedBox(height: 8),
                          _buildPaymentMethodSelector(readyState),

                          const SizedBox(height: 24),

                          // 5. Order Bill Breakdown
                          _buildSectionTitle('5. Price Details'),
                          const SizedBox(height: 8),
                          _buildBillDetails(cartState),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Place Order Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.borderLight)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          offset: Offset(0, -3),
                        ),
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
                              Text(
                                Formatters.formatPrice(cartState.grandTotal),
                                style: AppTextStyle.productPriceLarge,
                              ),
                            ],
                          ),
                          const Spacer(),
                          CustomButton(
                            text: 'Place Order',
                            width: 170,
                            isLoading: isLoading,
                            icon: Icons.lock_outline_rounded,
                            onPressed: () async {
                              // Verify that customer is registered or logged in
                              final authState = context.read<AuthBloc>().state;
                              if (authState is! AuthenticatedState) {
                                // Navigate to dedicated registration and signin screen
                                final bool? loggedIn = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutAuthScreen(),
                                  ),
                                );
                                if (loggedIn != true) {
                                  return;
                                }
                              }

                              if (readyState.selectedAddress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select or add a shipping address.'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }

                              context.read<CheckoutBloc>().add(
                                SubmitOrderEvent(
                                  items: cartState.items,
                                  subtotal: cartState.subtotal,
                                  discount: cartState.productDiscount,
                                  deliveryFee: cartState.deliveryFee,
                                  couponDiscount: cartState.couponDiscount,
                                  couponCode: cartState.appliedCoupon,
                                  totalAmount: cartState.grandTotal,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.labelLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }

  /// Customer Account Section:
  /// - If ALREADY registered/logged in: Displays clean verified customer profile (name, email, phone).
  ///   Does NOT show registration or login form ("dont show next like that").
  /// - If NOT registered: Provides inline Register (Name, Email, Phone, Password) and Sign In tabs.
  Widget _buildAccountSection() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthenticatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${authState.user.name}! Your account is verified.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (authState is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, authState) {
        // CASE A: User IS registered and logged in
        if (authState is AuthenticatedState) {
          final user = authState.user;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.brandBlue.withValues(alpha: 0.12),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'REGISTERED',
                              style: TextStyle(
                                color: AppColors.brandBlue,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: AppTextStyle.bodyFont,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.caption.copyWith(color: AppColors.textPrimary),
                      ),
                      if (user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutEvent());
                  },
                  child: Text(
                    'Change',
                    style: AppTextStyle.caption.copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // CASE B: User is NOT registered / NOT logged in (Blue Theme)
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.brandBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Account',
                      style: AppTextStyle.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sign in or create an account for orders & receipts.',
                      style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CheckoutAuthScreen(),
                    ),
                  );
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: AppTextStyle.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressSelector(CheckoutReadyState state) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, addrState) {
        final List<AddressModel> addresses =
        addrState is AddressLoadedState ? addrState.addresses : <AddressModel>[];
        final selected = state.selectedAddress ??
            (addrState is AddressLoadedState ? addrState.defaultAddress : null);

        // Fetch current authenticated user to prefill name/phone for new addresses
        final authState = context.read<AuthBloc>().state;
        final currentUser = authState is AuthenticatedState ? authState.user : null;

        if (addresses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_off_outlined, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No address found. Please add a shipping address.',
                    style: AppTextStyle.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditAddressScreen(
                          initialFullName: currentUser?.name,
                          initialPhone: currentUser?.phone,
                        ),
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          selected?.addressType.toUpperCase() ?? 'HOME',
                          style: AppTextStyle.badgeText.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selected?.fullName ?? (currentUser?.name ?? 'Recipient'),
                        style: AppTextStyle.labelLarge,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showAddressSelectionModal(
                      context,
                      addresses,
                      selected,
                      currentUser?.name,
                      currentUser?.phone,
                    ),
                    child: Text('Change', style: AppTextStyle.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                selected?.formattedAddress ?? 'No address selected',
                style: AppTextStyle.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Mobile: ${selected?.mobileNumber ?? currentUser?.phone ?? ""}',
                style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressSelectionModal(
      BuildContext context,
      List<AddressModel> addresses,
      AddressModel? current,
      String? defaultName,
      String? defaultPhone,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Delivery Address', style: AppTextStyle.sectionHeading),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add New'),
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditAddressScreen(
                                initialFullName: defaultName,
                                initialPhone: defaultPhone,
                              ),
                            ),
                          );
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
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final addr = addresses[index];
                      final isSelected = current?.id == addr.id;

                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        ),
                        title: Text(
                          '${addr.fullName} (${addr.addressType})',
                          style: AppTextStyle.labelMedium,
                        ),
                        subtitle: Text(addr.formattedAddress, style: AppTextStyle.caption),
                        onTap: () {
                          context.read<CheckoutBloc>().add(
                            SelectDeliveryAddressEvent(address: addr),
                          );
                          Navigator.pop(modalCtx);
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
    );
  }

  Widget _buildItemsPreview(CartLoadedState cartState) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartState.items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = cartState.items[index];
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
                      imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '',
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
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Size: ${item.selectedSize} | Qty: ${item.quantity}',
                        style: AppTextStyle.caption,
                      ),
                    ],
                  ),
                ),
                Text(Formatters.formatPrice(item.totalPrice), style: AppTextStyle.labelMedium),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodSelector(CheckoutReadyState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Cash on Delivery Option
          _buildPaymentOption(
            title: 'Cash on Delivery (COD)',
            subtitle: 'Pay at your doorstep via cash or UPI',
            icon: Icons.payments_outlined,
            value: 'Cash on Delivery',
            selectedValue: state.selectedPaymentMethod,
          ),
          const Divider(height: 12),
          // Online Payment (UPI / Cards / Netbanking)
          _buildPaymentOption(
            title: 'Online Payment (UPI, Cards, NetBanking)',
            subtitle: 'Instant secure checkout placeholder',
            icon: Icons.account_balance_wallet_outlined,
            value: 'Online Payment',
            selectedValue: state.selectedPaymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String selectedValue,
  }) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: () {
        context.read<CheckoutBloc>().add(SelectPaymentMethodEvent(paymentMethod: value));
      },
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

  Widget _buildBillDetails(CartLoadedState cartState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _buildRow('Items Total', Formatters.formatPrice(cartState.originalSubtotal)),
          if (cartState.productDiscount > 0)
            _buildRow('Product Discount', '- ${Formatters.formatPrice(cartState.productDiscount)}',
                color: AppColors.success),
          if (cartState.couponDiscount > 0)
            _buildRow('Coupon (${cartState.appliedCoupon})',
                '- ${Formatters.formatPrice(cartState.couponDiscount)}',
                color: AppColors.success),
          _buildRow(
            'Delivery Charges',
            cartState.deliveryFee == 0 ? 'FREE' : Formatters.formatPrice(cartState.deliveryFee),
            color: cartState.deliveryFee == 0 ? AppColors.success : null,
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTextStyle.labelLarge),
              Text(Formatters.formatPrice(cartState.grandTotal), style: AppTextStyle.productPriceLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary)),
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
}

