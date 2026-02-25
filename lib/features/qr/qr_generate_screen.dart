import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class QrGenerateScreen extends StatelessWidget {
  final String payload;
  final String title;
  final String subtitle;
  final Color color;

  const QrGenerateScreen({
    super.key,
    required this.payload,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(backgroundColor: AppTheme.darkNavy, title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: color),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              const SizedBox(height: 40),
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.darkNavy,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                  )
                  .animate(delay: 200.ms)
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded, color: color, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Kurye bu QR\'ı okuyarak paketi teslim alır.',
                        style: TextStyle(color: color, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
