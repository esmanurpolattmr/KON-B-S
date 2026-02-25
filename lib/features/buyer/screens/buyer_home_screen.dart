import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../qr/qr_scan_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  bool _qrVerified = false;
  String? _lastOrderId;

  void _openQrScanner() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(
          title: 'Teslim QR Tarama',
          expectedPayload: 'KONBIS_DELIVERY_OK',
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _qrVerified = true;
        _lastOrderId = 'KNB-${DateTime.now().millisecondsSinceEpoch % 100000}';
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppTheme.primaryGreen, size: 28),
            SizedBox(width: 10),
            Text('Teslimat Onaylandı!',
                style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(
          'Paketiniz başarıyla teslim alındı.\nSipariş: $_lastOrderId',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam',
                style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: Row(
          children: const [
            Icon(Icons.shopping_bag_rounded,
                color: AppTheme.accentBlue, size: 22),
            SizedBox(width: 8),
            Text('Alıcı Paneli'),
          ],
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hoşgeldin kartı
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.accentBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hoş geldin! 👋',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paketini teslim almak için QR tara',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              Text(
                'Teslimat İşlemleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ).animate(delay: 100.ms).fadeIn(),

              const SizedBox(height: 12),

              // QR Tara butonu - büyük ve belirgin
              GestureDetector(
                onTap: _openQrScanner,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentBlue.withValues(alpha: 0.2),
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.accentBlue.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: AppTheme.accentBlue,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'QR ile Teslim Al',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kurye QR kodunu tara, teslimatı onayla',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1),

              const SizedBox(height: 20),

              // Son teslimat durumu
              if (_qrVerified && _lastOrderId != null)
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Son Teslimat Onaylandı ✓',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppTheme.primaryGreen,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sipariş: $_lastOrderId',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const Spacer(),

              // Bilgi notu
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentOrange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.accentOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Güvenlik: Teslimat yalnızca QR kodu tarayarak onaylanır.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.accentOrange,
                            ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
