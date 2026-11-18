class RegistrationResponse {
  final String status;
  final String statusCode;
  final String message;
  final String email;

  RegistrationResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.email,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : {};
    return RegistrationResponse(
      status: (json['status'] ?? '').toString(),
      statusCode: (json['status_code'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
    );
  }
}