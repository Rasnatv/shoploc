import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/enquirymodel.dart';
import '../data/models/statemodel.dart';

class EnquiryProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// POST /enquiry
  Future<StateModel<EnquiryResponse>?> enquiryProvider(
      EnquiryRequest request) async {
    try {
      final r = await ObjectFactory().apiClient.sendEnquiry(request);
      if (_ok(r)) return StateModel.success(EnquiryResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<EnquiryResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}