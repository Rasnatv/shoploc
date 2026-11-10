abstract class AuthEvent {
  const AuthEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;

  const LoginEvent({
    required this.emailOrPhone,
    this.password = '',
  });
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    this.phone = '',
    this.password = '',
  });
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;
  final String contextType;
  final String? userName;
  final String? email;

  const VerifyOtpEvent({
    required this.otp,
    this.contextType = 'login',
    this.userName,
    this.email,
  });
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
