import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/notificationmodel.dart';
import '../data/models/statemodel.dart';

class NotificationProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /notifications
  Future<StateModel<NotificationsResponse>?> notificationsProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getNotifications();
      if (_ok(r)) {
        return StateModel.success(NotificationsResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<NotificationsResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}