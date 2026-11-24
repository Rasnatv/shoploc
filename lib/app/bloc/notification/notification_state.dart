import '../../data/models/notificationmodel.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitialState extends NotificationState {
  const NotificationInitialState();
}

class NotificationLoadingState extends NotificationState {
  const NotificationLoadingState();
}

class NotificationLoadedState extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoadedState({
    required this.notifications,
    required this.unreadCount,
  });

  bool get isEmpty => notifications.isEmpty;

  NotificationLoadedState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) =>
      NotificationLoadedState(
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

class NotificationErrorState extends NotificationState {
  final String errorMessage;
  const NotificationErrorState({required this.errorMessage});
}