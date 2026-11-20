import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/privacypolicymodel.dart';
import '../data/models/statemodel.dart';

class PrivacyPolicyProvider {
  /// GET /privacy-policy
  Future<StateModel<PrivacyPolicyResponse>?> privacyPolicyProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getPrivacyPolicy();
      if (r.statusCode == 200 || r.statusCode == 201) {
        return StateModel.success(PrivacyPolicyResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<PrivacyPolicyResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}