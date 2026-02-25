import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/carbon_calculator.dart';
import '../../courier/screens/courier_home_screen.dart';

class DeliveryCompleteScreen extends StatelessWidget {
  final double distanceKm;
  final double carbonSaved;
  final double bisPoints;

  const DeliveryCompleteScreen({
    super.key,
    required this.distanceKm,
    required this.carbonSaved,
    required this.bisPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, Color(0xFF00A87A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                    'Teslimat Tamamlandı! 🎉',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Harika iş! Bisikletinle dünyaya katkı sağladın.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              // Stats row
              Row(
                children: [
                  _StatCard(
                    value: distanceKm.toStringAsFixed(2),
                    unit: 'km',
                    label: 'Mesafe',
                    icon: Icons.route_rounded,
                    color: AppTheme.accentBlue,
                    delay: 500,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: CarbonCalculator.formatCo2(carbonSaved),
                    unit: '',
                    label: 'CO₂ Tasarruf',
                    icon: Icons.eco_rounded,
                    color: AppTheme.primaryGreen,
                    delay: 600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // BiS Points big card
              _BigPointCard(points: bisPoints)
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.15),
              const SizedBox(height: 16),
              // Tree equivalent
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🌳', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        CarbonCalculator.treeEquivalent(carbonSaved),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourierHomeScreen(),
                    ),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.directions_bike_rounded),
                  label: const Text('Devam Et'),
                ),
              ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, unit, label;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ).animate(delay: delay.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15),
    );
  }
}

class _BigPointCard extends StatelessWidget {
  final double points;
  const _BigPointCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.warning.withValues(alpha: 0.2), AppTheme.cardDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BiS Puan Kazandın!',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppTheme.warning),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${points.toStringAsFixed(0)} puan',
                  style: const TextStyle(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
