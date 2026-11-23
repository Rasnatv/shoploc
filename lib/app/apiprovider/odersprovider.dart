import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/ordersmodel.dart';
import '../data/models/statemodel.dart';

class OrderProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /orders?page=&per_page=
  Future<StateModel<OrdersResponse>?> ordersProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r =
      await ObjectFactory().apiClient.getOrders(page: page, perPage: perPage);
      if (_ok(r)) return StateModel.success(OrdersResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<OrdersResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}