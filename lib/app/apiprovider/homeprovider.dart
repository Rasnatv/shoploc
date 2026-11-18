
import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/models/apibannermodel.dart';
import '../data/models/models/homemodel.dart';
import '../data/models/models/productlistmodel.dart';
import '../data/models/statemodel.dart';

class HomeProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  // ===================== HOME =====================

  /// GET /banners
  Future<StateModel<BannersResponse>?> bannersProvider() async {
    try {
      final response = await ObjectFactory().apiClient.getBanners();
      if (_ok(response)) {
        return StateModel.success(BannersResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<BannersResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /categories
  Future<StateModel<CategoriesResponse>?> categoriesProvider() async {
    try {
      final response = await ObjectFactory().apiClient.getCategories();
      if (_ok(response)) {
        return StateModel.success(CategoriesResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<CategoriesResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /home/highlights
  Future<StateModel<HomeHighlightsResponse>?> homeHighlightsProvider() async {
    try {
      final response = await ObjectFactory().apiClient.getHomeHighlights();
      if (_ok(response)) {
        return StateModel.success(HomeHighlightsResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<HomeHighlightsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /home/best-sellers
  Future<StateModel<BestSellersResponse>?> homeBestSellersProvider() async {
    try {
      final response = await ObjectFactory().apiClient.getHomeBestSellers();
      if (_ok(response)) {
        return StateModel.success(BestSellersResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<BestSellersResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}