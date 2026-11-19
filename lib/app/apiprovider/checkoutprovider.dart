import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/checkoutmodel.dart';
import '../data/models/statemodel.dart';

class CheckoutProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /order/preview
  Future<StateModel<OrderPreviewResponse>?> orderPreviewProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getOrderPreview();
      if (_ok(r)) return StateModel.success(OrderPreviewResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<OrderPreviewResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// GET /checkout/summary
  Future<StateModel<CheckoutSummaryResponse>?> checkoutSummaryProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getCheckoutSummary();
      if (_ok(r)) return StateModel.success(CheckoutSummaryResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CheckoutSummaryResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}
