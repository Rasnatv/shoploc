// /// Central place for all asset paths.
// /// Put your image files inside  assets/images/  with these exact names
// /// (or change the names here).
// class AppAssets {
//   AppAssets._();
//
//   static const String splashBg = 'assets/images/new.png';
//   static const String logo = 'assets/images/logoss.png';
//   static const String onboarding='assets/images/shoplocillustration.png';
//   static const String banner='assets/images/banner.png';
//   static const String product1='assets/images/kurti.png';
//   static const String product2='assets/images/codset.jpeg';
//   static const String product3='assets/images/dress.jpg';
// }
/// Central place for all asset paths.
/// Put your image files inside  assets/images/  with these exact names
/// (or change the names here).
class AppAssets {
  AppAssets._();

  static const String splashBg = 'assets/images/new.png';
  static const String logo = 'assets/images/logoss.png';
  static const String onboarding = 'assets/images/shoplocillustration.png';
  static const String banner = 'assets/images/banner3.jpg';
  static const String banner3 = 'assets/images/banner.png';
  static const String product1 = 'assets/images/kurti.png';
  static const String product2 = 'assets/images/codset.jpeg';
  static const String product3 = 'assets/images/dress.jpg';

  static const List<String> _categoryImages = [product1, product2, product3];

  /// Image for product cards (cycles product1, product2, product3).
  static String productImage(int index) =>
      _categoryImages[index % _categoryImages.length];

  /// Cycles product1, product2, product3 for any number of categories.
  static String categoryImage(int index) =>
      _categoryImages[index % _categoryImages.length];
}