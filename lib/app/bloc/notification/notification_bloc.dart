// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../apiprovider/notificatioprovider.dart';
// import '../../core/utils/object_factory.dart';
// import '../../data/models/notificationmodel.dart';
// import '../../data/models/statemodel.dart';
// import 'notification_event.dart';
// import 'notification_state.dart';
//
// class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
//   static const String _lastSeenKey = 'last_seen_notification_id';
//
//   final NotificationProvider _provider;
//
//   NotificationBloc({NotificationProvider? provider})
//       : _provider = provider ?? NotificationProvider(),
//         super(const NotificationInitialState()) {
//     on<LoadNotificationsEvent>(_onLoad);
//     on<RefreshNotificationsEvent>(_onRefresh);
//     on<MarkNotificationsSeenEvent>(_onMarkSeen);
//   }
//
//   bool get _hasToken => ObjectFactory().prefs.hasAuthToken;
//
//   Future<int> _lastSeenId() async {
//     final sp = await SharedPreferences.getInstance();
//     return sp.getInt(_lastSeenKey) ?? 0;
//   }
//
//   int _unread(List<NotificationModel> list, int lastSeen) =>
//       list.where((n) => n.id > lastSeen).length;
//
//   Future<void> _onLoad(LoadNotificationsEvent e, Emitter<NotificationState> emit) async {
//     if (!_hasToken) {
//       emit(const NotificationInitialState());
//       return;
//     }
//     emit(const NotificationLoadingState());
//     await _fetch(emit);
//   }
//
//   Future<void> _onRefresh(RefreshNotificationsEvent e, Emitter<NotificationState> emit) async {
//     if (!_hasToken) {
//       emit(const NotificationInitialState());
//       return;
//     }
//     await _fetch(emit);
//   }
//
//   Future<void> _fetch(Emitter<NotificationState> emit) async {
//     try {
//       final res = await _provider.notificationsProvider();
//       final data = res.payload<NotificationsResponse>();
//       if (data == null) {
//         emit(NotificationErrorState(
//             errorMessage: res.errorText() ?? 'Failed to load notifications.'));
//         return;
//       }
//       final lastSeen = await _lastSeenId();
//       emit(NotificationLoadedState(
//         notifications: data.notifications,
//         unreadCount: _unread(data.notifications, lastSeen),
//       ));
//     } catch (_) {
//       emit(const NotificationErrorState(
//           errorMessage: 'Something went wrong. Please try again.'));
//     }
//   }
//
//   Future<void> _onMarkSeen(MarkNotificationsSeenEvent e, Emitter<NotificationState> emit) async {
//     final current = state;
//     if (current is! NotificationLoadedState || current.notifications.isEmpty) return;
//     final newest = current.notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b);
//     final sp = await SharedPreferences.getInstance();
//     await sp.setInt(_lastSeenKey, newest);
//     emit(current.copyWith(unreadCount: 0));
//   }
// }
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiprovider/notificatioprovider.dart';
import '../../core/services/pushnotificationservice.dart';
import '../../core/utils/object_factory.dart';
import '../../data/models/notificationmodel.dart';
import '../../data/models/statemodel.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState>
    with WidgetsBindingObserver {
  static const String _lastSeenKey = 'last_seen_notification_id';

  final NotificationProvider _provider;
  StreamSubscription<void>? _pushSub;

  NotificationBloc({NotificationProvider? provider})
      : _provider = provider ?? NotificationProvider(),
        super(const NotificationInitialState()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<RefreshNotificationsEvent>(_onRefresh);
    on<MarkNotificationsSeenEvent>(_onMarkSeen);

    // 1) Push received while the app is open -> refresh list + badge.
    _pushSub = PushNotificationService.instance.onForegroundMessage.listen((_) {
      // Small delay so the backend has time to save the notification.
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) add(const RefreshNotificationsEvent());
      });
    });

    // 2) App comes back from background -> refresh list + badge.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isClosed) {
      add(const RefreshNotificationsEvent());
    }
  }

  @override
  Future<void> close() {
    _pushSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  bool get _hasToken => ObjectFactory().prefs.hasAuthToken;

  Future<int> _lastSeenId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_lastSeenKey) ?? 0;
  }

  int _unread(List<NotificationModel> list, int lastSeen) =>
      list.where((n) => n.id > lastSeen).length;

  Future<void> _onLoad(
      LoadNotificationsEvent e, Emitter<NotificationState> emit) async {
    if (!_hasToken) {
      emit(const NotificationInitialState());
      return;
    }
    emit(const NotificationLoadingState());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      RefreshNotificationsEvent e, Emitter<NotificationState> emit) async {
    if (!_hasToken) {
      emit(const NotificationInitialState());
      return;
    }
    // No loading state here -> list/badge update silently, no flicker.
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<NotificationState> emit) async {
    try {
      final res = await _provider.notificationsProvider();
      final data = res.payload<NotificationsResponse>();
      if (data == null) {
        emit(NotificationErrorState(
            errorMessage: res.errorText() ?? 'Failed to load notifications.'));
        return;
      }
      final lastSeen = await _lastSeenId();
      emit(NotificationLoadedState(
        notifications: data.notifications,
        unreadCount: _unread(data.notifications, lastSeen),
      ));
    } catch (_) {
      emit(const NotificationErrorState(
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onMarkSeen(
      MarkNotificationsSeenEvent e, Emitter<NotificationState> emit) async {
    final current = state;
    if (current is! NotificationLoadedState || current.notifications.isEmpty) {
      return;
    }
    final newest =
    current.notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b);
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_lastSeenKey, newest);
    emit(current.copyWith(unreadCount: 0));
  }
}