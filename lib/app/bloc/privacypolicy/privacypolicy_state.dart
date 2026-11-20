
import '../../data/models/privacypolicymodel.dart';

abstract class PrivacyState {
  const PrivacyState();
}

class PrivacyInitialState extends PrivacyState {
  const PrivacyInitialState();
}

class PrivacyLoadingState extends PrivacyState {
  const PrivacyLoadingState();
}

class PrivacyLoadedState extends PrivacyState {
  final PrivacyPolicyResponse policy;
  const PrivacyLoadedState({required this.policy});
}

class PrivacyErrorState extends PrivacyState {
  final String errorMessage;
  const PrivacyErrorState({required this.errorMessage});
}