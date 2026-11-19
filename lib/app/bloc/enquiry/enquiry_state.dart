abstract class EnquiryState {
  const EnquiryState();
}

class EnquiryInitialState extends EnquiryState {
  const EnquiryInitialState();
}

/// Request running (the send button shows a loader).
class EnquirySubmittingState extends EnquiryState {
  const EnquirySubmittingState();
}

class EnquirySuccessState extends EnquiryState {
  /// Text from the server: "Thank you for your enquiry! ..."
  final String message;
  const EnquirySuccessState({required this.message});
}

class EnquiryErrorState extends EnquiryState {
  final String errorMessage;
  const EnquiryErrorState({required this.errorMessage});
}