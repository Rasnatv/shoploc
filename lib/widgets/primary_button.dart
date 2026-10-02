import 'package:flutter/material.dart';

/// Full-width dark button (Proceed to Checkout, Place Order...).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryButton(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
}
