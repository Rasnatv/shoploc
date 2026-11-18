class RegisterRequest {
  final String name;
  final String email;
  final String fcmToken;
  final String appVersion;
  final String model;
  final String modelName;
  final String modelVersion;
  final String referralCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.fcmToken,
    required this.appVersion,
    required this.model,
    required this.modelName,
    required this.modelVersion,
    this.referralCode = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'fcm_token': fcmToken,
    'app_version': appVersion,
    'model': model,
    'model_name': modelName,
    'model_version': modelVersion,
    'referral_code': referralCode,
  };
}