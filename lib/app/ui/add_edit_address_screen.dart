
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/addressbloc/address_bloc.dart';
import '../bloc/addressbloc/address_event.dart';
import '../bloc/addressbloc/address_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/object_factory.dart';
import '../core/utils/validator.dart';
import '../data/models/addressmodel.dart';
import '../widgets/appsnackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive.dart';

/// Add a new address, or edit one when [address] is given.
/// Pops with `true` after a successful save.
///
/// Routes:  AppRouter.addressAdd  /  AppRouter.addressEdit
class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  bool get isEdit => address != null;

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _zip;

  /// Only react to bloc messages caused by this form.
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;

    // New address: pre-fill the name from the logged-in user.
    final parts =
    (ObjectFactory().prefs.getUserName() ?? '').trim().split(RegExp(r'\s+'));
    final userFirst = parts.isNotEmpty ? parts.first : '';
    final userLast = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    _first = TextEditingController(text: a?.firstName ?? userFirst);
    _last = TextEditingController(text: a?.lastName ?? userLast);
    _phone = TextEditingController(text: a?.phone ?? '');
    _address = TextEditingController(text: a?.address ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _state = TextEditingController(text: a?.state ?? '');
    _zip = TextEditingController(text: a?.zip ?? '');

  }

  @override
  void dispose() {
    for (final c in [_first, _last, _phone, _address, _city, _state, _zip]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.warning('Please correct the highlighted fields.');
      return;
    }
    FocusScope.of(context).unfocus();

    final input = AddressInput(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      zip: _zip.text.trim(),
    );

    _submitted = true;
    final bloc = context.read<AddressBloc>();
    if (widget.isEdit) {
      bloc.add(UpdateAddressEvent(addressId: widget.address!.id, input: input));
    } else {
      bloc.add(AddAddressEvent(input: input));
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: Responsive.sp(14));
    final gapW = SizedBox(width: Responsive.sp(12));

    return BlocConsumer<AddressBloc, AddressState>(
      listenWhen: (prev, cur) =>
      cur is AddressLoadedState &&
          cur.message != null &&
          cur.message!.action != AddressAction.delete &&
          (prev is! AddressLoadedState || prev.message?.seq != cur.message!.seq),
      listener: (context, state) {
        if (!_submitted) return;
        final m = (state as AddressLoadedState).message!;
        if (m.isError) {
          AppSnackbar.error(m.text);
        } else {
          AppSnackbar.success(m.text);
          context.pop(true);
        }
      },
      builder: (context, state) {
        final saving = state is AddressLoadedState && state.isSaving;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(widget.isEdit ? 'Edit Address' : 'Add Address',
                style: AppTextStyle.appBarTitle),
          ),
          body: SafeArea(
            // keeps the form centred and readable on tablets
            child: ResponsiveCenter(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(Responsive.sp(16)),
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _first,
                                    label: 'First Name',
                                    hint: 'First name',
                                    validator: (v) =>
                                        DValidator.validateName('First name', v),
                                  ),
                                ),
                                gapW,
                                Expanded(
                                  child: CustomTextField(
                                    controller: _last,
                                    label: 'Last Name',
                                    hint: 'Last name',
                                    validator: (v) => DValidator.validateName(
                                        'Last name', v,
                                        minLength: 1),
                                  ),
                                ),
                              ],
                            ),
                            gap,
                            CustomTextField(
                              controller: _phone,
                              label: 'Phone Number',
                              hint: '10-digit mobile number',
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [_IndianPhoneFormatter()],
                              prefixIcon: Icon(Icons.phone_outlined,
                                  size: Responsive.sp(20)),
                              validator: DValidator.validatePhoneNumber,
                            ),
                            gap,
                            CustomTextField(
                              controller: _address,
                              label: 'Address',
                              hint: 'House no, building, street',
                              maxLines: 2,
                              keyboardType: TextInputType.streetAddress,
                              validator: DValidator.validateAddress,
                            ),
                            gap,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _city,
                                    label: 'City',
                                    hint: 'City',
                                    validator: (v) =>
                                        DValidator.validateName('City', v),
                                  ),
                                ),
                                gapW,
                                Expanded(
                                  child: CustomTextField(
                                    controller: _state,
                                    label: 'State',
                                    hint: 'State',
                                    validator: (v) =>
                                        DValidator.validateName('State', v),
                                  ),
                                ),
                              ],
                            ),
                            gap,
                            CustomTextField(
                              controller: _zip,
                              label: 'PIN Code',
                              hint: '6-digit PIN code',
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textInputAction: TextInputAction.done,
                              validator: DValidator.validatePinCode,
                              onSubmitted: (_) {
                                if (!saving) _save();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(Responsive.sp(16),
                        Responsive.sp(10), Responsive.sp(16), Responsive.sp(12)),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border:
                      Border(top: BorderSide(color: AppColors.borderLight)),
                    ),
                    child: CustomButton(
                      text: widget.isEdit ? 'Update Address' : 'Save Address',
                      isLoading: saving,
                      onPressed: saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Digits only, max 10. A pasted "+91 98765 43210" becomes 9876543210.
class _IndianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) digits = digits.substring(0, 10);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}