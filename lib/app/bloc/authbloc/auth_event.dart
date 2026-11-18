part of 'auth_bloc.dart';

abstract class AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String name, email, referralCode;
  RegisterRequested({
    required this.name,
    required this.email,
    this.referralCode = '',
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  LoginRequested({required this.email});
}

class VerifyOtpRequested extends AuthEvent {
  final String email, otp;
  final bool isRegister;
  VerifyOtpRequested({
    required this.email,
    required this.otp,
    required this.isRegister,
  });
}

class ResendOtpRequested extends AuthEvent {}