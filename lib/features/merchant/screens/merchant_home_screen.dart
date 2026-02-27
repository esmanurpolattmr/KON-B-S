import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../wallet/wallet_screen.dart';
import '../models/listing.dart';
import '../providers/merchant_provider.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MerchantProvider>();
    final allListings = provider.listings;

    final shown = _tabIndex == 0
        ? allListings.where((l) => l.status == ListingStatus.open).toList()
        : allListings.where((l) => l.status != ListingStatus.open).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: Row(
          children: [
            const Icon(
              Icons.store_rounded,
              color: AppTheme.accentOrange,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('Gönderici Paneli'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stat banner
          _StatBanner(listings: allListings),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _CustomTabBar(
              index: _tabIndex,
              tabs: const ['Açık İlanlar', 'Geçmiş'],
              onChange: (i) => setState(() => _tabIndex = i),
            ),
          ),
          // List
          Expanded(
            child: shown.isEmpty
                ? _EmptyState(tabIndex: _tabIndex)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: shown.length,
                    itemBuilder: (ctx, i) {
                      final listing = shown[i];
                      return _ListingCard(listing: listing)
                          .animate(delay: (i * 60).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        ),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni İlan'),
      ),
    );
  }
}

class _StatBanner extends StatelessWidget {
  final List<Listing> listings;
  const _StatBanner({required this.listings});

  @override
  Widget build(BuildContext context) {
    final open = listings.where((l) => l.status == ListingStatus.open).length;
    final delivered =
        listings.where((l) => l.status == ListingStatus.delivered).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentOrange.withValues(alpha: 0.15),
            AppTheme.cardDark
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '$open',
            label: 'Açık',
            color: AppTheme.primaryGreen,
          ),
          _StatItem(
            value: '${listings.length}',
            label: 'Toplam',
            color: AppTheme.accentBlue,
          ),
          _StatItem(
            value: '$delivered',
            label: 'Teslim',
            color: AppTheme.accentOrange,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final statusColor = listing.status == ListingStatus.open
        ? AppTheme.primaryGreen
        : listing.status == ListingStatus.assigned
            ? AppTheme.warning
            : AppTheme.textSecondary;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: listing),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      listing.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${listing.pickupAddress} → ${listing.deliveryAddress}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.timeWindowStart} - ${listing.timeWindowEnd}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.scale_rounded,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.weightKg} kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final int index;
  final List<String> tabs;
  final ValueChanged<int> onChange;
  const _CustomTabBar({
    required this.index,
    required this.tabs,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDarker,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.accentOrange : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: sel ? Colors.white : AppTheme.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  const _EmptyState({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabIndex == 0 ? Icons.add_box_outlined : Icons.history_rounded,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            tabIndex == 0 ? 'Henüz açık ilan yok' : 'Geçmiş ilan bulunamadı',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          if (tabIndex == 0) ...[
            const SizedBox(height: 8),
            Text(
              'Sağ alttaki + butonuna bas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
