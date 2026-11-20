import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/statemodel.dart';
import '../data/models/termsmodel.dart';

class TermsProvider {
  /// GET /terms-and-conditions
  Future<StateModel<TermsResponse>?> termsProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getTerms();
      if (r.statusCode == 200 || r.statusCode == 201) {
        return StateModel.success(TermsResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<TermsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}