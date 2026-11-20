import '../../data/models/cancelationpolicymodel.dart';


abstract class CancellationState {
  const CancellationState();
}

class CancellationInitialState extends CancellationState {
  const CancellationInitialState();
}

class CancellationLoadingState extends CancellationState {
  const CancellationLoadingState();
}

class CancellationLoadedState extends CancellationState {
  final CancellationPolicyResponse policy;
  const CancellationLoadedState({required this.policy});
}

class CancellationErrorState extends CancellationState {
  final String errorMessage;
  const CancellationErrorState({required this.errorMessage});
}