import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/statemodel.dart';
import '../data/models/whishlistmodel.dart';

class WishlistProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /wishlist?page=&per_page=
  Future<StateModel<WishlistResponse>?> wishlistProvider(
      {int page = 1, int perPage = 10}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .getWishlist(page: page, perPage: perPage);
      if (_ok(r)) {
        return StateModel.success(WishlistResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<WishlistResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /wishlist/add   body: { "product_id": 20 }
  Future<StateModel<WishlistActionResponse>?> addToWishlistProvider(
      {required int productId}) async {
    try {
      final r =
      await ObjectFactory().apiClient.addToWishlist(productId: productId);
      if (_ok(r)) {
        return StateModel.success(WishlistActionResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<WishlistActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /wishlist/remove   body: { "product_id": 20 }
  Future<StateModel<WishlistActionResponse>?> removeFromWishlistProvider(
      {required int productId}) async {
    try {
      final r = await ObjectFactory()
          .apiClient
          .removeFromWishlist(productId: productId);
      if (_ok(r)) {
        return StateModel.success(WishlistActionResponse.fromJson(r.data));
      }
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<WishlistActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}