import '../../data/models/addressmodel.dart';


abstract class AddressEvent {
  const AddressEvent();
}

/// First load - shows a loader.
class LoadAddressesEvent extends AddressEvent {
  const LoadAddressesEvent();
}

/// Reload silently (pull-to-refresh) - keeps the list on screen.
class RefreshAddressesEvent extends AddressEvent {
  const RefreshAddressesEvent();
}

/// POST /address/add
class AddAddressEvent extends AddressEvent {
  final AddressInput input;
  const AddAddressEvent({required this.input});
}

/// POST /address/update
class UpdateAddressEvent extends AddressEvent {
  final int addressId;
  final AddressInput input;
  const UpdateAddressEvent({required this.addressId, required this.input});
}

/// DELETE /address/delete
class DeleteAddressEvent extends AddressEvent {
  final int addressId;
  const DeleteAddressEvent({required this.addressId});
}

/// Local only: choose the delivery address used at checkout.
class SelectAddressEvent extends AddressEvent {
  final int addressId;
  const SelectAddressEvent({required this.addressId});
}

/// Local reset only (call on logout). Does NOT call the API.
class ResetAddressEvent extends AddressEvent {
  const ResetAddressEvent();
}
