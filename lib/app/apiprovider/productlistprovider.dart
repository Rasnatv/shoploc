import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/models/productlistmodel.dart';
import '../data/models/statemodel.dart';

class ProductListProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /products/new-arrivals
  Future<StateModel<ProductListResponse>?> newArrivalsProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getNewArrivals(page: page, perPage: perPage);
      if (_ok(r)) return StateModel.success(NewArrivalsResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<ProductListResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /products/trending
  Future<StateModel<ProductListResponse>?> trendingProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getTrending(page: page, perPage: perPage);
      if (_ok(r)) return StateModel.success(TrendingResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<ProductListResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /products/best-sellers
  Future<StateModel<ProductListResponse>?> bestSellersProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getBestSellers(page: page, perPage: perPage);
      if (_ok(r)) return StateModel.success(BestSellersResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<ProductListResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}