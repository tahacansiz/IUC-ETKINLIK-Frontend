/// Uygulama sabitleri
/// API endpoint'leri ve diğer sabit değerler
library;

/// API sabitleri
class ApiConstants {
  // Base URL - Backend hazır olduğunda güncellenecek
  static const String baseUrl = 'https://api.iuc-etkinlik.com/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Event endpoints
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static const String featuredEvents = '/events/featured';
  static const String upcomingEvents = '/events/upcoming';
  static String joinEvent(String id) => '/events/$id/join';
  static String leaveEvent(String id) => '/events/$id/leave';

  // User endpoints
  static const String profile = '/users/profile';
  static const String userEvents = '/users/events';

  // Notification endpoints
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Category endpoints
  static const String categories = '/categories';

  // Timeout süreleri
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Uygulama sabitleri
class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'İÜC Etkinlik';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
}

/// Asset yolları
class AssetPaths {
  // Images
  static const String images = 'assets/images';
  static const String logo = '$images/logo.png';
  static const String placeholder = '$images/placeholder.png';
  static const String emptyState = '$images/empty_state.png';
  static const String errorState = '$images/error_state.png';

  // Icons
  static const String icons = 'assets/icons';

  // Lottie animations
  static const String animations = 'assets/animations';
  static const String loadingAnimation = '$animations/loading.json';
  static const String successAnimation = '$animations/success.json';
}

/// Placeholder image URL'leri (Mock data için)
class PlaceholderImages {
  static const String event1 =
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800';
  static const String event2 =
      'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800';
  static const String event3 =
      'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800';
  static const String event4 =
      'https://images.unsplash.com/photo-1591115765373-5207764f72e7?w=800';
  static const String event5 =
      'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=800';
  static const String avatar =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200';

  static const List<String> eventImages = [
    event1,
    event2,
    event3,
    event4,
    event5,
  ];
}
