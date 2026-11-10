
import '../../data/models/user_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final UserModel user;
  const ProfileLoadedState({required this.user});
}

class ProfileUpdateSuccessState extends ProfileState {
  final UserModel user;
  final String message;
  const ProfileUpdateSuccessState({required this.user, required this.message});
}

class ProfileErrorState extends ProfileState {
  final String errorMessage;
  const ProfileErrorState({required this.errorMessage});
}

