String _toStr(dynamic v) => v?.toString() ?? '';
int _toInt(dynamic v) => int.tryParse(_toStr(v)) ?? 0;

class NotificationModel {
  final int id;
  final String type; // order | promo | test ...
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String dateRaw;
  final DateTime? date;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.dateRaw,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final raw = _toStr(json['date']);
    return NotificationModel(
      id: _toInt(json['id']),
      type: _toStr(json['type']),
      title: _toStr(json['title']),
      body: _toStr(json['body']),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : <String, dynamic>{},
      dateRaw: raw,
      date: DateTime.tryParse(raw),
    );
  }
}

class NotificationsResponse {
  final String message;
  final List<NotificationModel> notifications;

  const NotificationsResponse({required this.message, required this.notifications});

  bool get isEmpty => notifications.isEmpty;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return NotificationsResponse(
      message: _toStr(json['message']),
      notifications: raw is List
          ? raw
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : <NotificationModel>[],
    );
  }
}