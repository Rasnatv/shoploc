import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';

enum ButtonType { primary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(10);

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.primary ? AppColors.textLight : AppColors.primary,
          ),
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: textColor ??
                  (type == ButtonType.primary
                      ? AppColors.textLight
                      : AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (type == ButtonType.primary
                      ? AppTextStyle.buttonText
                      : AppTextStyle.buttonTextOutlined)
                  .copyWith(color: textColor),
            ),
          ),
        ],
      );
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ??
          (type == ButtonType.primary ? AppColors.primary : Colors.transparent),
      foregroundColor: textColor ??
          (type == ButtonType.primary ? AppColors.textLight : AppColors.primary),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: type == ButtonType.outlined
            ? BorderSide(color: backgroundColor ?? AppColors.primary, width: 1.2)
            : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

