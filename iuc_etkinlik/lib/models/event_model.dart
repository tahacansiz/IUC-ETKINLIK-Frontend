/// Etkinlik modeli
/// Uygulamadaki etkinlik verilerini temsil eder
library;

import 'category_model.dart';

/// Etkinlik durumu enum'u
enum EventStatus {
  upcoming('Yaklaşan'),
  ongoing('Devam Eden'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi');

  final String displayName;
  const EventStatus(this.displayName);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EventStatus.upcoming,
    );
  }
}

/// Etkinlik modeli
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String? imageUrl; // Afiş görseli
  final String categoryId;
  final String organizerId; // Etkinliği oluşturan kullanıcı ID'si
  final String organizerName;
  final int maxParticipants;
  final int currentParticipants;
  final EventStatus status;
  final bool isFeatured; // Öne çıkan etkinlik mi?
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    required this.categoryId,
    required this.organizerId,
    required this.organizerName,
    this.maxParticipants = 100,
    this.currentParticipants = 0,
    this.status = EventStatus.upcoming,
    this.isFeatured = false,
    required this.createdAt,
  });

  /// JSON'dan EventModel oluşturma (API response için)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as String,
      organizerId: json['organizerId'] as String,
      organizerName: json['organizerName'] as String,
      maxParticipants: json['maxParticipants'] as int? ?? 100,
      currentParticipants: json['currentParticipants'] as int? ?? 0,
      status: EventStatus.fromString(json['status'] as String? ?? 'upcoming'),
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// EventModel'i JSON'a dönüştürme (API request için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'status': status.name,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// copyWith metodu - immutable güncelleme için
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? imageUrl,
    String? categoryId,
    String? organizerId,
    String? organizerName,
    int? maxParticipants,
    int? currentParticipants,
    EventStatus? status,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Etkinliğin kategorisini getir
  CategoryModel? get category => PredefinedCategories.findById(categoryId);

  /// Etkinliğin doluluk oranı (yüzde)
  double get occupancyRate =>
      maxParticipants > 0 ? (currentParticipants / maxParticipants) * 100 : 0;

  /// Etkinlik dolu mu?
  bool get isFull => currentParticipants >= maxParticipants;

  /// Etkinlik geçmiş mi?
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// Kalan kontenjan
  int get remainingSlots => maxParticipants - currentParticipants;
}
