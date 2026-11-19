class LoginRequest {
  final String email;
  final String fcmToken;
  final String appVersion;
  final String model;
  final String modelName;
  final String modelVersion;

  LoginRequest({
    required this.email,
    required this.fcmToken,
    required this.appVersion,
    required this.model,
    required this.modelName,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'fcm_token': fcmToken,
    'app_version': appVersion,
    'model': model,
    'model_name': modelName,
    'model_version': modelVersion,
  };
}