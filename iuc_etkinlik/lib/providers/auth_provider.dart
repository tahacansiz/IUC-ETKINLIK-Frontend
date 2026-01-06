/// Auth Provider
/// Kimlik doğrulama state yönetimi (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Auth durumu
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state sınıfı
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  /// Initial state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Loading state
  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  /// Authenticated state
  factory AuthState.authenticated(UserModel user, String token) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
    );
  }

  /// Unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Error state
  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// copyWith metodu
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Kullanıcı Club Admin mi?
  bool get isClubAdmin => user?.role == UserRole.clubAdmin;

  /// Kullanıcı Student mi?
  bool get isStudent => user?.role == UserRole.student;
}

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth Notifier - Auth state'i yönetir
class AuthNotifier extends Notifier<AuthState> {
  late AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return AuthState.initial();
  }

  /// Giriş yap
  Future<bool> login(String email, String password) async {
    state = AuthState.loading();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result.success && result.user != null) {
      state = AuthState.authenticated(result.user!, result.token!);
      return true;
    } else {
      state = AuthState.error(result.errorMessage ?? 'Giriş başarısız');
      return false;
    }
  }

  /// Kayıt ol
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = AuthState.loading();

    final result = await _authService.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    if (result.success && result.user != null) {
      state = AuthState.authenticated(result.user!, result.token!);
      return true;
    } else {
      state = AuthState.error(result.errorMessage ?? 'Kayıt başarısız');
      return false;
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    state = AuthState.loading();
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  /// Hata mesajını temizle
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.unauthenticated();
    }
  }

  /// Kullanıcının katıldığı etkinliklere etkinlik ekle
  void addJoinedEvent(String eventId) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        joinedEventIds: [...state.user!.joinedEventIds, eventId],
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  /// Kullanıcının katıldığı etkinliklerden etkinlik çıkar
  void removeJoinedEvent(String eventId) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        joinedEventIds: state.user!.joinedEventIds
            .where((id) => id != eventId)
            .toList(),
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  /// Kullanıcı bu etkinliğe katılmış mı?
  bool hasJoinedEvent(String eventId) {
    return state.user?.joinedEventIds.contains(eventId) ?? false;
  }
}

/// Auth State Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Alias for backward compatibility
final authStateProvider = authProvider;

/// Current User Provider - Mevcut kullanıcıya kolay erişim
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is Authenticated Provider - Giriş durumuna kolay erişim
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is Club Admin Provider - Admin kontrolüne kolay erişim
final isClubAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isClubAdmin;
});
