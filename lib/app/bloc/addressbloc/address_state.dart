

import '../../data/models/address_model.dart';

abstract class AddressState {
  const AddressState();
}

class AddressInitialState extends AddressState {
  const AddressInitialState();
}

class AddressLoadingState extends AddressState {
  const AddressLoadingState();
}

class AddressLoadedState extends AddressState {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;

  const AddressLoadedState({
    required this.addresses,
    this.selectedAddress,
  });

  AddressModel? get defaultAddress {
    final matches = addresses.where((a) => a.isDefault).toList();
    if (matches.isNotEmpty) return matches.first;
    if (addresses.isNotEmpty) return addresses.first;
    return null;
  }
}

class AddressErrorState extends AddressState {
  final String errorMessage;
  const AddressErrorState({required this.errorMessage});
}

class AddressSuccessMessageState extends AddressState {
  final String message;
  const AddressSuccessMessageState({required this.message});
}

