String _s(dynamic v) => v == null ? '' : v.toString();

class UserModel {
  final int id;
  final String name;
  final String email;
  final String referralCode;
  final String referredByStaffId;
  final String referredByCode;
  final bool emailVerified;
  final String appVersion;
  final String deviceModel;
  final String deviceModelName;
  final String deviceModelVersion;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.referralCode,
    required this.referredByStaffId,
    required this.referredByCode,
    required this.emailVerified,
    required this.appVersion,
    required this.deviceModel,
    required this.deviceModelName,
    required this.deviceModelVersion,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: int.tryParse(_s(j['id'])) ?? 0,
    name: _s(j['name']),
    email: _s(j['email']),
    referralCode: _s(j['referral_code']),
    referredByStaffId: _s(j['referred_by_staff_id']),
    referredByCode: _s(j['referred_by_code']),
    emailVerified: j['email_verified'] == true,
    appVersion: _s(j['app_version']),
    deviceModel: _s(j['device_model']),
    deviceModelName: _s(j['device_model_name']),
    deviceModelVersion: _s(j['device_model_version']),
  );
}

class VerifyOtpResponse {
  final String status;
  final String statusCode;
  final String message;
  final String token;
  final UserModel user;

  VerifyOtpResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.token,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : <String, dynamic>{};
    return VerifyOtpResponse(
      status: _s(json['status']),
      statusCode: _s(json['status_code']),
      message: _s(json['message']),
      token: _s(data['token']),
      user: UserModel.fromJson(
        data['user'] is Map ? Map<String, dynamic>.from(data['user']) : {},
      ),
    );
  }
}