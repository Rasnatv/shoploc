import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notificationbloc/notification_bloc.dart';
import '../bloc/notificationbloc/notification_event.dart';
import '../bloc/notificationbloc/notification_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_style.dart';
import '../core/utils/formatters.dart';
import '../widgets/empty_state_view.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyle.appBarTitle),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoadedState && state.notifications.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'read_all') {
                      context.read<NotificationBloc>().add(const MarkAllNotificationsAsReadEvent());
                    } else if (val == 'clear_all') {
                      context.read<NotificationBloc>().add(const ClearAllNotificationsEvent());
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'read_all',
                      child: Text('Mark all as read'),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text('Clear all', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is NotificationLoadedState) {
            if (state.notifications.isEmpty) {
              return EmptyStateView(
                icon: Icons.notifications_off_outlined,
                title: 'No Notifications',
                message: 'You\'re all caught up! Promotional drops and order tracking alerts will appear here.',
                buttonText: 'Explore Collections',
                onButtonPressed: () => Navigator.of(context).pop(),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = state.notifications[index];
                final icon = _getIconForType(notif.type);

                return GestureDetector(
                  onTap: () {
                    context.read<NotificationBloc>().add(
                          MarkNotificationAsReadEvent(notificationId: notif.id),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notif.isRead ? AppColors.surface : AppColors.primaryMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: notif.isRead ? AppColors.borderLight : AppColors.primaryLight.withValues(alpha: 0.4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notif.isRead ? AppColors.surfaceVariant : AppColors.primaryMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: notif.isRead ? AppColors.textSecondary : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: AppTextStyle.labelLarge.copyWith(
                                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (!notif.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif.message, style: AppTextStyle.bodySmall),
                              const SizedBox(height: 6),
                              Text(
                                Formatters.formatDateTime(notif.timestamp),
                                style: AppTextStyle.caption.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
