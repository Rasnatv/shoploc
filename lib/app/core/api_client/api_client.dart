
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

import '../../data/models/addressmodel.dart';
import '../../data/models/enquirymodel.dart';
import '../../data/models/loginrequestmodel.dart';
import '../../data/models/otprequestmodel.dart';
import '../../data/models/registerrequestmodel.dart';
import '../constants/api constants.dart';

class ApiClient {
  late Dio dio;

  /// Bumps every time a 401 clears the session. Screens can listen to it.
  final ValueNotifier<int> sessionExpired = ValueNotifier<int>(0);

  ApiClient() {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
      ),
    );

    // shoploc.in has a valid SSL certificate, so there is no
    // badCertificateCallback override. Never ship that to production.

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Adds the Authorization header from the saved token
          final token = ObjectFactory().prefs.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final prefs = ObjectFactory().prefs;

          // Login / register / OTP calls must never log the user out
          final isAuthCall = error.requestOptions.path.contains('/auth/');

          // Token that was actually sent with the failed request
          final sentToken = error.requestOptions.headers['Authorization']
              ?.toString()
              .replaceFirst('Bearer ', '');

          if (error.response?.statusCode == 401 &&
              !isAuthCall &&
              prefs.isLoggedIn() == true &&
              sentToken == prefs.getAuthToken()) {
            // Must finish BEFORE handler.next, so the blocs see
            // isLoggedIn() == false when they check _sessionEnded()
            await prefs.clearSession();
            sessionExpired.value++;
          }
          handler.next(error);
        },
      ),
    );
  }

  // ---------------- AUTH ----------------

  /// POST /auth/register
  Future<Response> userReg(RegisterRequest r) =>
      dio.post(ApiConstants.register, data: r.toJson());

  /// POST /auth/register/verify
  Future<Response> userRegVerify(VerifyOtpRequest r) =>
      dio.post(ApiConstants.registerVerify, data: r.toJson());

  /// POST /auth/login
  Future<Response> userLogin(LoginRequest r) =>
      dio.post(ApiConstants.login, data: r.toJson());

  /// POST /auth/login/verify
  Future<Response> userLoginVerify(VerifyOtpRequest r) =>
      dio.post(ApiConstants.loginVerify, data: r.toJson());

  // ---------------- HOME ----------------

  /// GET banners
  Future<Response> getBanners() => dio.get(ApiConstants.banners);

  /// GET /categories
  Future<Response> getCategories() => dio.get(ApiConstants.categories);

  /// POST /subcategory/products?page=&per_page=   body: { "sub_category_id": 40 }
  Future<Response> getSubCategoryProducts({
    required int subCategoryId,
    int page = 1,
    int perPage = 10,
  }) =>
      dio.post(
        ApiConstants.subCategoryProducts,
        queryParameters: {'page': page, 'per_page': perPage},
        data: {'sub_category_id': subCategoryId},
      );

  /// GET /home/highlights
  Future<Response> getHomeHighlights() => dio.get(ApiConstants.homeHighlights);

  /// GET /home/best-sellers
  Future<Response> getHomeBestSellers() =>
      dio.get(ApiConstants.homeBestSellers);

  // ---------------- PRODUCT LISTS (paginated) ----------------

  /// GET /products/new-arrivals?page=&per_page=
  Future<Response> getNewArrivals({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.newArrivals,
          queryParameters: {'page': page, 'per_page': perPage});

  /// GET /products/trending?page=&per_page=
  Future<Response> getTrending({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.trending,
          queryParameters: {'page': page, 'per_page': perPage});

  /// GET /products/best-sellers?page=&per_page=
  Future<Response> getBestSellers({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.bestSellers,
          queryParameters: {'page': page, 'per_page': perPage});

  // ---------------- PRODUCT DETAILS ----------------

  /// POST /products/details   body: { "product_id": 28 }
  Future<Response> getProductDetails({required int productId}) =>
      dio.post(ApiConstants.productDetails, data: {'product_id': productId});

  // ---------------- RECENT VIEWS ----------------

  /// POST /recent-views   body: { "product_id": 26 }
  Future<Response> saveRecentView({required int productId}) =>
      dio.post(ApiConstants.recentViews, data: {'product_id': productId});

  /// GET /recent-views/top
  Future<Response> getRecentViewsTop() => dio.get(ApiConstants.recentViewsTop);

  /// GET /recent-views?page=&per_page=
  Future<Response> getRecentViews({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.recentViews,
          queryParameters: {'page': page, 'per_page': perPage});

  // ---------------- WISHLIST ----------------

  /// POST /wishlist/add   body: { "product_id": 20 }
  Future<Response> addToWishlist({required int productId}) =>
      dio.post(ApiConstants.wishlistAdd, data: {'product_id': productId});

  /// DELETE /wishlist/remove   body: { "product_id": 20 }
  Future<Response> removeFromWishlist({required int productId}) =>
      dio.delete(ApiConstants.wishlistRemove, data: {'product_id': productId});

  /// GET /wishlist?page=&per_page=
  Future<Response> getWishlist({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.wishlist,
          queryParameters: {'page': page, 'per_page': perPage});

  // ---------------- CART ----------------

  /// GET /cart
  Future<Response> getCart() => dio.get(ApiConstants.cart);

  /// POST /cart/add
  Future<Response> addToCart({
    required int productId,
    required int colorId,
    required String size,
    int quantity = 1,
  }) =>
      dio.post(ApiConstants.cartAdd, data: {
        'product_id': productId,
        'color_id': colorId,
        'size': size,
        'quantity': quantity,
      });

  /// POST /cart/update   body: { "cart_item_id": 99, "quantity": 3 }
  Future<Response> updateCart(
      {required int cartItemId, required int quantity}) =>
      dio.post(ApiConstants.cartUpdate,
          data: {'cart_item_id': cartItemId, 'quantity': quantity});

  /// DELETE /cart/remove   body: { "cart_item_id": 99 }
  Future<Response> removeFromCart({required int cartItemId}) =>
      dio.delete(ApiConstants.cartRemove, data: {'cart_item_id': cartItemId});



  /// GET /address
  Future<Response> getAddresses() => dio.get(ApiConstants.address);

  /// POST /address/add
  Future<Response> addAddress(AddressInput input) =>
      dio.post(ApiConstants.addressAdd, data: input.toJson());

  /// POST /address/update   (change to dio.put if your backend expects PUT)
  Future<Response> updateAddress(int addressId, AddressInput input) =>
      dio.put(ApiConstants.addressUpdate,
          data: {'address_id': addressId, ...input.toJson()});

  /// DELETE /address/delete   body: { "address_id": 26 }
  Future<Response> deleteAddress({required int addressId}) =>
      dio.delete(ApiConstants.addressDelete, data: {'address_id': addressId});

  // ---------------- CHECKOUT ----------------

  /// GET /order/preview
  Future<Response> getOrderPreview() => dio.get(ApiConstants.orderPreview);

  /// GET /checkout/summary
  Future<Response> getCheckoutSummary() => dio.get(ApiConstants.checkoutSummary);
  // ---------------- ENQUIRY ----------------

  /// POST /enquiry
  Future<Response> sendEnquiry(EnquiryRequest r) =>
      dio.post(ApiConstants.enquiry, data: r.toJson());


  /// GET /privacy-policy
  Future<Response> getPrivacyPolicy() => dio.get(ApiConstants.privacyPolicy);
  /// GET /refund-policy
  Future<Response> getRefundPolicy() => dio.get(ApiConstants.refundPolicy);
  /// GET /terms-and-conditions
  Future<Response> getTerms() => dio.get(ApiConstants.terms);
  /// GET /cancellation-policy
  Future<Response> getCancellationPolicy() =>
      dio.get(ApiConstants.cancellationPolicy);


  // ---------------- SEARCH ----------------

  /// POST /products/search   body: { "search": "olive" }
  Future<Response> searchProducts({required String search}) =>
      dio.post(ApiConstants.productSearch, data: {'search': search});
  // ---------------- ORDERS ----------------

  /// GET /orders?page=&per_page=
  Future<Response> getOrders({int page = 1, int perPage = 10}) =>
      dio.get(ApiConstants.orders,
          queryParameters: {'page': page, 'per_page': perPage});
  // ---------------- PRICE SUMMARY ----------------

  /// POST /product/price-summary   body: { "product_id": 21, "quantity": 2 }
  Future<Response> getPriceSummary(
      {required int productId, required int quantity}) =>
      dio.post(ApiConstants.priceSummary,
          data: {'product_id': productId, 'quantity': quantity});

  // ---------------- NOTIFICATIONS ----------------

  /// GET /notifications
  Future<Response> getNotifications() => dio.get(ApiConstants.notifications);
}