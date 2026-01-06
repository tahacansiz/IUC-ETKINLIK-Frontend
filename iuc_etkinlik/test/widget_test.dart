// IUC Etkinlik Widget Test
//
// Temel widget testleri

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iuc_etkinlik/main.dart';

void main() {
  testWidgets('App starts and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: IUCEtkinlikApp()),
    );

    // Uygulama başlatılır ve giriş ekranı gösterilir
    await tester.pumpAndSettle();

    // Giriş ekranının gösterildiğini doğrula
    expect(find.text('Giriş Yap'), findsWidgets);
  });
}
