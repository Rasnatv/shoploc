import '../../data/models/termsmodel.dart';

abstract class TermsState {
  const TermsState();
}

class TermsInitialState extends TermsState {
  const TermsInitialState();
}

class TermsLoadingState extends TermsState {
  const TermsLoadingState();
}

class TermsLoadedState extends TermsState {
  final TermsResponse terms;
  const TermsLoadedState({required this.terms});
}

class TermsErrorState extends TermsState {
  final String errorMessage;
  const TermsErrorState({required this.errorMessage});
}