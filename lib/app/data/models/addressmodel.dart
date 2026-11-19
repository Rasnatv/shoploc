int _toInt(dynamic v) =>
    int.tryParse(v?.toString() ?? '') ??
        (double.tryParse(v?.toString() ?? '')?.round() ?? 0);
String _toStr(dynamic v) => v?.toString() ?? '';

Map<String, dynamic> _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// One saved address.
/// { id, first_name, last_name, phone, address, city, state, zip }
class AddressModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;

  const AddressModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });

  String get fullName =>
      [firstName, lastName].where((s) => s.trim().isNotEmpty).join(' ');

  /// "House no 12, Main Road, Kanhangad, Kerala - 671315"
  String get formattedAddress {
    final line = [address, city, state].where((s) => s.trim().isNotEmpty).join(', ');
    return zip.isEmpty ? line : '$line - $zip';
  }

  AddressModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zip,
  }) =>
      AddressModel(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        zip: zip ?? this.zip,
      );

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: _toInt(json['id']),
    firstName: _toStr(json['first_name']),
    lastName: _toStr(json['last_name']),
    phone: _toStr(json['phone']),
    address: _toStr(json['address']),
    city: _toStr(json['city']),
    state: _toStr(json['state']),
    zip: _toStr(json['zip']),
  );
}

/// What the Add / Edit form sends (the same fields for both calls).
class AddressInput {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;

  const AddressInput({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'address': address,
    'city': city,
    'state': state,
    'zip': zip,
  };

  /// Used when the server answers without the saved address.
  AddressModel toModel(int id) => AddressModel(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    address: address,
    city: city,
    state: state,
    zip: zip,
  );
}

/// GET /address
/// { message, data: [ {address}, ... ] }
class AddressListResponse {
  final String message;
  final List<AddressModel> addresses;

  const AddressListResponse({required this.message, required this.addresses});

  factory AddressListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
        .whereType<Map>()
        .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : <AddressModel>[];
    return AddressListResponse(message: _toStr(json['message']), addresses: list);
  }
}

/// POST /address/add, /address/update   -> data: { address }
/// DELETE /address/delete               -> data: {}   (address is null)
class AddressActionResponse {
  final String message;
  final AddressModel? address;

  const AddressActionResponse({required this.message, this.address});

  factory AddressActionResponse.fromJson(Map<String, dynamic> json) {
    final map = _asMap(json['data']);
    return AddressActionResponse(
      message: _toStr(json['message']),
      address: map['id'] == null ? null : AddressModel.fromJson(map),
    );
  }
}
