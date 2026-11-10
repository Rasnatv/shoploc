import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/address_model.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final LocalStorageService _storageService;

  AddressBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const AddressInitialState()) {
    on<LoadAddressesEvent>(_onLoadAddresses);
    on<AddAddressEvent>(_onAddAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
    on<SetDefaultAddressEvent>(_onSetDefaultAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddressesEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoadingState());
    final raw = _storageService.getAddresses();
    List<AddressModel> addresses = [];

    if (raw.isNotEmpty) {
      addresses = raw.map((m) => AddressModel.fromMap(m)).toList();
    } else {
      // Initialize with default demo addresses
      addresses = List.from(ShoplocDummyData.defaultAddresses);
      await _storageService.saveAddresses(addresses.map((a) => a.toMap()).toList());
    }

    emit(AddressLoadedState(
      addresses: addresses,
      selectedAddress: addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      ),
    ));
  }

  Future<void> _onAddAddress(
    AddAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    List<AddressModel> currentList = [];
    if (state is AddressLoadedState) {
      currentList = List.from((state as AddressLoadedState).addresses);
    }

    var newAddress = event.address;
    if (currentList.isEmpty || newAddress.isDefault) {
      currentList = currentList.map((a) => a.copyWith(isDefault: false)).toList();
      newAddress = newAddress.copyWith(isDefault: true);
    }

    currentList.insert(0, newAddress);
    await _storageService.saveAddresses(currentList.map((a) => a.toMap()).toList());

    emit(AddressLoadedState(
      addresses: currentList,
      selectedAddress: newAddress,
    ));
  }

  Future<void> _onUpdateAddress(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    if (state is! AddressLoadedState) return;
    var currentList = List<AddressModel>.from((state as AddressLoadedState).addresses);

    final index = currentList.indexWhere((a) => a.id == event.address.id);
    if (index >= 0) {
      if (event.address.isDefault) {
        currentList = currentList.map((a) => a.copyWith(isDefault: false)).toList();
      }
      currentList[index] = event.address;
      await _storageService.saveAddresses(currentList.map((a) => a.toMap()).toList());

      emit(AddressLoadedState(
        addresses: currentList,
        selectedAddress: event.address,
      ));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    if (state is! AddressLoadedState) return;
    var currentList = List<AddressModel>.from((state as AddressLoadedState).addresses);

    final removed = currentList.where((a) => a.id == event.addressId).toList();
    currentList.removeWhere((a) => a.id == event.addressId);

    // If removed was default, make first remaining default
    if (removed.isNotEmpty && removed.first.isDefault && currentList.isNotEmpty) {
      currentList[0] = currentList[0].copyWith(isDefault: true);
    }

    await _storageService.saveAddresses(currentList.map((a) => a.toMap()).toList());

    emit(AddressLoadedState(
      addresses: currentList,
      selectedAddress: currentList.isNotEmpty ? currentList.first : null,
    ));
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    if (state is! AddressLoadedState) return;
    var currentList = List<AddressModel>.from((state as AddressLoadedState).addresses);

    currentList = currentList.map((a) {
      return a.copyWith(isDefault: a.id == event.addressId);
    }).toList();

    await _storageService.saveAddresses(currentList.map((a) => a.toMap()).toList());

    final selected = currentList.firstWhere(
      (a) => a.id == event.addressId,
      orElse: () => currentList.first,
    );

    emit(AddressLoadedState(
      addresses: currentList,
      selectedAddress: selected,
    ));
  }
}

