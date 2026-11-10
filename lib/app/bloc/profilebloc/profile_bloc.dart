import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LocalStorageService _storageService;

  ProfileBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    final userMap = _storageService.getCurrentUser();
    UserModel user;
    if (userMap != null) {
      user = UserModel.fromMap(userMap);
    } else {
      user = ShoplocDummyData.defaultUser;
      await _storageService.saveCurrentUser(user.toMap());
    }

    emit(ProfileLoadedState(user: user));
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    await Future.delayed(const Duration(milliseconds: 300));

    await _storageService.saveCurrentUser(event.updatedUser.toMap());
    emit(ProfileUpdateSuccessState(
      user: event.updatedUser,
      message: 'Profile updated successfully!',
    ));
    emit(ProfileLoadedState(user: event.updatedUser));
  }
}

