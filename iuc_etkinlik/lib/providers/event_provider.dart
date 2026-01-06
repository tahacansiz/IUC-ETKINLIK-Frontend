/// Event Provider
/// Etkinlik state yönetimi (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'auth_provider.dart';

/// Event listesi state sınıfı
class EventListState {
  final bool isLoading;
  final List<EventModel> events;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const EventListState({
    this.isLoading = false,
    this.events = const [],
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  EventListState copyWith({
    bool? isLoading,
    List<EventModel>? events,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventListState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Event Service Provider
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

/// Event List Notifier - Etkinlik listesi state'i yönetir
class EventListNotifier extends Notifier<EventListState> {
  late EventService _eventService;

  @override
  EventListState build() {
    _eventService = ref.watch(eventServiceProvider);
    return const EventListState();
  }

  /// Etkinlikleri yükle (ilk sayfa)
  Future<void> loadEvents({
    String? categoryId,
    String? searchQuery,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _eventService.getEvents(
      page: 1,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );

    if (result.success && result.data != null) {
      state = state.copyWith(
        isLoading: false,
        events: result.data,
        hasMore: result.data!.length >= 20,
        currentPage: 1,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }
  }

  /// Daha fazla etkinlik yükle (pagination)
  Future<void> loadMoreEvents({
    String? categoryId,
    String? searchQuery,
  }) async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final result = await _eventService.getEvents(
      page: state.currentPage + 1,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );

    if (result.success && result.data != null) {
      state = state.copyWith(
        isLoading: false,
        events: [...state.events, ...result.data!],
        hasMore: result.data!.length >= 20,
        currentPage: state.currentPage + 1,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
    }
  }

  /// Listeyi yenile
  Future<void> refresh({
    String? categoryId,
    String? searchQuery,
  }) async {
    state = const EventListState();
    await loadEvents(categoryId: categoryId, searchQuery: searchQuery);
  }
}

/// Filtre state sınıfı
class EventFilterState {
  final String? categoryId;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const EventFilterState({
    this.categoryId,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  EventFilterState copyWith({
    String? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return EventFilterState(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  /// Filtre aktif mi?
  bool get hasActiveFilter =>
      categoryId != null ||
      searchQuery.isNotEmpty ||
      startDate != null ||
      endDate != null;

  /// Filtreleri temizle
  EventFilterState clear() {
    return const EventFilterState();
  }
}

/// Event Filter Notifier
class EventFilterNotifier extends Notifier<EventFilterState> {
  @override
  EventFilterState build() {
    return const EventFilterState();
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void clearFilters() {
    state = state.clear();
  }
}

// ==================== PROVIDERS ====================

/// Event List Provider
final eventListProvider = NotifierProvider<EventListNotifier, EventListState>(
  EventListNotifier.new,
);

/// Event Detail Provider - FutureProvider.family olarak tanımlandı (eventId parametresi alır)
final eventDetailProvider = FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final eventService = ref.watch(eventServiceProvider);
  final result = await eventService.getEventById(eventId);
  if (result.success && result.data != null) {
    return result.data;
  }
  return null;
});

/// Event Filter Provider
final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilterState>(
  EventFilterNotifier.new,
);

/// Featured Events Provider
final featuredEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  final result = await eventService.getFeaturedEvents();
  if (result.success && result.data != null) {
    return result.data!;
  }
  return [];
});

/// Upcoming Events Provider
final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  final result = await eventService.getUpcomingEvents(limit: 10);
  if (result.success && result.data != null) {
    return result.data!;
  }
  return [];
});

/// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final eventService = ref.watch(eventServiceProvider);
  final result = await eventService.getCategories();
  if (result.success && result.data != null) {
    return result.data!;
  }
  return [];
});

/// Create Event State
class CreateEventState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final EventModel? createdEvent;

  const CreateEventState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.createdEvent,
  });

  CreateEventState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    EventModel? createdEvent,
  }) {
    return CreateEventState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      createdEvent: createdEvent ?? this.createdEvent,
    );
  }
}

/// Create Event Notifier
class CreateEventNotifier extends Notifier<CreateEventState> {
  late EventService _eventService;

  @override
  CreateEventState build() {
    _eventService = ref.watch(eventServiceProvider);
    return const CreateEventState();
  }

  /// Yeni etkinlik oluştur
  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String categoryId,
    String? imageUrl,
    int maxParticipants = 100,
  }) async {
    final authState = ref.read(authProvider);
    
    if (authState.user == null) {
      state = state.copyWith(errorMessage: 'Kullanıcı bulunamadı');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await _eventService.createEvent(
      title: title,
      description: description,
      dateTime: dateTime,
      location: location,
      categoryId: categoryId,
      organizerId: authState.user!.id,
      organizerName: authState.user!.fullName,
      imageUrl: imageUrl,
      maxParticipants: maxParticipants,
    );

    if (result.success && result.data != null) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdEvent: result.data,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// State'i sıfırla
  void reset() {
    state = const CreateEventState();
  }
}

/// Create Event Provider
final createEventProvider = NotifierProvider<CreateEventNotifier, CreateEventState>(
  CreateEventNotifier.new,
);

