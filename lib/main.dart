import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/merchant/providers/merchant_provider.dart';
import 'features/courier/providers/courier_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KonbisApp());
}

class KonbisApp extends StatelessWidget {
  const KonbisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => CourierProvider()),
      ],
      child: MaterialApp(
        title: 'KonBis - Bisiklet Kurye',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
