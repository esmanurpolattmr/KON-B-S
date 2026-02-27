import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../merchant/models/listing.dart';
import '../../merchant/providers/merchant_provider.dart';
import '../../wallet/wallet_screen.dart';
import '../providers/courier_provider.dart';
import 'active_delivery_screen.dart';

class CourierHomeScreen extends StatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  State<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends State<CourierHomeScreen> {
  bool _mapView = false;

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<MerchantProvider>().openListings;
    final courier = context.watch<CourierProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: Row(
          children: [
            const Icon(
              Icons.directions_bike_rounded,
              color: AppTheme.primaryGreen,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('Mevcut İlanlar'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _mapView ? Icons.list_rounded : Icons.map_rounded,
              color: AppTheme.primaryGreen,
            ),
            onPressed: () => setState(() => _mapView = !_mapView),
          ),
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
          if (courier.isDelivering)
            _ActiveDeliveryBanner(listing: courier.activeDelivery!),
          // Map / List toggle
          Expanded(
            child: _mapView
                ? _MapViewSection(listings: listings)
                : listings.isEmpty
                ? _NoListings()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: listings.length,
                    itemBuilder: (ctx, i) {
                      return _AvailableCard(listing: listings[i])
                          .animate(delay: (i * 70).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveryBanner extends StatelessWidget {
  final Listing listing;
  const _ActiveDeliveryBanner({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveDeliveryScreen(listing: listing),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen.withValues(alpha: 0.25),
              AppTheme.cardDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_rounded,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktif Teslimat',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    listing.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.primaryGreen,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final Listing listing;
  const _AvailableCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAcceptBottomSheet(context, listing),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          listing.merchantName,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AÇIK',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                  const Spacer(),
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

  void _showAcceptBottomSheet(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AcceptSheet(listing: listing),
    );
  }
}

class _AcceptSheet extends StatelessWidget {
  final Listing listing;
  const _AcceptSheet({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Teslimatı Kabul Et',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            listing.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.store_rounded, text: listing.merchantName),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.location_on_rounded,
            text: listing.pickupAddress,
          ),
          const SizedBox(height: 8),
          _DetailRow(icon: Icons.flag_rounded, text: listing.deliveryAddress),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.access_time_rounded,
            text: '${listing.timeWindowStart} - ${listing.timeWindowEnd}',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CourierProvider>().acceptDelivery(listing);
                context.read<MerchantProvider>().updateListingStatus(
                  listing.id,
                  ListingStatus.assigned,
                  courierId: 'courier-current',
                );
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveDeliveryScreen(listing: listing),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Kabul Et ve Başla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MapViewSection extends StatefulWidget {
  final List<Listing> listings;
  const _MapViewSection({required this.listings});

  @override
  State<_MapViewSection> createState() => _MapViewSectionState();
}

class _MapViewSectionState extends State<_MapViewSection> {
  final MapController _mapController = MapController();
  double _currentZoom = 13.5;
  static const double _minZoom = 5.0;
  static const double _maxZoom = 18.0;

  void _zoomIn() {
    if (_currentZoom < _maxZoom) {
      setState(
        () => _currentZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom),
      );
      _mapController.move(_mapController.camera.center, _currentZoom);
    }
  }

  void _zoomOut() {
    if (_currentZoom > _minZoom) {
      setState(
        () => _currentZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom),
      );
      _mapController.move(_mapController.camera.center, _currentZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    const center = LatLng(37.8713, 32.4846); // Konya - Alaeddin Tepesi

    return Stack(
      children: [
        RepaintBoundary(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentZoom,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.konbis.konbis',
                keepBuffer: 3,
                maxZoom: 18,
                tileDimension: 256,
              ),
              MarkerLayer(
                markers: widget.listings
                    .map(
                      (l) => Marker(
                        point: l.pickupLocation,
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _showAcceptBottomSheet(context, l),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppTheme.darkNavy,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        // Zoom kontrol butonları (web ve mobil için)
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              _ZoomButton(
                icon: Icons.add_rounded,
                onTap: _zoomIn,
                enabled: _currentZoom < _maxZoom,
              ),
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 1,
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 4),
              _ZoomButton(
                icon: Icons.remove_rounded,
                onTap: _zoomOut,
                enabled: _currentZoom > _minZoom,
              ),
            ],
          ),
        ),
        // Zoom seviyesi göstergesi
        Positioned(
          left: 16,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.zoom_in_rounded,
                  size: 14,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  'Zoom: ${_currentZoom.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAcceptBottomSheet(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AcceptSheet(listing: listing),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardDark.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? AppTheme.primaryGreen.withValues(alpha: 0.5)
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icon,
            color: enabled
                ? AppTheme.primaryGreen
                : AppTheme.textSecondary.withValues(alpha: 0.3),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _NoListings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 72,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Şu an mevcut ilan yok',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
