import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/searchmodel.dart';
import '../data/models/statemodel.dart';

class SearchProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /products/search   body: { "search": "olive" }
  Future<StateModel<SearchResponse>?> searchProvider(String query) async {
    try {
      final r = await ObjectFactory().apiClient.searchProducts(search: query);
      if (_ok(r)) return StateModel.success(SearchResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<SearchResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}