import 'package:flutter_bloc/flutter_bloc.dart';
import '../../apiprovider/addressprovider.dart';
import '../../core/utils/object_factory.dart';

import '../../data/models/addressmodel.dart';
import '../../data/models/statemodel.dart';
import '../checkout/checkout_bloc.dart';
import 'address_event.dart';
import 'address_state.dart';


class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressProvider _provider;
  int _msgSeq = 0;

  AddressBloc({AddressProvider? provider})
      : _provider = provider ?? AddressProvider(),
        super(const AddressInitialState()) {
    on<LoadAddressesEvent>(_onLoad);
    on<RefreshAddressesEvent>(_onRefresh);
    on<AddAddressEvent>(_onAdd);
    on<UpdateAddressEvent>(_onUpdate);
    on<DeleteAddressEvent>(_onDelete);
    on<SelectAddressEvent>(_onSelect);
    on<ResetAddressEvent>((e, emit) => emit(const AddressInitialState()));
  }

  bool get _loggedIn => ObjectFactory().prefs.isLoggedIn() ?? false;

  static const AddressLoadedState _empty = AddressLoadedState(addresses: []);

  AddressLoadedState get _loaded =>
      state is AddressLoadedState ? state as AddressLoadedState : _empty;

  AddressMessage _msg(String text, AddressAction action, {bool isError = false}) =>
      AddressMessage(seq: ++_msgSeq, text: text, action: action, isError: isError);

  /// A 401 clears the session (DioErrorHandler). When a request ends and the
  /// user is no longer logged in, drop the list and show the login prompt.
  bool _sessionEnded(Emitter<AddressState> emit) {
    if (_loggedIn) return false;
    emit(const AddressErrorState(
        errorMessage: 'Session expired. Please login again.'));
    return true;
  }

  /// Keeps the previous choice when it still exists, else the first address.
  int? _pick(List<AddressModel> list, int? preferred) {
    if (list.isEmpty) return null;
    if (preferred != null && list.any((a) => a.id == preferred)) return preferred;
    return list.first.id;
  }

  // ---------------- LOAD ----------------
  Future<void> _onLoad(LoadAddressesEvent e, Emitter<AddressState> emit) async {
    if (!_loggedIn) {
      emit(const AddressErrorState(
          errorMessage: 'Please login to manage your addresses.'));
      return;
    }
    emit(const AddressLoadingState());
    await _fetch(emit, showErrorState: true);
  }

  Future<void> _onRefresh(
      RefreshAddressesEvent e, Emitter<AddressState> emit) async {
    if (!_loggedIn) {
      emit(const AddressErrorState(
          errorMessage: 'Please login to manage your addresses.'));
      return;
    }
    await _fetch(emit, showErrorState: state is! AddressLoadedState);
  }

  /// Returns true when the list was loaded. Always emits something.
  Future<bool> _fetch(Emitter<AddressState> emit,
      {required bool showErrorState, int? select}) async {
    try {
      final res = await _provider.addressListProvider();
      final data = res.payload<AddressListResponse>();
      if (data == null) {
        if (_sessionEnded(emit)) return false;
        _fail(emit, res.errorText() ?? 'Failed to load addresses.', showErrorState);
        return false;
      }
      final prev = state is AddressLoadedState
          ? (state as AddressLoadedState).selectedId
          : null;
      emit(AddressLoadedState(
        addresses: data.addresses,
        selectedId: _pick(data.addresses, select ?? prev),
      ));
      return true;
    } catch (_) {
      if (_sessionEnded(emit)) return false;
      _fail(emit, 'Something went wrong. Please try again.', showErrorState);
      return false;
    }
  }

  void _fail(Emitter<AddressState> emit, String text, bool showErrorState) {
    if (showErrorState || state is! AddressLoadedState) {
      emit(AddressErrorState(errorMessage: text));
    } else {
      emit(_loaded.copyWith(
          isSaving: false, message: _msg(text, AddressAction.update, isError: true)));
    }
  }

  // ---------------- ADD ----------------
  Future<void> _onAdd(AddAddressEvent e, Emitter<AddressState> emit) async {
    if (!_loggedIn) {
      emit(_loaded.copyWith(
          message: _msg('Please login to add an address.', AddressAction.add,
              isError: true)));
      return;
    }
    if (_loaded.isSaving) return;
    final wasLoaded = state is AddressLoadedState;

    emit(_loaded.copyWith(isSaving: true));

    final res = await _provider.addAddressProvider(e.input);
    final data = res.payload<AddressActionResponse>();

    if (data == null) {
      if (_sessionEnded(emit)) return;
      emit(_loaded.copyWith(
          isSaving: false,
          message: _msg(res.errorText() ?? 'Could not add address.',
              AddressAction.add,
              isError: true)));
      return;
    }

    final created = data.address;
    final text = data.message.isNotEmpty ? data.message : 'Address added successfully.';

    if (!wasLoaded || created == null) {
      // we do not know the full list yet -> pull the real one
      final ok = await _fetch(emit, showErrorState: false, select: created?.id);
      if (!ok) emit(_loaded.copyWith(isSaving: false));
    } else {
      final cur = _loaded;
      emit(cur.copyWith(
        addresses: [...cur.addresses, created],
        selectedId: created.id, // newly added becomes the delivery address
        isSaving: false,
      ));
    }
    emit(_loaded.copyWith(message: _msg(text, AddressAction.add)));
  }

  // ---------------- UPDATE ----------------
  Future<void> _onUpdate(UpdateAddressEvent e, Emitter<AddressState> emit) async {
    if (_loaded.isSaving) return;
    emit(_loaded.copyWith(isSaving: true));

    final res = await _provider.updateAddressProvider(e.addressId, e.input);
    final data = res.payload<AddressActionResponse>();

    if (data == null) {
      if (_sessionEnded(emit)) return;
      emit(_loaded.copyWith(
          isSaving: false,
          message: _msg(res.errorText() ?? 'Could not update address.',
              AddressAction.update,
              isError: true)));
      return;
    }

    final updated = data.address ?? e.input.toModel(e.addressId);
    final cur = _loaded;
    emit(cur.copyWith(
      addresses: cur.addresses.map((a) => a.id == e.addressId ? updated : a).toList(),
      isSaving: false,
      message: _msg(
          data.message.isNotEmpty ? data.message : 'Address updated successfully.',
          AddressAction.update),
    ));
  }

  // ---------------- DELETE ----------------
  Future<void> _onDelete(DeleteAddressEvent e, Emitter<AddressState> emit) async {
    final s = state;
    if (s is! AddressLoadedState || s.busyIds.contains(e.addressId)) return;

    emit(s.copyWith(busyIds: {...s.busyIds, e.addressId}));

    final res = await _provider.deleteAddressProvider(addressId: e.addressId);
    final data = res.payload<AddressActionResponse>();

    final cur = _loaded;
    final busy = {...cur.busyIds}..remove(e.addressId);

    if (data == null) {
      if (_sessionEnded(emit)) return;
      emit(cur.copyWith(
          busyIds: busy,
          message: _msg(res.errorText() ?? 'Could not delete address.',
              AddressAction.delete,
              isError: true)));
      return;
    }

    final left = cur.addresses.where((a) => a.id != e.addressId).toList();
    emit(AddressLoadedState(
      addresses: left,
      selectedId: _pick(left, cur.selectedId),
      busyIds: busy,
      message: _msg(
          data.message.isNotEmpty ? data.message : 'Address deleted successfully.',
          AddressAction.delete),
    ));
  }

  // ---------------- SELECT ----------------
  void _onSelect(SelectAddressEvent e, Emitter<AddressState> emit) {
    final s = state;
    if (s is! AddressLoadedState || !s.addresses.any((a) => a.id == e.addressId)) {
      return;
    }
    emit(s.copyWith(selectedId: e.addressId));
  }
}
