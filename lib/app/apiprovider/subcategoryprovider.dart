import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/statemodel.dart';
import '../data/models/subcategorymodel.dart';

class SubCategoryProductProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /subcategory/products?page=&per_page=   body: { "sub_category_id": 40 }
  Future<StateModel<SubCategoryProductsResponse>?> subCategoryProductsProvider({
    required int subCategoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final r = await ObjectFactory().apiClient.getSubCategoryProducts(
        subCategoryId: subCategoryId,
        page: page,
        perPage: perPage,
      );
      if (_ok(r)) {
        return StateModel.success(SubCategoryProductsResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<SubCategoryProductsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}