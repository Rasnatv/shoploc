import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/recentviewmodel.dart';
import '../data/models/statemodel.dart';

class RecentViewProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /recent-views   body: { "product_id": 26 }
  Future<StateModel<SaveRecentViewResponse>?> saveRecentViewProvider(
      {required int productId}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .saveRecentView(productId: productId);
      if (_ok(r)) {
        return StateModel.success(SaveRecentViewResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<SaveRecentViewResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /recent-views/top   (latest few, for the Home section)
  Future<StateModel<RecentViewsResponse>?> topRecentViewsProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getRecentViewsTop();
      if (_ok(r)) {
        return StateModel.success(RecentViewsResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<RecentViewsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /recent-views?page=&per_page=   (full paginated list)
  Future<StateModel<RecentViewsResponse>?> recentViewsProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getRecentViews(page: page, perPage: perPage);
      if (_ok(r)) {
        return StateModel.success(RecentViewsResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<RecentViewsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}