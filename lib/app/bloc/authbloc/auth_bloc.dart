import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

import '../../apiprovider/auth_provider.dart';
import '../../data/models/models/loginrequestmodel.dart';
import '../../data/models/models/otp_responsivemodel.dart';
import '../../data/models/models/otprequestmodel.dart';
import '../../data/models/models/registerrequestmodel.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _provider = AuthProvider();
  final _prefs = ObjectFactory().prefs;

  RegisterRequest? _lastReg;
  LoginRequest? _lastLogin;
  bool _isRegisterFlow = true;

  AuthBloc() : super(AuthInitialState()) {
    on<RegisterRequested>(_onRegister);
    on<LoginRequested>(_onLogin);
    on<VerifyOtpRequested>(_onVerify);
    on<ResendOtpRequested>(_onResend);
  }

  String _v(String? s) => s ?? '';

  Future<void> _onRegister(
      RegisterRequested e, Emitter<AuthState> emit) async {
    _isRegisterFlow = true;
    _lastReg = RegisterRequest(
      name: e.name,
      email: e.email,
      referralCode: e.referralCode,
      fcmToken: _v(_prefs.getFcmToken()),
      appVersion: _v(_prefs.getAppVersion()),
      model: _v(_prefs.getModel()),
      modelName: _v(_prefs.getModelName()),
      modelVersion: _v(_prefs.getModelVersion()),
    );
    await _sendOtp(emit, isResend: false);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    _isRegisterFlow = false;
    _lastLogin = LoginRequest(
      email: e.email,
      fcmToken: _v(_prefs.getFcmToken()),
      appVersion: _v(_prefs.getAppVersion()),
      model: _v(_prefs.getModel()),
      modelName: _v(_prefs.getModelName()),
      modelVersion: _v(_prefs.getModelVersion()),
    );
    await _sendOtp(emit, isResend: false);
  }

  Future<void> _onResend(
      ResendOtpRequested e, Emitter<AuthState> emit) async {
    if (_isRegisterFlow ? _lastReg == null : _lastLogin == null) return;
    await _sendOtp(emit, isResend: true);
  }

  Future<void> _sendOtp(Emitter<AuthState> emit,
      {required bool isResend}) async {
    emit(AuthLoadingState());

    if (_isRegisterFlow) {
      final result = await _provider.userRegProvider(_lastReg!);
      if (result != null && result.isSuccess) {
        emit(OtpSentState(
          email: result.data!.email.isNotEmpty
              ? result.data!.email
              : _lastReg!.email,
          message: result.data!.message,
          isRegister: true,
          isResend: isResend,
        ));
      } else {
        emit(AuthErrorState(result?.error ?? 'Something went wrong'));
      }
    } else {
      final result = await _provider.userLoginProvider(_lastLogin!);
      if (result != null && result.isSuccess) {
        emit(OtpSentState(
          email: result.data!.email.isNotEmpty
              ? result.data!.email
              : _lastLogin!.email,
          message: result.data!.message,
          isRegister: false,
          isResend: isResend,
        ));
      } else {
        emit(AuthErrorState(result?.error ?? 'Something went wrong'));
      }
    }
  }

  Future<void> _onVerify(VerifyOtpRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final req = VerifyOtpRequest(email: e.email, otp: e.otp);

    final result = e.isRegister
        ? await _provider.userRegVerifyProvider(req)
        : await _provider.userLoginVerifyProvider(req);

    if (result != null && result.isSuccess) {
      final d = result.data!;
      _prefs.setAuthToken(accesstoken: d.token);
      _prefs.setIsLoggedIn(true);
      _prefs.setUserId(user_id: d.user.id.toString());
      _prefs.setUserName(d.user.name);
      _prefs.setUserEmail(d.user.email);
      _prefs.clearReferralCode(); // used, so clear it
      emit(AuthenticatedState(d.user));
    } else {
      emit(AuthErrorState(result?.error ?? 'Something went wrong'));
    }
  }
}