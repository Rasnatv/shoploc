part of 'auth_bloc.dart';



abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class OtpSentState extends AuthState {
  final String email, message;
  final bool isRegister;
  final bool isResend;
  OtpSentState({
    required this.email,
    required this.message,
    required this.isRegister,
    this.isResend = false,
  });
}

class AuthenticatedState extends AuthState {
  final UserModel user;
  AuthenticatedState(this.user);
}

class AuthErrorState extends AuthState {
  final String errorMessage;
  AuthErrorState(this.errorMessage);
}