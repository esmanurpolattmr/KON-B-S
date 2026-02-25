import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/carbon_calculator.dart';
import '../../../shared/widgets/glass_card.dart';
import 'models/bis_transaction.dart';
import 'providers/wallet_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: const Text('BiS Cüzdan'),
      ),
      body: wallet.transactions.isEmpty
          ? _EmptyWallet()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _WalletHeader(wallet: wallet)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final tx = wallet.transactions[i];
                      return _TransactionCard(tx: tx)
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1);
                    }, childCount: wallet.transactions.length),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  final WalletProvider wallet;
  const _WalletHeader({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF007A5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Toplam BiS Puanı',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                wallet.totalBisPoints.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'puan',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStatChip(
                icon: Icons.eco_rounded,
                label: CarbonCalculator.formatCo2(wallet.totalCo2Saved),
                bgColor: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 10),
              _MiniStatChip(
                icon: Icons.route_rounded,
                label: '${wallet.totalKm.toStringAsFixed(1)} km',
                bgColor: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 10),
              _MiniStatChip(
                icon: Icons.local_shipping_rounded,
                label: '${wallet.transactions.length} teslimat',
                bgColor: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  const _MiniStatChip({
    required this.icon,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final BisTransaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_bike_rounded,
                color: AppTheme.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.deliveryTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tx.distanceKm.toStringAsFixed(1)} km • ${CarbonCalculator.formatCo2(tx.co2SavedKg)} tasarruf',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '+${tx.bisPoints.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppTheme.warning,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz teslimat yok',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Teslimat yaptıkça puan kazanacaksın!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
