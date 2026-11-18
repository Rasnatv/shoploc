class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://shoploc.in/api';

  // Auth
  static const String register = '/auth/register';
  static const String registerVerify = '/auth/register/verify';
  static const String login = '/auth/login';
  static const String loginVerify = '/auth/login/verify';

  //home
// ADD inside your existing ApiConstants class (file: api constants.dart)

  // Home
  static const String banners = '/banners';
  static const String categories = '/categories';
  static const String homeHighlights = '/home/highlights';
  static const String homeBestSellers = '/home/best-sellers';

  // Product lists (paginated: ?page=1&per_page=10)
  static const String newArrivals = '/products/new-arrivals';
  static const String trending = '/products/trending';
  static const String bestSellers = '/products/best-sellers';
  // Product details (POST, body: {"product_id": 28})
  static const String productDetails = '/products/details';
}