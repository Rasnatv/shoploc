import 'package:flutter/material.dart';
import 'package:shoploc/ui/onboaring.dart';
import 'package:shoploc/ui/splashscreen.dart';
import 'core/appcolors.dart';
import 'core/apptheme.dart';
import 'core/responsive.dart';


void main() => runApp(const MyApp());

class MyApp  extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Shoploc',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    // Keeps the app centered with a max width on tablets / web.
    builder: (context, child) => ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(maxWidth: Responsive.maxAppWidth),
          child: child,
        ),
      ),
    ),
    home: const SplashPage(),
  );
}
