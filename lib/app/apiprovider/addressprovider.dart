import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/addressmodel.dart';
import '../data/models/statemodel.dart';

class AddressProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// GET /address
  Future<StateModel<AddressListResponse>?> addressListProvider() async {
    try {
      final r = await ObjectFactory().apiClient.getAddresses();
      if (_ok(r)) return StateModel.success(AddressListResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<AddressListResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /address/add
  Future<StateModel<AddressActionResponse>?> addAddressProvider(
      AddressInput input) async {
    try {
      final r = await ObjectFactory().apiClient.addAddress(input);
      if (_ok(r)) return StateModel.success(AddressActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<AddressActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// POST /address/update
  Future<StateModel<AddressActionResponse>?> updateAddressProvider(
      int addressId, AddressInput input) async {
    try {
      final r = await ObjectFactory().apiClient.updateAddress(addressId, input);
      if (_ok(r)) return StateModel.success(AddressActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<AddressActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// DELETE /address/delete
  Future<StateModel<AddressActionResponse>?> deleteAddressProvider(
      {required int addressId}) async {
    try {
      final r = await ObjectFactory().apiClient.deleteAddress(addressId: addressId);
      if (_ok(r)) return StateModel.success(AddressActionResponse.fromJson(r.data));
      return StateModel.error("Unexpected response: ${r.statusCode}");
    } on DioException catch (e) {
      return DioErrorHandler.handle<AddressActionResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}
