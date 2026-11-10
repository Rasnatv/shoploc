import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalStorageService _storageService;

  AuthBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    await Future.delayed(const Duration(milliseconds: 300));

    final isLoggedIn = _storageService.isLoggedIn();
    if (isLoggedIn) {
      final userMap = _storageService.getCurrentUser();
      if (userMap != null) {
        emit(AuthenticatedState(user: UserModel.fromMap(userMap)));
      } else {
        // Fallback to default dummy user
        final user = ShoplocDummyData.defaultUser;
        await _storageService.saveCurrentUser(user.toMap());
        emit(AuthenticatedState(user: user));
      }
    } else {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState(loadingMessage: 'Signing in to Shoploc...'));
    await Future.delayed(const Duration(milliseconds: 400));

    // Email-based instant login (no OTP, no password gate required)
    if (event.emailOrPhone.trim().isEmpty) {
      emit(const AuthErrorState(errorMessage: 'Please enter your email address.'));
      return;
    }

    final trimmedEmail = event.emailOrPhone.trim();
    final nameFromEmail = trimmedEmail.contains('@')
        ? trimmedEmail.split('@').first
        : 'Shoploc Customer';

    // Capitalize first letter of name
    final displayName = nameFromEmail.isNotEmpty
        ? nameFromEmail[0].toUpperCase() + nameFromEmail.substring(1)
        : 'Customer';

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: displayName,
      email: trimmedEmail.contains('@') ? trimmedEmail : '$trimmedEmail@shoploc.in',
      phone: event.emailOrPhone.contains('@') ? '+91 98765 43210' : event.emailOrPhone,
      profileImageUrl: ShoplocDummyData.defaultUser.profileImageUrl,
    );

    await _storageService.setLoggedIn(true);
    await _storageService.saveCurrentUser(user.toMap());

    emit(AuthenticatedState(user: user));
  }

  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState(loadingMessage: 'Creating your Shoploc account...'));
    await Future.delayed(const Duration(milliseconds: 400));

    if (event.name.trim().isEmpty || event.email.trim().isEmpty) {
      emit(const AuthErrorState(errorMessage: 'Please enter both your full name and email address.'));
      return;
    }

    if (!event.email.contains('@')) {
      emit(const AuthErrorState(errorMessage: 'Please enter a valid email address.'));
      return;
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: event.name.trim(),
      email: event.email.trim(),
      phone: event.phone.trim().isNotEmpty ? event.phone.trim() : '+91 98765 43210',
      profileImageUrl: ShoplocDummyData.defaultUser.profileImageUrl,
    );

    await _storageService.setLoggedIn(true);
    await _storageService.saveCurrentUser(user.toMap());

    emit(AuthenticatedState(user: user));
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState(loadingMessage: 'Sending recovery OTP...'));
    await Future.delayed(const Duration(milliseconds: 500));

    if (event.email.trim().isEmpty || !event.email.contains('@')) {
      emit(const AuthErrorState(errorMessage: 'Please enter a valid email address.'));
      return;
    }

    emit(PasswordResetSentState(email: event.email.trim()));
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState(loadingMessage: 'Verifying code...'));
    await Future.delayed(const Duration(milliseconds: 350));

    if (event.otp.length != 4 && event.otp.length != 6) {
      emit(const AuthErrorState(errorMessage: 'Please enter a valid 4-digit OTP.'));
      return;
    }

    // Preserve the user's registered name and email
    final name = (event.userName != null && event.userName!.trim().isNotEmpty)
        ? event.userName!.trim()
        : 'Shoploc Customer';
    final email = (event.email != null && event.email!.trim().isNotEmpty)
        ? event.email!.trim()
        : 'customer@shoploc.in';

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: '+91 98765 43210',
      profileImageUrl: ShoplocDummyData.defaultUser.profileImageUrl,
    );

    await _storageService.setLoggedIn(true);
    await _storageService.saveCurrentUser(user.toMap());

    emit(AuthenticatedState(user: user));
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoadingState());
    await _storageService.clearUserSession();
    emit(const UnauthenticatedState(message: 'Logged out successfully.'));
  }
}

