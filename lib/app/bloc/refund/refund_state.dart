import '../../data/models/refundpolicymodel.dart';

abstract class RefundState {
  const RefundState();
}

class RefundInitialState extends RefundState {
  const RefundInitialState();
}

class RefundLoadingState extends RefundState {
  const RefundLoadingState();
}

class RefundLoadedState extends RefundState {
  final RefundPolicyResponse policy;
  const RefundLoadedState({required this.policy});
}

class RefundErrorState extends RefundState {
  final String errorMessage;
  const RefundErrorState({required this.errorMessage});
}