import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../data/models/address_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';


class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  final String? initialFullName;
  final String? initialPhone;

  const AddEditAddressScreen({
    super.key,
    this.address,
    this.initialFullName,
    this.initialPhone,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _houseController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinController;
  String _addressType = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameController = TextEditingController(text: a?.fullName ?? widget.initialFullName ?? '');
    _phoneController = TextEditingController(text: a?.mobileNumber ?? widget.initialPhone ?? '');
    _houseController = TextEditingController(text: a?.houseBuilding ?? '');
    _streetController = TextEditingController(text: a?.street ?? '');
    _cityController = TextEditingController(text: a?.city ?? 'Kochi');
    _stateController = TextEditingController(text: a?.state ?? 'Kerala');
    _pinController = TextEditingController(text: a?.pinCode ?? '');
    _addressType = a?.addressType ?? 'Home';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final isEdit = widget.address != null;
      final newAddress = AddressModel(
        id: widget.address?.id ?? 'addr_${1000 + Random().nextInt(9000)}',
        fullName: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        houseBuilding: _houseController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pinCode: _pinController.text.trim(),
        addressType: _addressType,
        isDefault: _isDefault,
      );

      if (isEdit) {
        context.read<AddressBloc>().add(UpdateAddressEvent(address: newAddress));
      } else {
        context.read<AddressBloc>().add(AddAddressEvent(address: newAddress));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Address' : 'Add New Address', style: AppTextStyle.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'e.g. Ananya Sharma',
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                label: 'Mobile Number *',
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _houseController,
                label: 'House No. / Flat / Building *',
                hint: 'e.g. Flat 302, Rose Enclave',
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _streetController,
                label: 'Street / Area / Landmark *',
                hint: 'e.g. Near Infopark, Kakkanad',
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'City *',
                      hint: 'City',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State *',
                      hint: 'State',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _pinController,
                label: 'PIN Code *',
                hint: '6-digit PIN code',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  if (val.trim().length != 6) return 'Enter 6 digits';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Address Type Chips
              Text('Address Type', style: AppTextStyle.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Work', 'Other'].map((type) {
                  final isSelected = _addressType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: AppTextStyle.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _addressType = type),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Default address switch

              const SizedBox(height: 24),

              CustomButton(
                text: isEdit ? 'Update Address' : 'Save Address',
                onPressed: _saveAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

