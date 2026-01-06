/// Notification Service
/// Bildirim işlemleri için servis katmanı
/// API endpoint'leri placeholder olarak tanımlanmıştır
library;

import '../models/models.dart';
import 'mock_data.dart';

/// Notification işlemlerinin sonucu
class NotificationResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  const NotificationResult({
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory NotificationResult.success(T data) {
    return NotificationResult(
      success: true,
      data: data,
    );
  }

  factory NotificationResult.failure(String message) {
    return NotificationResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Notification Service - Bildirim servisi
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // In-memory bildirim listesi (mock için)
  final List<NotificationModel> _mockNotifications = List.from(MockNotifications.all);

  /// Tüm bildirimleri getir
  /// 
  /// Endpoint: GET /notifications
  /// Query params: ?page=1&limit=20&unreadOnly=false
  Future<NotificationResult<List<NotificationModel>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final queryParams = {
      //   'page': page.toString(),
      //   'limit': limit.toString(),
      //   'unreadOnly': unreadOnly.toString(),
      // };
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notifications}')
      //       .replace(queryParameters: queryParams),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock bildirimleri döndür
      List<NotificationModel> notifications = List.from(_mockNotifications);

      // Sadece okunmamış filtresi
      if (unreadOnly) {
        notifications = notifications.where((n) => !n.isRead).toList();
      }

      // Tarihe göre sırala (en yeni en üstte)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex < notifications.length) {
        notifications = notifications.sublist(
          startIndex,
          endIndex > notifications.length ? notifications.length : endIndex,
        );
      } else {
        notifications = [];
      }

      return NotificationResult.success(notifications);
    } catch (e) {
      return NotificationResult.failure('Bildirimler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  /// Okunmamış bildirim sayısını getir
  /// 
  /// Endpoint: GET /notifications/unread-count
  Future<NotificationResult<int>> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}/notifications/unread-count'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock okunmamış sayısı
      final count = _mockNotifications.where((n) => !n.isRead).length;
      return NotificationResult.success(count);
    } catch (e) {
      return NotificationResult.failure('Bildirim sayısı alınamadı');
    }
  }

  /// Bildirimi okundu olarak işaretle
  /// 
  /// Endpoint: PUT /notifications/{id}/read
  Future<NotificationResult<bool>> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.put(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.markNotificationRead(notificationId)}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - bildirimi okundu olarak işaretle
      final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _mockNotifications[index] = _mockNotifications[index].markAsRead();
        return NotificationResult.success(true);
      }
      return NotificationResult.failure('Bildirim bulunamadı');
    } catch (e) {
      return NotificationResult.failure('Bildirim güncellenemedi: ${e.toString()}');
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  /// 
  /// Endpoint: PUT /notifications/read-all
  Future<NotificationResult<bool>> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.put(
      //   Uri.parse('${ApiConstants.baseUrl}/notifications/read-all'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - tüm bildirimleri okundu yap
      for (int i = 0; i < _mockNotifications.length; i++) {
        _mockNotifications[i] = _mockNotifications[i].markAsRead();
      }
      return NotificationResult.success(true);
    } catch (e) {
      return NotificationResult.failure('Bildirimler güncellenemedi: ${e.toString()}');
    }
  }

  /// Bildirim sil
  /// 
  /// Endpoint: DELETE /notifications/{id}
  Future<NotificationResult<bool>> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.delete(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notificationById(notificationId)}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - bildirimi sil
      _mockNotifications.removeWhere((n) => n.id == notificationId);
      return NotificationResult.success(true);
    } catch (e) {
      return NotificationResult.failure('Bildirim silinemedi: ${e.toString()}');
    }
  }

  /// Yeni bildirim ekle (test için)
  void addMockNotification(NotificationModel notification) {
    _mockNotifications.insert(0, notification);
  }
}
