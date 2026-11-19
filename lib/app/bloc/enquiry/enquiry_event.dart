import '../../data/models/enquirymodel.dart';


abstract class EnquiryEvent {
  const EnquiryEvent();
}

/// POST /enquiry
class SubmitEnquiryEvent extends EnquiryEvent {
  final EnquiryRequest request;
  const SubmitEnquiryEvent({required this.request});
}

/// Back to the empty state.
class ResetEnquiryEvent extends EnquiryEvent {
  const ResetEnquiryEvent();
}