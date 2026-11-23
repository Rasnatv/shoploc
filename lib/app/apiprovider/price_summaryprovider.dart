import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/buynowproductsummarymodel.dart';
import '../data/models/statemodel.dart';

class PriceSummaryProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /product/price-summary   body: { "product_id": 21, "quantity": 2 }
  Future<StateModel<PriceSummaryResponse>?> priceSummaryProvider(
      {required int productId, required int quantity}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getPriceSummary(productId: productId, quantity: quantity);
      if (_ok(r)) {
        return StateModel.success(PriceSummaryResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<PriceSummaryResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}