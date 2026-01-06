/// Utility fonksiyonlar ve helper'lar
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tarih formatlama utility'leri
class DateTimeUtils {
  /// Tarih formatla: "15 Ocak 2026"
  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(dateTime);
  }

  /// Saat formatla: "14:30"
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Tarih ve saat formatla: "15 Ocak 2026, 14:30"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(dateTime);
  }

  /// Kısa tarih formatla: "15 Oca"
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('d MMM', 'tr_TR').format(dateTime);
  }

  /// Görece zaman: "2 saat önce", "Yarın", vb.
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Geçmiş zaman
      final absDiff = difference.abs();
      if (absDiff.inMinutes < 1) {
        return 'Az önce';
      } else if (absDiff.inMinutes < 60) {
        return '${absDiff.inMinutes} dakika önce';
      } else if (absDiff.inHours < 24) {
        return '${absDiff.inHours} saat önce';
      } else if (absDiff.inDays < 7) {
        return '${absDiff.inDays} gün önce';
      } else {
        return formatDate(dateTime);
      }
    } else {
      // Gelecek zaman
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} dakika sonra';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} saat sonra';
      } else if (difference.inDays == 1) {
        return 'Yarın';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün sonra';
      } else {
        return formatDate(dateTime);
      }
    }
  }

  /// Gün adı getir: "Pazartesi"
  static String getDayName(DateTime dateTime) {
    return DateFormat('EEEE', 'tr_TR').format(dateTime);
  }

  /// Bugün mü kontrol et
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Yarın mı kontrol et
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }
}

/// Validasyon utility'leri
class ValidationUtils {
  /// Email validasyonu
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi girin';
    }
    return null;
  }

  /// Şifre validasyonu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  /// İsim validasyonu
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gerekli';
    }
    if (value.length < 2) {
      return 'En az 2 karakter girin';
    }
    return null;
  }

  /// Boş alan validasyonu
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }
    return null;
  }

  /// Açıklama validasyonu
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama gerekli';
    }
    if (value.length < 10) {
      return 'Açıklama en az 10 karakter olmalı';
    }
    if (value.length > 1000) {
      return 'Açıklama en fazla 1000 karakter olabilir';
    }
    return null;
  }
}

/// String extension'ları
extension StringExtensions on String {
  /// İlk harfi büyük yap
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Her kelimenin ilk harfini büyük yap
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Kısalt (maxLength karakterden uzunsa ...)
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Context extension'ları
extension ContextExtensions on BuildContext {
  /// Theme'e kolay erişim
  ThemeData get theme => Theme.of(this);

  /// ColorScheme'e kolay erişim
  ColorScheme get colorScheme => theme.colorScheme;

  /// TextTheme'e kolay erişim
  TextTheme get textTheme => theme.textTheme;

  /// MediaQuery'e kolay erişim
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ekran genişliği
  double get screenWidth => mediaQuery.size.width;

  /// Ekran yüksekliği
  double get screenHeight => mediaQuery.size.height;

  /// Mobil cihaz mı?
  bool get isMobile => screenWidth < 600;

  /// Tablet mi?
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Desktop mu?
  bool get isDesktop => screenWidth >= 1200;

  /// Snackbar göster
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Loading dialog göster
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Dialog kapat
  void hideDialog() {
    Navigator.of(this).pop();
  }
}

/// Renk utility'leri
class ColorUtils {
  /// Hex string'den Color oluştur
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Color'dan hex string oluştur
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
