
import '../../data/models/address_model.dart';

abstract class AddressEvent {
  const AddressEvent();
}

class LoadAddressesEvent extends AddressEvent {
  const LoadAddressesEvent();
}

class AddAddressEvent extends AddressEvent {
  final AddressModel address;
  const AddAddressEvent({required this.address});
}

class UpdateAddressEvent extends AddressEvent {
  final AddressModel address;
  const UpdateAddressEvent({required this.address});
}

class DeleteAddressEvent extends AddressEvent {
  final String addressId;
  const DeleteAddressEvent({required this.addressId});
}

class SetDefaultAddressEvent extends AddressEvent {
  final String addressId;
  const SetDefaultAddressEvent({required this.addressId});
}

