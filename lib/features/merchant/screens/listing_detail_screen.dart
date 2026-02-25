import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../qr/qr_generate_screen.dart';
import '../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        backgroundColor: AppTheme.darkNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            listing.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      listing.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Alış Adresi',
                      value: listing.pickupAddress,
                      color: AppTheme.primaryGreen,
                    ),
                    const Divider(color: AppTheme.cardDarker, height: 24),
                    _InfoRow(
                      icon: Icons.flag_rounded,
                      label: 'Teslimat Adresi',
                      value: listing.deliveryAddress,
                      color: AppTheme.accentOrange,
                    ),
                    const Divider(color: AppTheme.cardDarker, height: 24),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Zaman Aralığı',
                      value:
                          '${listing.timeWindowStart} - ${listing.timeWindowEnd}',
                      color: AppTheme.accentBlue,
                    ),
                    const Divider(color: AppTheme.cardDarker, height: 24),
                    _InfoRow(
                      icon: Icons.scale_rounded,
                      label: 'Ağırlık',
                      value: '${listing.weightKg} kg',
                      color: AppTheme.warning,
                    ),
                  ],
                ),
              ),
            ),
            if (listing.status == ListingStatus.open) ...[
              const SizedBox(height: 24),
              Text(
                'Paket QR Kodu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Kurye paketi alırken bu QR\'ı okuyacak.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrGenerateScreen(
                        payload: listing.qrPayload,
                        title: 'Alış QR Kodu',
                        subtitle: listing.title,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Alış QR Göster'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrGenerateScreen(
                        payload: listing.deliveryQrPayload,
                        title: 'Teslim QR Kodu',
                        subtitle: listing.title,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Teslim QR Göster'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
