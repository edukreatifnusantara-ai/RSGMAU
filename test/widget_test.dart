import 'package:flutter_test/flutter_test.dart';

import 'package:bukusaku_standalone/main.dart';

void main() {
  testWidgets('splash screen menampilkan logo RSGMAU', (tester) async {
    await tester.pumpWidget(const BukuSakuApp());
    expect(find.bySemanticsLabel('Masuk ke Buku Saku RSGM AU'), findsOneWidget);
    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('logo membuka beranda dengan empat fitur utama', (tester) async {
    await tester.pumpWidget(const BukuSakuApp());
    await tester.tap(find.bySemanticsLabel('Masuk ke Buku Saku RSGM AU'));
    await tester.pumpAndSettle();
    expect(find.text('Buku Saku RSGMAU'), findsOneWidget);
    expect(find.text('Siap menghadapi survei?'), findsOneWidget);
    expect(find.text('Materi Akreditasi'), findsOneWidget);
    expect(find.text('Panduan Cepat'), findsOneWidget);
    expect(find.text('Latihan Tanya Jawab'), findsOneWidget);
    expect(find.text('Cari Materi'), findsOneWidget);
  });

  testWidgets('menu RSGMAU menampilkan tiga slot sambutan', (tester) async {
    await tester.pumpWidget(const BukuSakuApp());
    await tester.tap(find.bySemanticsLabel('Masuk ke Buku Saku RSGM AU'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RSGMAU').last);
    await tester.pumpAndSettle();
    expect(find.text('Kepala Lakesgilut AU'), findsOneWidget);
    expect(find.text('Kepala RSGMAU'), findsOneWidget);
    expect(find.text('Ketua Akreditasi RSGMAU'), findsOneWidget);
  });
}
