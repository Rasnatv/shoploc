import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';

/// Official Shoploc Logo Widget.
/// Displays the authentic Shoploc logo featuring "Shop" in vibrant blue,
/// "Loc" in vibrant orange, and the delivery trolley cart emblem.
class ShoplocLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final double fontSize;
  final bool showTagline;
  final bool isDark;

  const ShoplocLogo({
    super.key,
    this.height,
    this.width,
    this.fontSize = 24,
    this.showTagline = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? (fontSize * 1.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Primary: Official Shoploc Logo Asset
        Image.asset(
          'assets/images/shoploc_logo.png',
          height: effectiveHeight,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // High-fidelity fallback vector
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: AppTextStyle.bodyFont,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Shop',
                        style: TextStyle(color: AppColors.brandBlue),
                      ),
                      TextSpan(
                        text: 'Loc',
                        style: TextStyle(color: AppColors.brandOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 20,
                  color: AppColors.brandOrange,
                ),
              ],
            );
          },
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            'SHOP LOCAL • SHOP SMART',
            style: AppTextStyle.caption.copyWith(
              fontSize: (fontSize * 0.38).clamp(9.0, 12.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              color: isDark ? AppColors.accentSoft : AppColors.brandOrange,
            ),
          ),
        ],
      ],
    );
  }
}
