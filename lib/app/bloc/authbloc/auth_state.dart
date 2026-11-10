

import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  final String? loadingMessage;
  const AuthLoadingState({this.loadingMessage});
}

class AuthenticatedState extends AuthState {
  final UserModel user;
  const AuthenticatedState({required this.user});
}

class UnauthenticatedState extends AuthState {
  final String? message;
  const UnauthenticatedState({this.message});
}

class AuthErrorState extends AuthState {
  final String errorMessage;
  const AuthErrorState({required this.errorMessage});
}

class OtpSentState extends AuthState {
  final String destination;
  final String verificationType;

  const OtpSentState({
    required this.destination,
    required this.verificationType,
  });
}

class PasswordResetSentState extends AuthState {
  final String email;
  const PasswordResetSentState({required this.email});
}

