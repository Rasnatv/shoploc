import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

import '../../data/models/models/loginrequestmodel.dart';
import '../../data/models/models/otprequestmodel.dart';
import '../../data/models/models/registerrequestmodel.dart';
import '../constants/api constants.dart';

class ApiClient {
  late Dio dio;

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
        onError: (error, handler) => handler.next(error),
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

  //get banners

  Future<Response> getBanners() => dio.get(ApiConstants.banners);

  /// GET /categories
  Future<Response> getCategories() => dio.get(ApiConstants.categories);

  /// GET /home/highlights
  Future<Response> getHomeHighlights() => dio.get(ApiConstants.homeHighlights);

  /// GET /home/best-sellers
  Future<Response> getHomeBestSellers() => dio.get(ApiConstants.homeBestSellers);

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
}