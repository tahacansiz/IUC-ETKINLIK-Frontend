/// Auth Service
/// Kimlik doğrulama işlemleri için servis katmanı
/// API endpoint'leri placeholder olarak tanımlanmıştır
library;

import '../models/models.dart';
import 'mock_data.dart';

/// Auth işlemlerinin sonucu
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.user,
    this.token,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user, String token) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Auth Service - Kimlik doğrulama servisi
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Giriş yap
  /// 
  /// Endpoint: POST /auth/login
  /// Body: { email, password }
  /// Response: { user, token }
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // API çağrısı simülasyonu - gerçek implementasyonda HTTP request yapılacak
    await Future.delayed(const Duration(seconds: 1)); // Network gecikmesi simülasyonu

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      //   body: jsonEncode({'email': email, 'password': password}),
      // );

      // Mock login - email ve şifre kontrolü
      final user = MockUsers.findByCredentials(email, password);
      
      if (user != null) {
        // Mock token oluştur
        final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        return AuthResult.success(user, mockToken);
      } else {
        return AuthResult.failure('Email veya şifre hatalı');
      }
    } catch (e) {
      return AuthResult.failure('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Kayıt ol
  /// 
  /// Endpoint: POST /auth/register
  /// Body: { fullName, email, password, role }
  /// Response: { user, token }
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(seconds: 1));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
      //   body: jsonEncode({
      //     'fullName': fullName,
      //     'email': email,
      //     'password': password,
      //     'role': role.name,
      //   }),
      // );

      // Mock kayıt - yeni kullanıcı oluştur
      // Gerçek uygulamada email tekrarı kontrolü backend'de yapılacak
      if (email.contains('@')) {
        final newUser = UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          fullName: fullName,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
        return AuthResult.success(newUser, mockToken);
      } else {
        return AuthResult.failure('Geçersiz email adresi');
      }
    } catch (e) {
      return AuthResult.failure('Bir hata oluştu: ${e.toString()}');
    }
  }

  /// Çıkış yap
  /// 
  /// Endpoint: POST /auth/logout
  Future<bool> logout() async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı - token'ı geçersiz kıl
      // await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Local storage'dan token ve kullanıcı bilgilerini sil
      // await _clearStoredAuth();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Token yenile
  /// 
  /// Endpoint: POST /auth/refresh
  /// Body: { refreshToken }
  /// Response: { token, refreshToken }
  Future<String?> refreshToken(String refreshToken) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
      //   body: jsonEncode({'refreshToken': refreshToken}),
      // );

      // Mock token yenileme
      return 'new_mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return null;
    }
  }

  /// Mevcut kullanıcıyı getir (token'dan)
  /// 
  /// Endpoint: GET /users/profile
  Future<UserModel?> getCurrentUser(String token) async {
    // API çağrısı simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // TODO: Gerçek API çağrısı
      // final response = await http.get(
      //   Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Mock - varsayılan student kullanıcısını döndür
      return MockUsers.student;
    } catch (e) {
      return null;
    }
  }

  /// Şifre sıfırlama isteği
  /// 
  /// Endpoint: POST /auth/forgot-password
  /// Body: { email }
  Future<bool> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // TODO: Gerçek API çağrısı
      // await http.post(
      //   Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      //   body: jsonEncode({'email': email}),
      // );

      return true; // Email gönderildi
    } catch (e) {
      return false;
    }
  }
}
