// import 'package:flutter/material.dart';
// import '../core/theme/app_colors.dart';
// import '../core/theme/app_text_style.dart';
//
// class CustomTextField extends StatelessWidget {
//   final TextEditingController? controller;
//   final String? label;
//   final String? hint;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final TextInputAction textInputAction;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final void Function(String)? onSubmitted;
//   final int maxLines;
//   final bool readOnly;
//   final VoidCallback? onTap;
//   final FocusNode? focusNode;
//   final bool autofocus;
//
//   const CustomTextField({
//     super.key,
//     this.controller,
//     this.label,
//     this.hint,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.textInputAction = TextInputAction.next,
//     this.validator,
//     this.onChanged,
//     this.onSubmitted,
//     this.maxLines = 1,
//     this.readOnly = false,
//     this.onTap,
//     this.focusNode,
//     this.autofocus = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label != null) ...[
//           Text(label!, style: AppTextStyle.inputLabel),
//           const SizedBox(height: 6),
//         ],
//         TextFormField(
//           controller: controller,
//           obscureText: obscureText,
//           keyboardType: keyboardType,
//           textInputAction: textInputAction,
//           validator: validator,
//           onChanged: onChanged,
//           onFieldSubmitted: onSubmitted,
//           maxLines: maxLines,
//           readOnly: readOnly,
//           onTap: onTap,
//           focusNode: focusNode,
//           autofocus: autofocus,
//           style: AppTextStyle.inputText,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: AppTextStyle.inputHint,
//             prefixIcon: prefixIcon,
//             suffixIcon: suffixIcon,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             filled: true,
//             fillColor: AppColors.inputBackground,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: AppColors.borderLight),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: AppColors.borderLight),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: AppColors.error),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: AppColors.error, width: 1.5),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Restrict what can be typed / pasted (e.g. digits only).
  final List<TextInputFormatter>? inputFormatters;

  /// Hard character limit (the "0/10" counter is hidden).
  final int? maxLength;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyle.inputLabel),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: AppTextStyle.inputText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyle.inputHint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '', // hide the "0/10" counter when maxLength is used
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}