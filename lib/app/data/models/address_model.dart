class AddressModel {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String houseBuilding;
  final String street;
  final String city;
  final String state;
  final String pinCode;
  final String addressType; // 'Home', 'Work', 'Other'
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.houseBuilding,
    required this.street,
    required this.city,
    required this.state,
    required this.pinCode,
    this.addressType = 'Home',
    this.isDefault = false,
  });

  String get formattedAddress => '$houseBuilding, $street, $city, $state - $pinCode';

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? houseBuilding,
    String? street,
    String? city,
    String? state,
    String? pinCode,
    String? addressType,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      houseBuilding: houseBuilding ?? this.houseBuilding,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'houseBuilding': houseBuilding,
      'street': street,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      mobileNumber: map['mobileNumber']?.toString() ?? '',
      houseBuilding: map['houseBuilding']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      pinCode: map['pinCode']?.toString() ?? '',
      addressType: map['addressType']?.toString() ?? 'Home',
      isDefault: map['isDefault'] == true,
    );
  }
}

