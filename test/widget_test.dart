import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konbis/main.dart';
import 'package:konbis/features/merchant/providers/merchant_provider.dart';
import 'package:konbis/features/courier/providers/courier_provider.dart';
import 'package:konbis/features/wallet/providers/wallet_provider.dart';

void main() {
  testWidgets('KonbisApp smoke test - uygulama başlıyor', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MerchantProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => CourierProvider()),
        ],
        child: const KonbisApp(),
      ),
    );
    // Splash ekranı veya uygulama başarıyla render edilmeli
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
