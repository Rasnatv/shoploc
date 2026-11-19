import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/enquiryprovider.dart';
import '../../data/models/enquirymodel.dart';
import '../../data/models/statemodel.dart';
import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final EnquiryProvider _provider;

  EnquiryBloc({EnquiryProvider? provider})
      : _provider = provider ?? EnquiryProvider(),
        super(const EnquiryInitialState()) {
    on<SubmitEnquiryEvent>(_onSubmit);
    on<ResetEnquiryEvent>((e, emit) => emit(const EnquiryInitialState()));
  }

  Future<void> _onSubmit(
      SubmitEnquiryEvent e, Emitter<EnquiryState> emit) async {
    if (state is EnquirySubmittingState) return; // ignore double taps
    emit(const EnquirySubmittingState());

    try {
      final res = await _provider.enquiryProvider(e.request);
      final data = res.payload<EnquiryResponse>();

      if (data == null) {
        emit(EnquiryErrorState(
            errorMessage:
            res.errorText() ?? 'Could not send your message. Please try again.'));
        return;
      }
      emit(EnquirySuccessState(
        message: data.message.isNotEmpty
            ? data.message
            : 'Thank you for your enquiry! We will get back to you soon.',
      ));
    } catch (_) {
      emit(const EnquiryErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}