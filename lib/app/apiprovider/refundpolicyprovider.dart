import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/refundpolicymodel.dart';
import '../data/models/statemodel.dart';

class RefundPolicyProvider {
  /// GET /refund-policy
  Future<StateModel<RefundPolicyResponse>?> refundPolicyProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getRefundPolicy();
      if (r.statusCode == 200 || r.statusCode == 201) {
        return StateModel.success(RefundPolicyResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<RefundPolicyResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}
