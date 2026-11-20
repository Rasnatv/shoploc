import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/cancelationpolicymodel.dart';
import '../data/models/statemodel.dart';

class CancellationPolicyProvider {
  /// GET /cancellation-policy
  Future<StateModel<CancellationPolicyResponse>?>
  cancellationPolicyProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getCancellationPolicy();
      if (r.statusCode == 200 || r.statusCode == 201) {
        return StateModel.success(CancellationPolicyResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CancellationPolicyResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}