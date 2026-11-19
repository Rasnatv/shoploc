import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/cartmodel.dart';
import '../data/models/statemodel.dart';

class CartProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /cart
  Future<StateModel<CartResponse>?> cartProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getCart();
      if (_ok(r)) return StateModel.success(CartResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CartResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /cart/add
  Future<StateModel<CartActionResponse>?> addToCartProvider({
    required int productId,
    required int colorId,
    required String size,
    int quantity = 1,
  }) async {
    try {
      final r = await ObjectFactory().apiClient.addToCart(
        productId: productId,
        colorId: colorId,
        size: size,
        quantity: quantity,
      );
      if (_ok(r)) return StateModel.success(CartActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CartActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /cart/update
  Future<StateModel<CartActionResponse>?> updateCartProvider(
      {required int cartItemId, required int quantity}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .updateCart(cartItemId: cartItemId, quantity: quantity);
      if (_ok(r)) return StateModel.success(CartActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CartActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /cart/remove
  Future<StateModel<CartActionResponse>?> removeFromCartProvider(
      {required int cartItemId}) async {
    try {
      final r =
      await ObjectFactory().apiClient.removeFromCart(cartItemId: cartItemId);
      if (_ok(r)) return StateModel.success(CartActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<CartActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}