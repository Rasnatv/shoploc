import '../../data/models/addressmodel.dart';


abstract class AddressState {
  const AddressState();
}

class AddressInitialState extends AddressState {
  const AddressInitialState();
}

class AddressLoadingState extends AddressState {
  const AddressLoadingState();
}

enum AddressAction { add, update, delete }

/// One-shot message for a snackbar / closing the form.
class AddressMessage {
  final int seq; // changes on every message so listeners always fire
  final String text;
  final bool isError;
  final AddressAction action;
  const AddressMessage({
    required this.seq,
    required this.text,
    required this.action,
    this.isError = false,
  });
}

class AddressLoadedState extends AddressState {
  final List<AddressModel> addresses;

  /// Address used for delivery at checkout.
  final int? selectedId;

  /// Add / update request running (the form button shows a loader).
  final bool isSaving;

  /// Addresses with a delete request running.
  final Set<int> busyIds;
  final AddressMessage? message;

  const AddressLoadedState({
    required this.addresses,
    this.selectedId,
    this.isSaving = false,
    this.busyIds = const {},
    this.message,
  });

  bool get isEmpty => addresses.isEmpty;

  AddressModel? get selectedAddress {
    for (final a in addresses) {
      if (a.id == selectedId) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  AddressLoadedState copyWith({
    List<AddressModel>? addresses,
    int? selectedId,
    bool? isSaving,
    Set<int>? busyIds,
    AddressMessage? message,
  }) =>
      AddressLoadedState(
        addresses: addresses ?? this.addresses,
        selectedId: selectedId ?? this.selectedId,
        isSaving: isSaving ?? this.isSaving,
        busyIds: busyIds ?? this.busyIds,
        message: message, // null clears the old message
      );
}

class AddressErrorState extends AddressState {
  final String errorMessage;
  const AddressErrorState({required this.errorMessage});
}
