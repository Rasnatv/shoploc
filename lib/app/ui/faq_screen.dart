//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../core/constants/app_constants.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
// import 'enquiry_screen.dart';
//
// class FaqItem {
//   final String question;
//   final String answer;
//   final String category; // 'Orders', 'Shipping', 'Payment', 'Account'
//
//   const FaqItem({
//     required this.question,
//     required this.answer,
//     required this.category,
//   });
// }
//
// class FaqScreen extends StatefulWidget {
//   const FaqScreen({super.key});
//
//   @override
//   State<FaqScreen> createState() => _FaqScreenState();
// }
//
// /// Alias for FaqScreen named QuestionsScreen
// typedef QuestionsScreen = FaqScreen;
//
// class _FaqScreenState extends State<FaqScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedCategory = 'All';
//   String _searchQuery = '';
//
//   // Keyed by question text so expanded state stays correct when filtering.
//   final Set<String> _expandedQuestions = {};
//
//   final List<String> _categories = const [
//     'All',
//     'Orders',
//     'Shipping',
//     'Payment',
//     'Account',
//   ];
//
//   final List<FaqItem> _allFaqs = const [
//     // ───────────── Orders ─────────────
//     FaqItem(
//       category: 'Orders',
//       question: 'How do I place an order?',
//       answer:
//       'Browse products, select your size and colour, then click "Add to Cart". When you\'re ready, go to your cart and click "Checkout". Fill in your delivery details and complete the payment to confirm your order.',
//     ),
//     FaqItem(
//       category: 'Orders',
//       question: 'Can I cancel or modify my order?',
//       answer:
//       'All orders are final once placed and cannot be cancelled or modified by customers. If you believe there is an urgent issue with your order, please call our customer care immediately at +91 98765 43210 or email info@shoploc.in. Our team will review the situation and assist where possible, but we cannot guarantee changes once an order is confirmed.',
//     ),
//     FaqItem(
//       category: 'Orders',
//       question: 'How do I track my order?',
//       answer:
//       'Once your order is dispatched, you\'ll receive an email with a tracking number. You can also check the status anytime under My Account → My Orders.',
//     ),
//     FaqItem(
//       category: 'Orders',
//       question: 'What if an item is out of stock?',
//       answer:
//       'Out-of-stock items cannot be added to your cart. Save the product to your wishlist and check back later. For urgent requests, contact us directly and we\'ll let you know when it\'s available.',
//     ),
//     FaqItem(
//       category: 'Orders',
//       question: 'What if I received a damaged or wrong item?',
//       answer:
//       'Please contact us within 48 hours of delivery with clear photos of the item and your Order ID. Send them to info@shoploc.in or call our customer care. We will review each case individually and may offer a replacement or resolution at our discretion.',
//     ),
//
//     // ───────────── Shipping ─────────────
//     FaqItem(
//       category: 'Shipping',
//       question: 'How long does delivery take?',
//       answer:
//       'Standard delivery takes 5–7 business days. Remote areas may take an additional 2–3 days. Exact estimated delivery dates are shown at checkout based on your pin code.',
//     ),
//     FaqItem(
//       category: 'Shipping',
//       question: 'How much does shipping cost?',
//       answer:
//       'Shipping charges are calculated at checkout based on your delivery location and order size. The exact shipping fee will be shown before you confirm your payment.',
//     ),
//     FaqItem(
//       category: 'Shipping',
//       question: 'Do you ship across India?',
//       answer:
//       'Yes, we ship to all serviceable pin codes across India. Enter your pin code at checkout to confirm delivery availability to your area.',
//     ),
//     FaqItem(
//       category: 'Shipping',
//       question: 'What happens if delivery fails?',
//       answer:
//       'If a delivery attempt fails due to an incorrect address or unavailability, the courier may attempt re-delivery. Please ensure your address and phone number are accurate when placing the order. Failed deliveries are not eligible for refunds.',
//     ),
//
//     // ───────────── Payment ─────────────
//     FaqItem(
//       category: 'Payment',
//       question: 'What payment methods do you accept?',
//       answer:
//       'We accept UPI (GPay, PhonePe, Paytm, BHIM), Credit Cards, Debit Cards, Net Banking, and Wallets. All payments are processed securely through Razorpay.',
//     ),
//     FaqItem(
//       category: 'Payment',
//       question: 'Is Cash on Delivery (COD) available?',
//       answer:
//       'No, we do not offer Cash on Delivery. All orders must be paid online at the time of checkout. We accept UPI, cards, net banking, and wallets via Razorpay.',
//     ),
//     FaqItem(
//       category: 'Payment',
//       question: 'Is my payment information safe?',
//       answer:
//       'Yes. We do not store your card details. All payments are processed through Razorpay\'s PCI-DSS compliant gateway with SSL encryption and OTP-based bank authentication.',
//     ),
//     FaqItem(
//       category: 'Payment',
//       question: 'My payment failed but money was deducted. What should I do?',
//       answer:
//       'If your payment was deducted but your order was not confirmed, the amount will be automatically reversed to your original payment method within 5–7 business days by Razorpay. If it isn\'t reversed after 7 days, contact us at info@shoploc.in with your transaction reference number and we\'ll follow up with Razorpay.',
//     ),
//     FaqItem(
//       category: 'Payment',
//       question: 'Are there any hidden charges?',
//       answer:
//       'No. The amount shown at checkout — including product price, taxes, and shipping — is the final amount you pay. There are no hidden fees or surprise deductions.',
//     ),
//
//     // ───────────── Account ─────────────
//     FaqItem(
//       category: 'Account',
//       question: 'Do I need an account to order?',
//       answer:
//       'You can browse freely without an account, but you\'ll need to register to place an order. An account lets you track orders, manage your wishlist, and save delivery addresses.',
//     ),
//     FaqItem(
//       category: 'Account',
//       question: 'How do I reset my password?',
//       answer:
//       'Click "Forgot password" on the login page and enter your registered email. You\'ll receive a reset link within a few minutes. Check your spam folder if you don\'t see it.',
//     ),
//     FaqItem(
//       category: 'Account',
//       question: 'How do I update my address or phone number?',
//       answer:
//       'Go to My Account → My Profile to update your personal details, saved addresses, and contact information at any time.',
//     ),
//   ];
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   List<FaqItem> get _filteredFaqs {
//     final query = _searchQuery.toLowerCase();
//     return _allFaqs.where((faq) {
//       final matchesCategory =
//           _selectedCategory == 'All' || faq.category == _selectedCategory;
//       final matchesSearch = query.isEmpty ||
//           faq.question.toLowerCase().contains(query) ||
//           faq.answer.toLowerCase().contains(query);
//       return matchesCategory && matchesSearch;
//     }).toList();
//   }
//
//   void _copyContact(String label, String value) {
//     Clipboard.setData(ClipboardData(text: value));
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$label copied: $value',
//             style: TextStyle(fontFamily: AppTextStyle.bodyFont)),
//         backgroundColor: const Color(0xFF1E60ED),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final filtered = _filteredFaqs;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFBFD),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'FAQ',
//           style: AppTextStyle.appBarTitle,
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 10),
//
//               // 1. Page Header
//               Center(
//                 child: Text(
//                   'Frequently asked questions',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.playfairDisplay(
//                     textStyle: TextStyle(
//                       fontFamily: AppTextStyle.headingFont,
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       color: const Color(0xFF111827),
//                       letterSpacing: -0.4,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Center(
//                 child: Text(
//                   'Find quick answers about orders, shipping, payments and more.',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.plusJakartaSans(
//                     textStyle: TextStyle(
//                       fontFamily: AppTextStyle.bodyFont,
//                       fontSize: 13.5,
//                       color: const Color(0xFF6B7280),
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 22),
//
//               // 2. Search Box
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE5E7EB)),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Color(0x06000000),
//                       blurRadius: 10,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         style: TextStyle(
//                           fontFamily: AppTextStyle.bodyFont,
//                           fontSize: 14,
//                           color: AppColors.textPrimary,
//                         ),
//                         onChanged: (val) {
//                           setState(() {
//                             _searchQuery = val.trim();
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Search a question...',
//                           hintStyle: GoogleFonts.plusJakartaSans(
//                             textStyle: TextStyle(
//                               fontFamily: AppTextStyle.bodyFont,
//                               color: const Color(0xFF9CA3AF),
//                               fontSize: 14,
//                             ),
//                           ),
//                           prefixIcon: const Icon(
//                             Icons.search,
//                             color: Color(0xFF9CA3AF),
//                             size: 20,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 6),
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF111827),
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 18,
//                             vertical: 11,
//                           ),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _searchQuery = _searchController.text.trim();
//                           });
//                         },
//                         child: Text(
//                           'Search',
//                           style: GoogleFonts.plusJakartaSans(
//                             textStyle: TextStyle(
//                               fontFamily: AppTextStyle.bodyFont,
//                               fontSize: 13.5,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 18),
//
//               // 3. Category Filter Pills
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 physics: const BouncingScrollPhysics(),
//                 child: Row(
//                   children: _categories.map((cat) {
//                     final isSelected = _selectedCategory == cat;
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             _selectedCategory = cat;
//                           });
//                         },
//                         borderRadius: BorderRadius.circular(24),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 18,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? const Color(0xFF111827)
//                                 : Colors.white,
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(
//                               color: isSelected
//                                   ? const Color(0xFF111827)
//                                   : const Color(0xFFE5E7EB),
//                             ),
//                           ),
//                           child: Text(
//                             cat,
//                             style: GoogleFonts.plusJakartaSans(
//                               textStyle: TextStyle(
//                                 fontFamily: AppTextStyle.bodyFont,
//                                 fontSize: 13,
//                                 fontWeight: isSelected
//                                     ? FontWeight.w700
//                                     : FontWeight.w500,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : const Color(0xFF4B5563),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // 4. Category Section Subtitle
//               Row(
//                 children: [
//                   Text(
//                     _selectedCategory.toUpperCase(),
//                     style: GoogleFonts.plusJakartaSans(
//                       textStyle: TextStyle(
//                         fontFamily: AppTextStyle.bodyFont,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 1.2,
//                         color: const Color(0xFF9CA3AF),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Divider(
//                       color: Color(0xFFE5E7EB),
//                       thickness: 1,
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 14),
//
//               // 5. Accordion FAQ Cards
//               if (filtered.isEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.search_off_rounded,
//                         size: 42,
//                         color: Color(0xFF9CA3AF),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'No matching questions found',
//                         style: GoogleFonts.plusJakartaSans(
//                           textStyle: TextStyle(
//                             fontFamily: AppTextStyle.bodyFont,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'Try searching for another keyword or reach out directly to our team below.',
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.plusJakartaSans(
//                           textStyle: TextStyle(
//                             fontFamily: AppTextStyle.bodyFont,
//                             fontSize: 12.5,
//                             color: const Color(0xFF6B7280),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 ...filtered.map((faq) {
//                   final isExpanded = _expandedQuestions.contains(faq.question);
//
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: isExpanded
//                             ? const Color(0xFFD1D5DB)
//                             : const Color(0xFFE5E7EB),
//                       ),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Color(0x04000000),
//                           blurRadius: 6,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: Column(
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               setState(() {
//                                 if (isExpanded) {
//                                   _expandedQuestions.remove(faq.question);
//                                 } else {
//                                   _expandedQuestions.add(faq.question);
//                                 }
//                               });
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 16,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       faq.question,
//                                       style: GoogleFonts.plusJakartaSans(
//                                         textStyle: TextStyle(
//                                           fontFamily: AppTextStyle.bodyFont,
//                                           fontSize: 14.5,
//                                           fontWeight: FontWeight.w700,
//                                           color: const Color(0xFF111827),
//                                           height: 1.3,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Container(
//                                     width: 28,
//                                     height: 28,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: const Color(0xFFE5E7EB),
//                                       ),
//                                     ),
//                                     child: Icon(
//                                       isExpanded ? Icons.remove : Icons.add,
//                                       size: 16,
//                                       color: const Color(0xFF6B7280),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           if (isExpanded) ...[
//                             const Divider(
//                               height: 1,
//                               color: Color(0xFFF3F4F6),
//                             ),
//                             Container(
//                               width: double.infinity,
//                               padding:
//                               const EdgeInsets.fromLTRB(18, 14, 18, 16),
//                               color: const Color(0xFFFAFAFA),
//                               child: Text(
//                                 faq.answer,
//                                 style: GoogleFonts.plusJakartaSans(
//                                   textStyle: TextStyle(
//                                     fontFamily: AppTextStyle.bodyFont,
//                                     fontSize: 13.5,
//                                     color: const Color(0xFF4B5563),
//                                     height: 1.5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//
//               const SizedBox(height: 24),
//
//               // 6. "Still have a question?" Contact Card
//               Container(
//                 padding: const EdgeInsets.all(22),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF3F4F6),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(color: const Color(0xFFE5E7EB)),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Still have a question?',
//                       style: GoogleFonts.playfairDisplay(
//                         textStyle: TextStyle(
//                           fontFamily: AppTextStyle.headingFont,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                           color: const Color(0xFF111827),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Our team is available Mon–Sat, 9:00 AM – 6:00 PM',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.plusJakartaSans(
//                         textStyle: TextStyle(
//                           fontFamily: AppTextStyle.bodyFont,
//                           fontSize: 13,
//                           color: const Color(0xFF6B7280),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Wrap(
//                       alignment: WrapAlignment.center,
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         // Call Us
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF111827),
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 10,
//                             ),
//                           ),
//                           onPressed: () => _copyContact(
//                             'Phone number',
//                             AppConstants.supportPhone,
//                           ),
//                           icon: const Icon(Icons.phone, size: 15),
//                           label: Text(
//                             'Call us',
//                             style: GoogleFonts.plusJakartaSans(
//                               textStyle: TextStyle(
//                                 fontFamily: AppTextStyle.bodyFont,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         // Email Us
//                         OutlinedButton.icon(
//                           style: OutlinedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFF111827),
//                             side: const BorderSide(color: Color(0xFFD1D5DB)),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 10,
//                             ),
//                           ),
//                           onPressed: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => const EnquiryScreen(),
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.mail_outline, size: 16),
//                           label: Text(
//                             'Email us',
//                             style: GoogleFonts.plusJakartaSans(
//                               textStyle: TextStyle(
//                                 fontFamily: AppTextStyle.bodyFont,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         // WhatsApp
//                         OutlinedButton.icon(
//                           style: OutlinedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFF16A34A),
//                             side: const BorderSide(color: Color(0xFFD1D5DB)),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 10,
//                             ),
//                           ),
//                           onPressed: () => _copyContact(
//                             'WhatsApp support',
//                             AppConstants.supportPhone,
//                           ),
//                           icon: const Icon(Icons.chat_bubble_outline, size: 16),
//                           label: Text(
//                             'WhatsApp',
//                             style: GoogleFonts.plusJakartaSans(
//                               textStyle: TextStyle(
//                                 fontFamily: AppTextStyle.bodyFont,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoploc/app/widgets/appsnackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category; // 'Orders', 'Shipping', 'Payment', 'Account'

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

/// Alias for FaqScreen named QuestionsScreen
typedef QuestionsScreen = FaqScreen;

class _FaqScreenState extends State<FaqScreen> {
  // ---------- Support contact details ----------
  static const String _supportPhone = '+918848748469'; // dialer / tel:
  static const String _supportWhatsapp = '918848748469'; // wa.me (no +)
  static const String _supportEmail = 'razicdeli@gmail.com';

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Keyed by question text so expanded state stays correct when filtering.
  final Set<String> _expandedQuestions = {};

  final List<String> _categories = const [
    'All',
    'Orders',
    'Shipping',
    'Payment',
    'Account',
  ];

  final List<FaqItem> _allFaqs = const [
    // ───────────── Orders ─────────────
    FaqItem(
      category: 'Orders',
      question: 'How do I place an order?',
      answer:
      'Browse products, select your size and colour, then click "Add to Cart". When you\'re ready, go to your cart and click "Checkout". Fill in your delivery details and complete the payment to confirm your order.',
    ),
    FaqItem(
      category: 'Orders',
      question: 'Can I cancel or modify my order?',
      answer:
      'All orders are final once placed and cannot be cancelled or modified by customers. If you believe there is an urgent issue with your order, please call our customer care immediately at +91 88487 48469 or email razicdeli@gmail.com. Our team will review the situation and assist where possible, but we cannot guarantee changes once an order is confirmed.',
    ),
    FaqItem(
      category: 'Orders',
      question: 'How do I track my order?',
      answer:
      'Once your order is dispatched, you\'ll receive an email with a tracking number. You can also check the status anytime under My Account → My Orders.',
    ),
    FaqItem(
      category: 'Orders',
      question: 'What if an item is out of stock?',
      answer:
      'Out-of-stock items cannot be added to your cart. Save the product to your wishlist and check back later. For urgent requests, contact us directly and we\'ll let you know when it\'s available.',
    ),
    FaqItem(
      category: 'Orders',
      question: 'What if I received a damaged or wrong item?',
      answer:
      'Please contact us within 48 hours of delivery with clear photos of the item and your Order ID. Send them to razicdeli@gmail.com or call our customer care. We will review each case individually and may offer a replacement or resolution at our discretion.',
    ),

    // ───────────── Shipping ─────────────
    FaqItem(
      category: 'Shipping',
      question: 'How long does delivery take?',
      answer:
      'Standard delivery takes 5–7 business days. Remote areas may take an additional 2–3 days. Exact estimated delivery dates are shown at checkout based on your pin code.',
    ),
    FaqItem(
      category: 'Shipping',
      question: 'How much does shipping cost?',
      answer:
      'Shipping charges are calculated at checkout based on your delivery location and order size. The exact shipping fee will be shown before you confirm your payment.',
    ),
    FaqItem(
      category: 'Shipping',
      question: 'Do you ship across India?',
      answer:
      'Yes, we ship to all serviceable pin codes across India. Enter your pin code at checkout to confirm delivery availability to your area.',
    ),
    FaqItem(
      category: 'Shipping',
      question: 'What happens if delivery fails?',
      answer:
      'If a delivery attempt fails due to an incorrect address or unavailability, the courier may attempt re-delivery. Please ensure your address and phone number are accurate when placing the order. Failed deliveries are not eligible for refunds.',
    ),

    // ───────────── Payment ─────────────
    FaqItem(
      category: 'Payment',
      question: 'What payment methods do you accept?',
      answer:
      'We accept UPI (GPay, PhonePe, Paytm, BHIM), Credit Cards, Debit Cards, Net Banking, and Wallets. All payments are processed securely through Razorpay.',
    ),
    FaqItem(
      category: 'Payment',
      question: 'Is Cash on Delivery (COD) available?',
      answer:
      'No, we do not offer Cash on Delivery. All orders must be paid online at the time of checkout. We accept UPI, cards, net banking, and wallets via Razorpay.',
    ),
    FaqItem(
      category: 'Payment',
      question: 'Is my payment information safe?',
      answer:
      'Yes. We do not store your card details. All payments are processed through Razorpay\'s PCI-DSS compliant gateway with SSL encryption and OTP-based bank authentication.',
    ),
    FaqItem(
      category: 'Payment',
      question: 'My payment failed but money was deducted. What should I do?',
      answer:
      'If your payment was deducted but your order was not confirmed, the amount will be automatically reversed to your original payment method within 5–7 business days by Razorpay. If it isn\'t reversed after 7 days, contact us at razicdeli@gmail.com with your transaction reference number and we\'ll follow up with Razorpay.',
    ),
    FaqItem(
      category: 'Payment',
      question: 'Are there any hidden charges?',
      answer:
      'No. The amount shown at checkout — including product price, taxes, and shipping — is the final amount you pay. There are no hidden fees or surprise deductions.',
    ),

    // ───────────── Account ─────────────
    FaqItem(
      category: 'Account',
      question: 'Do I need an account to order?',
      answer:
      'You can browse freely without an account, but you\'ll need to register to place an order. An account lets you track orders, manage your wishlist, and save delivery addresses.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How do I reset my password?',
      answer:
      'Click "Forgot password" on the login page and enter your registered email. You\'ll receive a reset link within a few minutes. Check your spam folder if you don\'t see it.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How do I update my address or phone number?',
      answer:
      'Go to My Account → My Profile to update your personal details, saved addresses, and contact information at any time.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    final query = _searchQuery.toLowerCase();
    return _allFaqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ---------- Contact actions ----------
  Future<void> _launch(Uri uri, String errorMessage) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) AppSnackbar.error(errorMessage);
    } catch (_) {
      AppSnackbar.error(errorMessage);
    }
  }

  /// Opens the phone dialer with the support number.
  void _callSupport() =>
      _launch(Uri(scheme: 'tel', path: _supportPhone), 'Could not open dialer');

  /// Opens the email app with the support address.
  void _emailSupport() => _launch(
    Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Shoploc support enquiry'},
    ),
    'Could not open email app',
  );

  /// Opens a WhatsApp chat with the support number.
  void _whatsappSupport() => _launch(
    Uri.parse('https://wa.me/$_supportWhatsapp'),
    'Could not open WhatsApp',
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFaqs;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FAQ',
          style: AppTextStyle.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // 1. Page Header
              Center(
                child: Text(
                  'Frequently asked questions',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.headingFont,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Find quick answers about orders, shipping, payments and more.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    textStyle: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontSize: 13.5,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 2. Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search a question...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontFamily: AppTextStyle.bodyFont,
                              color: const Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = _searchController.text.trim();
                          });
                        },
                        child: Text(
                          'Search',
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: TextStyle(
                              fontFamily: AppTextStyle.bodyFont,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF111827)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF111827)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Category Section Subtitle
              Row(
                children: [
                  Text(
                    _selectedCategory.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      textStyle: TextStyle(
                        fontFamily: AppTextStyle.bodyFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE5E7EB),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Accordion FAQ Cards
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 42,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No matching questions found',
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try searching for another keyword or reach out directly to our team below.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          textStyle: TextStyle(
                            fontFamily: AppTextStyle.bodyFont,
                            fontSize: 12.5,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.map((faq) {
                  final isExpanded = _expandedQuestions.contains(faq.question);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isExpanded
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedQuestions.remove(faq.question);
                                } else {
                                  _expandedQuestions.add(faq.question);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: GoogleFonts.plusJakartaSans(
                                        textStyle: TextStyle(
                                          fontFamily: AppTextStyle.bodyFont,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Icon(
                                      isExpanded ? Icons.remove : Icons.add,
                                      size: 16,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(
                              height: 1,
                              color: Color(0xFFF3F4F6),
                            ),
                            Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.fromLTRB(18, 14, 18, 16),
                              color: const Color(0xFFFAFAFA),
                              child: Text(
                                faq.answer,
                                style: GoogleFonts.plusJakartaSans(
                                  textStyle: TextStyle(
                                    fontFamily: AppTextStyle.bodyFont,
                                    fontSize: 13.5,
                                    color: const Color(0xFF4B5563),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // 6. "Still have a question?" Contact Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Still have a question?',
                      style: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.headingFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Our team is available Mon–Sat, 9:00 AM – 6:00 PM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        textStyle: TextStyle(
                          fontFamily: AppTextStyle.bodyFont,
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Call Us -> opens phone dialer
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111827),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _callSupport,
                          icon: const Icon(Icons.phone, size: 15),
                          label: Text(
                            'Call us',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Email Us -> opens email app
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF111827),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _emailSupport,
                          icon: const Icon(Icons.mail_outline, size: 16),
                          label: Text(
                            'Email us',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // WhatsApp -> opens WhatsApp chat
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF16A34A),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onPressed: _whatsappSupport,
                          icon: const FaIcon(FontAwesomeIcons.whatsapp,
                              size: 17, color: Color(0xFF25D366)),
                          label: Text(
                            'WhatsApp',
                            style: GoogleFonts.plusJakartaSans(
                              textStyle: TextStyle(
                                fontFamily: AppTextStyle.bodyFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}