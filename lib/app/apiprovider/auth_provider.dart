import 'package:dio/dio.dart';
import '../core/error/api_error handler.dart';
import '../core/utils/object_factory.dart';
import '../data/models/models/loginrequestmodel.dart';
import '../data/models/models/loginresponsemodel.dart';
import '../data/models/models/otp_responsivemodel.dart';
import '../data/models/models/otprequestmodel.dart';
import '../data/models/models/registerrequestmodel.dart';
import '../data/models/models/registerresponsemodel.dart';
import '../data/models/statemodel.dart';

class AuthProvider {
  bool _ok(Response r) => r.statusCode == 200 || r.statusCode == 201;

  /// REGISTER (sends OTP)
  Future<StateModel<RegistrationResponse>?> userRegProvider(
      RegisterRequest registerRequest) async {
    try {
      final response = await ObjectFactory().apiClient.userReg(registerRequest);
      if (_ok(response)) {
        return StateModel.success(RegistrationResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<RegistrationResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// REGISTER VERIFY OTP
  Future<StateModel<VerifyOtpResponse>?> userRegVerifyProvider(
      VerifyOtpRequest request) async {
    try {
      final response =
      await ObjectFactory().apiClient.userRegVerify(request);
      if (_ok(response)) {
        return StateModel.success(VerifyOtpResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<VerifyOtpResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// LOGIN (sends OTP)
  Future<StateModel<LoginResponse>?> userLoginProvider(
      LoginRequest loginRequest) async {
    try {
      final response = await ObjectFactory().apiClient.userLogin(loginRequest);
      if (_ok(response)) {
        return StateModel.success(LoginResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<LoginResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }

  /// LOGIN VERIFY OTP
  Future<StateModel<VerifyOtpResponse>?> userLoginVerifyProvider(
      VerifyOtpRequest request) async {
    try {
      final response =
      await ObjectFactory().apiClient.userLoginVerify(request);
      if (_ok(response)) {
        return StateModel.success(VerifyOtpResponse.fromJson(response.data));
      } else {
        return StateModel.error("Unexpected response: ${response.statusCode}");
      }
    } on DioException catch (e) {
      return DioErrorHandler.handle<VerifyOtpResponse>(e);
    } catch (_) {
      return StateModel.error("Something went wrong. Please try again.");
    }
  }
}