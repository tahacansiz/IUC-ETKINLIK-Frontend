/// Mock Data
/// Backend hazır olana kadar kullanılacak örnek veriler
library;

import '../models/models.dart';
import '../core/constants.dart';

/// Mock kullanıcılar
class MockUsers {
  static final UserModel student = UserModel(
    id: 'user_1',
    fullName: 'Ahmet Yılmaz',
    email: 'ahmet@stu.iuc.edu.tr',
    role: UserRole.student,
    avatarUrl: PlaceholderImages.avatar,
    createdAt: DateTime(2024, 9, 1),
    joinedEventIds: ['event_1', 'event_3'],
  );

  static final UserModel clubAdmin = UserModel(
    id: 'user_2',
    fullName: 'Elif Demir',
    email: 'elif@iuc.edu.tr',
    role: UserRole.clubAdmin,
    avatarUrl: PlaceholderImages.avatar,
    createdAt: DateTime(2024, 8, 15),
    joinedEventIds: ['event_2'],
  );

  static final List<UserModel> all = [student, clubAdmin];

  /// Email ve şifre ile kullanıcı bul (Mock login)
  static UserModel? findByCredentials(String email, String password) {
    // Mock validasyon - gerçek uygulamada backend yapacak
    if (email == 'ahmet@stu.iuc.edu.tr' && password == '123456') {
      return student;
    }
    if (email == 'elif@iuc.edu.tr' && password == '123456') {
      return clubAdmin;
    }
    return null;
  }
}

