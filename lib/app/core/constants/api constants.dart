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
  // Subcategory products (POST, ?page=1&per_page=10, body: {"sub_category_id": 40})
  static const String subCategoryProducts = '/subcategory/products';

  // Recent views
  // POST /recent-views            body: {"product_id": 26}  (save)
  // GET  /recent-views/top        (home section)
  // GET  /recent-views?page=1&per_page=10  (full list)
  static const String recentViews = '/recent-views';
  static const String recentViewsTop = '/recent-views/top';


  // Wishlist
  // POST /wishlist/add       body: {"product_id": 20}
  // GET  /wishlist?page=1&per_page=10
  // POST /wishlist/remove    body: {"product_id": 20}
  static const String wishlist = '/wishlist';
  static const String wishlistAdd = '/wishlist/add';
  static const String wishlistRemove = '/wishlist/remove';

  // Cart
  // GET  /cart
  // POST /cart/add      body: {"product_id": 32, "color_id": 2, "size": "Free Size", "quantity": 1}
  // POST /cart/update   body: {"cart_item_id": 99, "quantity": 3}
  // POST /cart/remove   body: {"cart_item_id": 99}
  static const String cart = '/cart';
  static const String cartAdd = '/cart/add';
  static const String cartUpdate = '/cart/update';
  static const String cartRemove = '/cart/remove';

  // Address
  // GET    /address                 -> list
  // POST   /address/add             body: first_name, last_name, phone, address, city, state, zip
  // POST   /address/update          body: address_id + same fields
  // DELETE /address/delete          body: {"address_id": 26}
  static const String address = '/address';
  static const String addressAdd = '/address/add';
  static const String addressUpdate = '/address/update';
  static const String addressDelete = '/address/delete';

  // Checkout
  // GET /order/preview       -> items in the order
  // GET /checkout/summary    -> subtotal, tax, delivery, total_amount
  static const String orderPreview = '/order/preview';
  static const String checkoutSummary = '/checkout/summary';
  // Enquiry
  // POST /enquiry   body: {name, email, subject, message}
  static const String enquiry = '/enquiry';



}
