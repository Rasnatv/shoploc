import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/dummy_data/shoploc_dummy_data.dart';
import '../../data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final LocalStorageService _storageService;

  NotificationBloc({required LocalStorageService storageService})
      : _storageService = storageService,
        super(const NotificationInitialState()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
    on<ClearAllNotificationsEvent>(_onClearAll);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoadingState());
    final raw = _storageService.getNotifications();
    List<NotificationModel> notifications = [];

    if (raw.isNotEmpty) {
      notifications = raw.map((m) => NotificationModel.fromMap(m)).toList();
    } else {
      notifications = List.from(ShoplocDummyData.defaultNotifications);
      await _storageService.saveNotifications(
        notifications.map((n) => n.toMap()).toList(),
      );
    }

    emit(NotificationLoadedState(notifications: notifications));
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoadedState) return;
    var list = List<NotificationModel>.from((state as NotificationLoadedState).notifications);

    final index = list.indexWhere((n) => n.id == event.notificationId);
    if (index >= 0) {
      list[index] = list[index].copyWith(isRead: true);
      await _storageService.saveNotifications(list.map((n) => n.toMap()).toList());
      emit(NotificationLoadedState(notifications: list));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoadedState) return;
    var list = List<NotificationModel>.from((state as NotificationLoadedState).notifications);

    list = list.map((n) => n.copyWith(isRead: true)).toList();
    await _storageService.saveNotifications(list.map((n) => n.toMap()).toList());
    emit(NotificationLoadedState(notifications: list));
  }

  Future<void> _onClearAll(
    ClearAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _storageService.saveNotifications([]);
    emit(const NotificationLoadedState(notifications: []));
  }
}

