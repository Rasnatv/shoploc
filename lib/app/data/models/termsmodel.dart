import 'privacypolicymodel.dart';

String _toStr(dynamic v) => v?.toString() ?? '';

/// GET /terms-and-conditions
/// { status, status_code, message, data: { title, sections: [{ title, content, content_html }] } }
///
/// Sections use the same shape as the privacy policy, so [PolicySectionModel]
/// (which parses content_html into paragraph / bullet / highlight blocks) is reused.
class TermsResponse {
  final String message;
  final String title;
  final List<PolicySectionModel> sections;

  const TermsResponse({
    required this.message,
    required this.title,
    required this.sections,
  });

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map =
    data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final raw = map['sections'];
    final title = _toStr(map['title']);
    return TermsResponse(
      message: _toStr(json['message']),
      title: title.isEmpty ? 'Terms and Conditions' : title,
      sections: raw is List
          ? raw
          .map((e) =>
          PolicySectionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
          : <PolicySectionModel>[],
    );
  }
}