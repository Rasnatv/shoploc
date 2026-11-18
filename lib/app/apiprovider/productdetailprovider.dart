import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/models/productdetailmodel.dart';
import '../data/models/statemodel.dart';

class ProductDetailsProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /products/details   { "product_id": id }
  Future<StateModel<ProductDetailsResponse>?> productDetailsProvider(
      {required int productId}) async {
    try {
      final r =
      await ObjectFactory().apiClient.getProductDetails(productId: productId);
      if (_ok(r)) {
        final res = ProductDetailsResponse.fromJson(r.data);
        if (res.success && res.product != null) return StateModel.success(res);
        return StateModel.error(
            res.message.isNotEmpty ? res.message : 'Product not found.');
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<ProductDetailsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}