/// Mock etkinlikler
class MockEvents {
  static List<EventModel> get all => [
        EventModel(
          id: 'event_1',
          title: 'Yapay Zeka ve Gelecek Konferansı',
          description:
              'Bu konferansta yapay zekanın günümüzdeki uygulamaları ve gelecekte bizi neler beklediği hakkında konuşacağız. Alanında uzman konuşmacılar eşliğinde interaktif bir etkinlik olacak.',
          dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
          location: 'Ana Konferans Salonu',
          imageUrl: PlaceholderImages.event1,
          categoryId: '1',
          organizerId: 'user_2',
          organizerName: 'Bilişim Kulübü',
          maxParticipants: 200,
          currentParticipants: 145,
          status: EventStatus.upcoming,
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        EventModel(
          id: 'event_2',
          title: 'Flutter ile Mobil Uygulama Geliştirme Workshop',
          description:
              'Sıfırdan Flutter öğrenerek kendi mobil uygulamanızı geliştirin. Workshop sonunda basit bir uygulama yapabilecek seviyeye geleceksiniz.',
          dateTime: DateTime.now().add(const Duration(days: 7, hours: 10)),
          location: 'Bilgisayar Lab 3',
          imageUrl: PlaceholderImages.event2,
          categoryId: '2',
          organizerId: 'user_2',
          organizerName: 'Yazılım Kulübü',
          maxParticipants: 30,
          currentParticipants: 28,
          status: EventStatus.upcoming,
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        EventModel(
          id: 'event_3',
          title: 'Kariyer Günleri 2026',
          description:
              'Sektörün önde gelen şirketleri ile tanışma fırsatı. CV değerlendirmesi, mülakat simülasyonları ve networking imkanı.',
          dateTime: DateTime.now().add(const Duration(days: 14, hours: 9)),
          location: 'Spor Salonu',
          imageUrl: PlaceholderImages.event3,
          categoryId: '7',
          organizerId: 'user_2',
          organizerName: 'Kariyer Merkezi',
          maxParticipants: 500,
          currentParticipants: 320,
          status: EventStatus.upcoming,
          isFeatured: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        EventModel(
          id: 'event_4',
          title: 'Bahar Konseri',
          description:
              'Üniversitemiz müzik kulübünün hazırladığı bahar konseri. Pop, rock ve Türk halk müziği dinletisi.',
          dateTime: DateTime.now().add(const Duration(days: 21, hours: 19)),
          location: 'Açık Hava Amfisi',
          imageUrl: PlaceholderImages.event4,
          categoryId: '5',
          organizerId: 'user_2',
          organizerName: 'Müzik Kulübü',
          maxParticipants: 1000,
          currentParticipants: 456,
          status: EventStatus.upcoming,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        EventModel(
          id: 'event_5',
          title: 'Futbol Turnuvası Finali',
          description:
              'Fakülteler arası futbol turnuvası final maçı. Mühendislik vs İşletme karşılaşması.',
          dateTime: DateTime.now().add(const Duration(days: 5, hours: 16)),
          location: 'Futbol Sahası',
          imageUrl: PlaceholderImages.event5,
          categoryId: '4',
          organizerId: 'user_2',
          organizerName: 'Spor Kulübü',
          maxParticipants: 300,
          currentParticipants: 180,
          status: EventStatus.upcoming,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        EventModel(
          id: 'event_6',
          title: 'Girişimcilik Semineri',
          description:
              'Başarılı girişimcilerden dinleyeceğiniz deneyimler ve startup dünyasına giriş.',
          dateTime: DateTime.now().add(const Duration(days: 10, hours: 13)),
          location: 'İşletme Fakültesi Konferans Salonu',
          imageUrl: PlaceholderImages.event1,
          categoryId: '3',
          organizerId: 'user_2',
          organizerName: 'Girişimcilik Kulübü',
          maxParticipants: 150,
          currentParticipants: 89,
          status: EventStatus.upcoming,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        EventModel(
          id: 'event_7',
          title: 'Resim Sergisi Açılışı',
          description:
              'Güzel Sanatlar öğrencilerinin eserlerinin sergileneceği yıllık sergi açılışı.',
          dateTime: DateTime.now().add(const Duration(days: 2, hours: 11)),
          location: 'Sanat Galerisi',
          imageUrl: PlaceholderImages.event3,
          categoryId: '6',
          organizerId: 'user_2',
          organizerName: 'Sanat Kulübü',
          maxParticipants: 100,
          currentParticipants: 45,
          status: EventStatus.upcoming,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        EventModel(
          id: 'event_8',
          title: 'Öğrenci Buluşması',
          description:
              'Tüm fakültelerden öğrencilerin kaynaşacağı sosyal etkinlik. Oyunlar, müzik ve ikramlar.',
          dateTime: DateTime.now().add(const Duration(days: 8, hours: 15)),
          location: 'Kampüs Çim Alanı',
          imageUrl: PlaceholderImages.event2,
          categoryId: '8',
          organizerId: 'user_2',
          organizerName: 'Öğrenci Konseyi',
          maxParticipants: 250,
          currentParticipants: 120,
          status: EventStatus.upcoming,
          isFeatured: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ];

  /// Öne çıkan etkinlikleri getir
  static List<EventModel> get featured =>
      all.where((event) => event.isFeatured).toList();

  /// Yaklaşan etkinlikleri getir (tarihe göre sıralı)
  static List<EventModel> get upcoming {
    final now = DateTime.now();
    return all
        .where((event) => event.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// ID'ye göre etkinlik bul
  static EventModel? findById(String id) {
    try {
      return all.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Kategoriye göre filtrele
  static List<EventModel> filterByCategory(String categoryId) {
    return all.where((event) => event.categoryId == categoryId).toList();
  }

  /// Arama yap
  static List<EventModel> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
          event.description.toLowerCase().contains(lowerQuery) ||
          event.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Mock bildirimler
class MockNotifications {
  static List<NotificationModel> get all => [
        NotificationModel(
          id: 'notif_1',
          title: 'Etkinlik Hatırlatması',
          message:
              'Yapay Zeka ve Gelecek Konferansı 3 gün sonra başlayacak. Unutmayın!',
          type: NotificationType.eventReminder,
          eventId: 'event_1',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Kayıt Onaylandı',
          message:
              'Flutter Workshop etkinliğine kaydınız başarıyla tamamlandı.',
          type: NotificationType.registrationConfirmed,
          eventId: 'event_2',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'Yeni Etkinlik',
          message: 'Kariyer Günleri 2026 etkinliği yayınlandı. Hemen inceleyin!',
          type: NotificationType.newEvent,
          eventId: 'event_3',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: 'notif_4',
          title: 'Etkinlik Güncellendi',
          message: 'Bahar Konseri etkinliğinin saati değişti. Yeni detayları kontrol edin.',
          type: NotificationType.eventUpdated,
          eventId: 'event_4',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
        NotificationModel(
          id: 'notif_5',
          title: 'Hoş Geldiniz!',
          message:
              'İÜC Etkinlik uygulamasına hoş geldiniz. Kampüsteki etkinlikleri keşfedin!',
          type: NotificationType.general,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          isRead: true,
        ),
      ];

  /// Okunmamış bildirimleri getir
  static List<NotificationModel> get unread =>
      all.where((notif) => !notif.isRead).toList();

  /// Okunmamış bildirim sayısı
  static int get unreadCount => unread.length;
}
