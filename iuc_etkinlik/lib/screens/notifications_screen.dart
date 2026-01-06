/// Notifications Screen
/// Bildirimler sayfası
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Bildirimleri yükle
    Future.microtask(() {
      ref.read(notificationListProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          // Tümünü okundu yap
          if (notificationState.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tümünü okundu yap',
              onPressed: () async {
                await ref
                    .read(notificationListProvider.notifier)
                    .markAllAsRead();
                if (context.mounted) {
                  context.showSnackBar('Tüm bildirimler okundu olarak işaretlendi');
                }
              },
            ),
        ],
      ),
      body: _buildBody(notificationState),
    );
  }

  Widget _buildBody(NotificationListState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingState(message: 'Bildirimler yükleniyor...');
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(notificationListProvider.notifier).loadNotifications();
        },
      );
    }

    if (state.notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'Bildirim Yok',
        message: 'Henüz bildiriminiz bulunmuyor.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationItem(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismiss: () => _handleNotificationDismiss(notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Okundu olarak işaretle
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier).markAsRead(notification.id);
    }

    // İlgili etkinliğe yönlendir (varsa)
    if (notification.eventId != null) {
      context.push('/events/${notification.eventId}');
    }
  }

  void _handleNotificationDismiss(NotificationModel notification) {
    ref.read(notificationListProvider.notifier).deleteNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bildirim silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            // TODO: Geri alma işlemi
            ref.read(notificationListProvider.notifier).refresh();
          },
        ),
      ),
    );
  }
}

/// Bildirim item widget'ı
class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const _NotificationItem({
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: context.colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: context.colorScheme.onError,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? null
                : context.colorScheme.primaryContainer.withValues(alpha: 0.2),
            border: Border(
              bottom: BorderSide(
                color: context.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İkon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColor(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      notification.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Mesaj
                    Text(
                      notification.message,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Zaman
                    Text(
                      DateTimeUtils.formatRelativeTime(notification.createdAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Okunmadı göstergesi
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.eventReminder:
        return Icons.alarm;
      case NotificationType.eventApproved:
        return Icons.check_circle_outline;
      case NotificationType.eventCancelled:
        return Icons.cancel_outlined;
      case NotificationType.eventUpdated:
        return Icons.update;
      case NotificationType.newEvent:
        return Icons.new_releases_outlined;
      case NotificationType.registrationConfirmed:
        return Icons.how_to_reg;
      case NotificationType.general:
        return Icons.info_outline;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.eventReminder:
        return AppColors.warning;
      case NotificationType.eventApproved:
        return AppColors.success;
      case NotificationType.eventCancelled:
        return context.colorScheme.error;
      case NotificationType.eventUpdated:
        return AppColors.tertiary;
      case NotificationType.newEvent:
        return context.colorScheme.primary;
      case NotificationType.registrationConfirmed:
        return AppColors.success;
      case NotificationType.general:
        return context.colorScheme.onSurfaceVariant;
    }
  }
}
