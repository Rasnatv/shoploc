String _toStr(dynamic v) => v?.toString() ?? '';

/// POST /enquiry body
/// { name, email, subject, message }
class EnquiryRequest {
  final String name;
  final String email;
  final String subject;
  final String message;

  const EnquiryRequest({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'subject': subject,
    'message': message,
  };
}

/// POST /enquiry
/// { status, status_code: "201", message: "Thank you for your enquiry! ...", data: {} }
class EnquiryResponse {
  final String message;

  const EnquiryResponse({required this.message});

  factory EnquiryResponse.fromJson(Map<String, dynamic> json) =>
      EnquiryResponse(message: _toStr(json['message']));
}