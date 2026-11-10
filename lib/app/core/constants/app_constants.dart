/// Application wide constants for Shoploc.
class AppConstants {
  AppConstants._();

  static const String appName = 'Shoploc';
  static const String appTagline = 'Quality products delivered to your doorstep.';
  static const String appSubTagline = 'Shop local, shop smart.';

  // Currency
  static const String currency = '₹';

  // Shipping
  static const double freeShippingThreshold = 999.0;
  static const double standardShippingFee = 60.0;

  // Contact & Brand
  static const String supportPhone = '+91 88487 48469';
  static const String supportEmail = 'info@shoploc.in';
  static const String altEmail = 'razicdeli@gmail.com';
  static const String brandAddress = 'Deli, Kalanad (PO), Kasaragod – 671317, Kerala, India';
  static const String businessHours = 'Mon – Sat, 9:00 AM – 6:00 PM IST';
  static const String websiteUrl = 'https://shoploc.in';

  // Storage Keys
  static const String keyIsLoggedIn = 'shoploc_is_logged_in';
  static const String keyOnboardingComplete = 'shoploc_onboarding_complete';
  static const String keyCurrentUser = 'shoploc_current_user';
  static const String keyWishlist = 'shoploc_wishlist_items';
  static const String keyCart = 'shoploc_cart_items';
  static const String keyAddresses = 'shoploc_addresses';
  static const String keyOrders = 'shoploc_orders';
  static const String keyRecentlyViewed = 'shoploc_recently_viewed';
  static const String keyNotifications = 'shoploc_notifications';

  // Available Coupon Codes
  static const Map<String, double> couponPercentages = {
    'SHOPLOC10': 10.0,
    'FESTIVE20': 20.0,
    'WELCOME15': 15.0,
  };

  static const Map<String, double> couponFlatDiscounts = {
    'FIRST50': 50.0,
    'SHOPLOC100': 100.0,
  };
}

