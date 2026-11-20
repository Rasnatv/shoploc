String _toStr(dynamic v) => v?.toString() ?? '';

enum PolicyBlockType { paragraph, bullet, highlight }

/// One piece of a section: a paragraph, a bullet, or a highlighted note.
class PolicyBlock {
  final PolicyBlockType type;

  /// Bold lead-in of a bullet, e.g. "Payment Information:" (may be empty).
  final String label;
  final String text;

  const PolicyBlock({required this.type, required this.text, this.label = ''});
}

/// One section of GET /privacy-policy  ->  data.sections[]
/// { title, content, content_html }
class PolicySectionModel {
  final String title;
  final String content; // plain text
  final String contentHtml; // html
  final List<PolicyBlock> blocks; // parsed, ready to draw

  const PolicySectionModel({
    required this.title,
    required this.content,
    required this.contentHtml,
    required this.blocks,
  });

  factory PolicySectionModel.fromJson(Map<String, dynamic> json) {
    final content = _toStr(json['content']);
    final html = _toStr(json['content_html']);
    return PolicySectionModel(
      title: _toStr(json['title']),
      content: content,
      contentHtml: html,
      blocks: html.trim().isNotEmpty ? _parseHtml(html) : _parsePlain(content),
    );
  }

  // ---------- html -> blocks (no extra packages needed) ----------
  static final RegExp _blockRe = RegExp(
    r'<p[^>]*>(.*?)</p>|<li[^>]*>(.*?)</li>|<div[^>]*highlight-box[^>]*>(.*?)</div>',
    dotAll: true,
    caseSensitive: false,
  );
  static final RegExp _leadingStrongRe = RegExp(
    r'^\s*<strong>(.*?)</strong>\s*(.*)$',
    dotAll: true,
    caseSensitive: false,
  );

  static List<PolicyBlock> _parseHtml(String html) {
    final blocks = <PolicyBlock>[];
    for (final m in _blockRe.allMatches(html)) {
      if (m.group(1) != null) {
        final t = _cleanHtml(m.group(1)!);
        if (t.isNotEmpty) {
          blocks.add(PolicyBlock(type: PolicyBlockType.paragraph, text: t));
        }
      } else if (m.group(2) != null) {
        final raw = m.group(2)!;
        final strong = _leadingStrongRe.firstMatch(raw);
        if (strong != null) {
          final label = _cleanHtml(strong.group(1)!);
          final text = _cleanHtml(strong.group(2) ?? '');
          blocks.add(PolicyBlock(
              type: PolicyBlockType.bullet, label: label, text: text));
        } else {
          final t = _cleanHtml(raw);
          if (t.isNotEmpty) {
            blocks.add(PolicyBlock(type: PolicyBlockType.bullet, text: t));
          }
        }
      } else if (m.group(3) != null) {
        final t = _cleanHtml(m.group(3)!);
        if (t.isNotEmpty) {
          blocks.add(PolicyBlock(type: PolicyBlockType.highlight, text: t));
        }
      }
    }
    return blocks;
  }

  // ---------- plain text -> blocks (fallback) ----------
  static List<PolicyBlock> _parsePlain(String content) {
    final blocks = <PolicyBlock>[];
    for (final raw in content.split(RegExp(r'[\r\n]+'))) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('•')) {
        final body = line.substring(1).trim();
        final m = RegExp(r'^([^:]{1,40}:)\s+(.+)$').firstMatch(body);
        blocks.add(m != null
            ? PolicyBlock(
            type: PolicyBlockType.bullet, label: m.group(1)!, text: m.group(2)!)
            : PolicyBlock(type: PolicyBlockType.bullet, text: body));
      } else {
        blocks.add(PolicyBlock(type: PolicyBlockType.paragraph, text: line));
      }
    }
    return blocks;
  }

  static String _cleanHtml(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// GET /privacy-policy
/// { message, data: { title, sections: [...] } }
class PrivacyPolicyResponse {
  final String message;
  final String title;
  final List<PolicySectionModel> sections;

  const PrivacyPolicyResponse({
    required this.message,
    required this.title,
    required this.sections,
  });

  factory PrivacyPolicyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final raw = map['sections'];
    return PrivacyPolicyResponse(
      message: _toStr(json['message']),
      title: _toStr(map['title']).isEmpty ? 'Privacy Policy' : _toStr(map['title']),
      sections: raw is List
          ? raw
          .map((e) => PolicySectionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
          : <PolicySectionModel>[],
    );
  }
}