
import '../../data/models/user_model.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final UserModel updatedUser;
  const UpdateProfileEvent({required this.updatedUser});
}

