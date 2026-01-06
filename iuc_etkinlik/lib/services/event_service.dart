/// Event Service
/// Etkinlik işlemleri için servis katmanı
/// API endpoint'leri placeholder olarak tanımlanmıştır
library;

import '../models/models.dart';
import 'mock_data.dart';

/// Event işlemlerinin sonucu
class EventResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  const EventResult({
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory EventResult.success(T data) {
    return EventResult(
      success: true,
      data: data,
    );
  }

  factory EventResult.failure(String message) {
    return EventResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Event Service - Etkinlik servisi
class EventService {
  // Singleton pattern
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  // In-memory event listesi (mock için)
  final List<EventModel> _mockEvents = List.from(MockEvents.all);

  /// Tüm etkinlikleri getir
  /// 
  /// Endpoint: GET /events
  /// Query params: ?page=1&limit=20&categoryId=...&search=...
  Future<EventResult<List<EventModel>>> getEvents({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // TODO: Gerçek API çağrısı
      // final queryParams = {
      //   'page': page.toString(),
      //   'limit': limit.toString(),
      //   if (categoryId != null) 'categoryId': categoryId,
      //   if (searchQuery != null) 'search': searchQuery,
      // };
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}')
      //       .replace(queryParameters: queryParams),
      // );

      // Mock filtreleme
      List<EventModel> events = List.from(_mockEvents);

      // Kategori filtresi
      if (categoryId != null && categoryId.isNotEmpty) {
        events = events.where((e) => e.categoryId == categoryId).toList();
      }

      // Arama filtresi
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        events = events.where((e) {
          return e.title.toLowerCase().contains(query) ||
              e.description.toLowerCase().contains(query) ||
              e.location.toLowerCase().contains(query);
        }).toList();
      }

      // Tarih aralığı filtresi
      if (startDate != null) {
        events = events.where((e) => e.dateTime.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        events = events.where((e) => e.dateTime.isBefore(endDate)).toList();
      }

      // Tarihe göre sırala
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex < events.length) {
        events = events.sublist(
          startIndex,
          endIndex > events.length ? events.length : endIndex,
        );
      } else {
        events = [];
      }

      return EventResult.success(events);
    } catch (e) {
      return EventResult.failure('Etkinlikler yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  /// Etkinlik detayı getir
  /// 
  /// Endpoint: GET /events/{id}
  Future<EventResult<EventModel>> getEventById(String id) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventById(id)}'),
      // );

      // Mock - ID'ye göre etkinlik bul
      final event = _mockEvents.where((e) => e.id == id).firstOrNull;

      if (event != null) {
        return EventResult.success(event);
      } else {
        return EventResult.failure('Etkinlik bulunamadı');
      }
    } catch (e) {
      return EventResult.failure('Etkinlik yüklenirken hata oluştu: ${e.toString()}');
    }
  }

  /// Öne çıkan etkinlikleri getir
  /// 
  /// Endpoint: GET /events/featured
  Future<EventResult<List<EventModel>>> getFeaturedEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.featuredEvents}'),
      // );

      // Mock - öne çıkan etkinlikler
      final featured = _mockEvents.where((e) => e.isFeatured).toList();
      return EventResult.success(featured);
    } catch (e) {
      return EventResult.failure('Öne çıkan etkinlikler yüklenirken hata oluştu');
    }
  }

  /// Yaklaşan etkinlikleri getir
  /// 
  /// Endpoint: GET /events/upcoming
  Future<EventResult<List<EventModel>>> getUpcomingEvents({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.upcomingEvents}?limit=$limit'),
      // );

      // Mock - yaklaşan etkinlikler
      final now = DateTime.now();
      final upcoming = _mockEvents
          .where((e) => e.dateTime.isAfter(now))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      return EventResult.success(upcoming.take(limit).toList());
    } catch (e) {
      return EventResult.failure('Yaklaşan etkinlikler yüklenirken hata oluştu');
    }
  }

  /// Yeni etkinlik oluştur
  /// 
  /// Endpoint: POST /events
  /// Body: { title, description, dateTime, location, categoryId, ... }
  Future<EventResult<EventModel>> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String categoryId,
    required String organizerId,
    required String organizerName,
    String? imageUrl,
    int maxParticipants = 100,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}'),
      //   headers: {'Authorization': 'Bearer $token'},
      //   body: jsonEncode({
      //     'title': title,
      //     'description': description,
      //     'dateTime': dateTime.toIso8601String(),
      //     'location': location,
      //     'categoryId': categoryId,
      //     'imageUrl': imageUrl,
      //     'maxParticipants': maxParticipants,
      //   }),
      // );

      // Mock - yeni etkinlik oluştur
      final newEvent = EventModel(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        dateTime: dateTime,
        location: location,
        imageUrl: imageUrl,
        categoryId: categoryId,
        organizerId: organizerId,
        organizerName: organizerName,
        maxParticipants: maxParticipants,
        currentParticipants: 0,
        status: EventStatus.upcoming,
        isFeatured: false,
        createdAt: DateTime.now(),
      );

      // Mock listeye ekle
      _mockEvents.insert(0, newEvent);

      return EventResult.success(newEvent);
    } catch (e) {
      return EventResult.failure('Etkinlik oluşturulurken hata oluştu: ${e.toString()}');
    }
  }

  /// Etkinliğe katıl
  /// 
  /// Endpoint: POST /events/{id}/join
  Future<EventResult<bool>> joinEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.joinEvent(eventId)}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - katılımcı sayısını artır
      final index = _mockEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _mockEvents[index];
        if (event.isFull) {
          return EventResult.failure('Etkinlik dolu');
        }
        _mockEvents[index] = event.copyWith(
          currentParticipants: event.currentParticipants + 1,
        );
        return EventResult.success(true);
      }
      return EventResult.failure('Etkinlik bulunamadı');
    } catch (e) {
      return EventResult.failure('Katılım işlemi başarısız: ${e.toString()}');
    }
  }

  /// Etkinlikten ayrıl
  /// 
  /// Endpoint: POST /events/{id}/leave
  Future<EventResult<bool>> leaveEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.leaveEvent(eventId)}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - katılımcı sayısını azalt
      final index = _mockEvents.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _mockEvents[index];
        if (event.currentParticipants > 0) {
          _mockEvents[index] = event.copyWith(
            currentParticipants: event.currentParticipants - 1,
          );
        }
        return EventResult.success(true);
      }
      return EventResult.failure('Etkinlik bulunamadı');
    } catch (e) {
      return EventResult.failure('Ayrılma işlemi başarısız: ${e.toString()}');
    }
  }

  /// Kategorileri getir
  /// 
  /// Endpoint: GET /categories
  Future<EventResult<List<CategoryModel>>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}'),
      // );

      // Mock kategoriler
      return EventResult.success(PredefinedCategories.categories);
    } catch (e) {
      return EventResult.failure('Kategoriler yüklenirken hata oluştu');
    }
  }
}
