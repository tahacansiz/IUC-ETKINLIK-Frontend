/// Notification Provider
/// Bildirim state yönetimi (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Notification listesi state sınıfı
class NotificationListState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final String? errorMessage;
  final int unreadCount;

  const NotificationListState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage,
    this.unreadCount = 0,
  });

  NotificationListState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification List Notifier - Bildirim listesi state'i yönetir
class NotificationListNotifier extends Notifier<NotificationListState> {
  late NotificationService _notificationService;

  @override
  NotificationListState build() {
    _notificationService = ref.watch(notificationServiceProvider);
    return const NotificationListState();
  }

  /// Bildirimleri yükle
  Future<void> loadNotifications({bool unreadOnly = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _notificationService.getNotifications(
      unreadOnly: unreadOnly,
    );

    if (result.success && result.data != null) {
      final unreadCount =
          result.data!.where((n) => !n.isRead).length;
      state = state.copyWith(
        isLoading: false,
        notifications: result.data,
        unreadCount: unreadCount,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }
  }

  /// Okunmamış bildirim sayısını güncelle
  Future<void> updateUnreadCount() async {
    final result = await _notificationService.getUnreadCount();
    if (result.success && result.data != null) {
      state = state.copyWith(unreadCount: result.data);
    }
  }

  /// Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    final result = await _notificationService.markAsRead(notificationId);

    if (result.success) {
      // Local state'i güncelle
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.markAsRead();
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    final result = await _notificationService.markAllAsRead();

    if (result.success) {
      // Local state'i güncelle
      final updatedNotifications = state.notifications
          .map((n) => n.markAsRead())
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    }
  }

  /// Bildirimi sil
  Future<void> deleteNotification(String notificationId) async {
    final notification = state.notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => throw Exception('Notification not found'),
    );

    final result = await _notificationService.deleteNotification(notificationId);

    if (result.success) {
      final updatedNotifications = state.notifications
          .where((n) => n.id != notificationId)
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: notification.isRead
            ? state.unreadCount
            : state.unreadCount - 1,
      );
    }
  }

  /// Listeyi yenile
  Future<void> refresh() async {
    await loadNotifications();
  }
}

// ==================== PROVIDERS ====================

/// Notification List Provider
final notificationListProvider =
    NotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);

/// Unread Count Provider - Badge için okunmamış bildirim sayısı
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationListProvider).unreadCount;
});

