/// Bildirim modeli
/// Uygulama bildirimlerini temsil eder
library;

/// Bildirim türleri enum'u
enum NotificationType {
  eventReminder('Etkinlik Hatırlatma'),
  eventApproved('Etkinlik Onaylandı'),
  eventCancelled('Etkinlik İptal Edildi'),
  eventUpdated('Etkinlik Güncellendi'),
  newEvent('Yeni Etkinlik'),
  registrationConfirmed('Kayıt Onaylandı'),
  general('Genel Bildirim');

  final String displayName;
  const NotificationType(this.displayName);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationType.general,
    );
  }
}

/// Bildirim modeli
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? eventId; // İlişkili etkinlik ID'si (varsa)
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.eventId,
    required this.createdAt,
    this.isRead = false,
  });

  /// JSON'dan NotificationModel oluşturma
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      eventId: json['eventId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// NotificationModel'i JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'eventId': eventId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// copyWith metodu
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? eventId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Bildirimi okundu olarak işaretle
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }
}
