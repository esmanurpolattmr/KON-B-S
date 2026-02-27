import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Eklendi
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/carbon_calculator.dart';
import '../../../core/services/location_service.dart'; // Eklendi
import '../../../core/services/route_service.dart'; // Eklendi
import '../../merchant/models/listing.dart';
import '../../merchant/providers/merchant_provider.dart';
import '../../qr/qr_scan_screen.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/courier_provider.dart';
import 'delivery_complete_screen.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final Listing listing;
  const ActiveDeliveryScreen({super.key, required this.listing});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  List<LatLng> _routePoints = []; // Artık statik değil, servisten gelecek
  LatLng? _courierPos;
  double _distanceTravelled = 0.0;
  double _totalRouteDistanceKm = 0.0;

  StreamSubscription<Position>? _positionStream;
  final MapController _mapController = MapController();
  bool _hasPickedUp = false;
  bool _isLoadingRoute = true;

  // ValueNotifiers — sadece ilgili widget'ı rebuild eder
  final ValueNotifier<LatLng?> _posNotifier = ValueNotifier(null);
  final ValueNotifier<double> _distNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> _remainingDistNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _initDelivery();
  }

  Future<void> _initDelivery() async {
    _hasPickedUp = context.read<CourierProvider>().hasPickedUp;

    // Geçerli konumu alıp başlangıç noktası veya kurye pozisyonu yapalım
    final currentPos = await LocationService.getCurrentPosition();
    if (currentPos != null) {
      _courierPos = LatLng(currentPos.latitude, currentPos.longitude);
      _posNotifier.value = _courierPos;
    } else {
      // GPS kapalıysa ilan noktası varsayılır
      _courierPos = widget.listing.pickupLocation;
      _posNotifier.value = _courierPos;
    }

    if (_courierPos != null) {
      final initialDist = LocationService.getDistanceBetween(
        _courierPos!.latitude,
        _courierPos!.longitude,
        widget.listing.deliveryLocation.latitude,
        widget.listing.deliveryLocation.longitude,
      );
      _remainingDistNotifier.value = initialDist / 1000.0;
    }

    // Rotayı çizdir (Pickup -> Delivery)
    await _fetchRoute();

    if (_hasPickedUp) _startTracking();
  }

  Future<void> _fetchRoute() async {
    setState(() => _isLoadingRoute = true);

    final points = await RouteService.getBicycleRoute(
      widget.listing.pickupLocation,
      widget.listing.deliveryLocation,
    );

    setState(() {
      _routePoints = points.isEmpty
          ? [widget.listing.pickupLocation, widget.listing.deliveryLocation]
          : points;

      double routeDist = 0.0;
      for (int i = 0; i < _routePoints.length - 1; i++) {
        routeDist += LocationService.getDistanceBetween(
          _routePoints[i].latitude,
          _routePoints[i].longitude,
          _routePoints[i + 1].latitude,
          _routePoints[i + 1].longitude,
        );
      }
      _totalRouteDistanceKm = routeDist / 1000.0;

      _isLoadingRoute = false;
    });

    if (_courierPos != null) {
      _mapController.move(_courierPos!, 15.5);
    }
  }

  void _startTracking() {
    _positionStream = LocationService.getPositionStream()?.listen((
      Position position,
    ) {
      if (!mounted) return;

      final newPos = LatLng(position.latitude, position.longitude);

      if (_courierPos != null) {
        // İki nokta arası kat edilen km hesaplanarak ekleniyor
        final distKm =
            LocationService.getDistanceBetween(
              _courierPos!.latitude,
              _courierPos!.longitude,
              newPos.latitude,
              newPos.longitude,
            ) /
            1000.0;

        // 100 metreden az sıçramaları kabul et (büyük GPS sapmalarını engelle)
        if (distKm < 0.1) {
          _distanceTravelled += distKm;
        }
      }

      _courierPos = newPos;
      _posNotifier.value = _courierPos;
      _distNotifier.value = _distanceTravelled;

      // Teslimat noktasına çok yaklaştığını (örn: 50m kaldı mı?) kontrol edebiliriz
      final distToTarget = LocationService.getDistanceBetween(
        newPos.latitude,
        newPos.longitude,
        widget.listing.deliveryLocation.latitude,
        widget.listing.deliveryLocation.longitude,
      );
      _remainingDistNotifier.value = distToTarget / 1000.0;

      _mapController.move(_courierPos!, _mapController.camera.zoom);

      if (distToTarget < 50) {
        // Hedefe vardı say
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _posNotifier.dispose();
    _distNotifier.dispose();
    _remainingDistNotifier.dispose();
    super.dispose();
  }

  Future<void> _scanPickup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(
          title: 'Paketi Al',
          expectedPayload: widget.listing.qrPayload,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<CourierProvider>().confirmPickup();
      setState(() => _hasPickedUp = true);
      _startTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.darkNavy),
              SizedBox(width: 8),
              Text(
                'Paket alındı! Teslimat başladı. GPS üzerinden takip ediliyor.',
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _scanDelivery() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(
          title: 'Teslim Et',
          expectedPayload: widget.listing.deliveryQrPayload,
        ),
      ),
    );
    if (result == true && mounted) {
      _positionStream?.cancel();
      final km = _distanceTravelled > (_totalRouteDistanceKm * 0.5)
          ? _distanceTravelled
          : (_totalRouteDistanceKm > 0 ? _totalRouteDistanceKm : 1.2);
      final wallet = context.read<WalletProvider>();
      final courier = context.read<CourierProvider>();
      final merchant = context.read<MerchantProvider>();
      await courier.completeDelivery(distanceKm: km, walletProvider: wallet);
      merchant.updateListingStatus(widget.listing.id, ListingStatus.delivered);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryCompleteScreen(
              distanceKm: km,
              carbonSaved: CarbonCalculator.calculateCarbonSaved(
                km,
                weightKg: widget.listing.weightKg,
              ),
              bisPoints: CarbonCalculator.calculateBisPoints(
                km,
                weightKg: widget.listing.weightKg,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool atDestination = false;
    if (_courierPos != null) {
      final distToTarget = LocationService.getDistanceBetween(
        _courierPos!.latitude,
        _courierPos!.longitude,
        widget.listing.deliveryLocation.latitude,
        widget.listing.deliveryLocation.longitude,
      );
      atDestination =
          distToTarget < 50; // 50 metreden yakınsa hedefe vardı kabul et
    }

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        title: const Text('Aktif Teslimat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: AppTheme.errorRed),
            onPressed: () {
              context.read<CourierProvider>().cancelDelivery();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator — static, sadece _hasPickedUp veya atDestination değişince rebuild
          _DeliveryStepBar(
            hasPickedUp: _hasPickedUp,
            atDestination: atDestination,
          ),
          // Harita — ValueListenableBuilder ile sadece marker rebuild edilir
          Expanded(
            flex: 3,
            child: _isLoadingRoute
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  )
                : RepaintBoundary(
                    child: _MapSection(
                      mapController: _mapController,
                      routePoints: _routePoints,
                      posNotifier: _posNotifier,
                      listing: widget.listing,
                    ),
                  ),
          ),
          // Bottom panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sadece stats alanı ValueNotifier ile rebuild edilir
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _distNotifier,
                    _remainingDistNotifier,
                  ]),
                  builder: (ctx, _) => _LiveStats(
                    km: _distNotifier.value,
                    remainingKm: _remainingDistNotifier.value,
                    co2: CarbonCalculator.calculateCarbonSaved(
                      _distNotifier.value,
                      weightKg: widget.listing.weightKg,
                    ),
                    points: CarbonCalculator.calculateBisPoints(
                      _distNotifier.value,
                      weightKg: widget.listing.weightKg,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: !_hasPickedUp
                      ? ElevatedButton.icon(
                          onPressed: _scanPickup,
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('QR ile Paketi Al'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: atDestination ? _scanDelivery : null,
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: Text(
                            atDestination
                                ? 'QR ile Teslim Et'
                                : 'Hedefe ulaşınca teslim et...',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: atDestination
                                ? AppTheme.primaryGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Harita bölümü — kendi içinde ValueListenableBuilder kullanarak
/// sadece değişen marker'ı rebuild eder, TileLayer'ı rebuild etmez.
class _MapSection extends StatelessWidget {
  final MapController mapController;
  final List<LatLng> routePoints;
  final ValueNotifier<LatLng?> posNotifier;
  final Listing listing;

  const _MapSection({
    required this.mapController,
    required this.routePoints,
    required this.posNotifier,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: routePoints.isNotEmpty
            ? routePoints[0]
            : listing.pickupLocation,
        initialZoom: 15.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.konbis.konbis',
          keepBuffer: 2,
          maxZoom: 18,
          tileDimension: 256,
        ),
        // Çizilen Rota
        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: AppTheme.primaryGreen,
                strokeWidth: 5,
              ),
            ],
          ),

        // Statik markerlar (pickup & delivery)
        MarkerLayer(
          markers: [
            Marker(
              point: listing.pickupLocation,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            Marker(
              point: listing.deliveryLocation,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        // Kurye marker - GPS ile hareket eder
        ValueListenableBuilder<LatLng?>(
          valueListenable: posNotifier,
          builder: (ctx, pos, p2) {
            if (pos == null) return const SizedBox.shrink();
            return MarkerLayer(
              markers: [
                Marker(
                  point: pos,
                  width: 52,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkNavy,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryGreen,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_bike_rounded,
                      color: AppTheme.primaryGreen,
                      size: 26,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DeliveryStepBar extends StatelessWidget {
  final bool hasPickedUp;
  final bool atDestination;
  const _DeliveryStepBar({
    required this.hasPickedUp,
    required this.atDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Step(
            label: 'Al',
            done: hasPickedUp,
            active: !hasPickedUp,
            color: AppTheme.accentOrange,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: hasPickedUp ? AppTheme.primaryGreen : AppTheme.cardDarker,
            ),
          ),
          _Step(
            label: 'Götür',
            done: atDestination && hasPickedUp,
            active: hasPickedUp,
            color: AppTheme.primaryGreen,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: atDestination
                  ? AppTheme.primaryGreen
                  : AppTheme.cardDarker,
            ),
          ),
          _Step(
            label: 'Teslim',
            done: false,
            active: atDestination && hasPickedUp,
            color: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool done, active;
  final Color color;
  const _Step({
    required this.label,
    required this.done,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? color
                : active
                ? color.withValues(alpha: 0.2)
                : AppTheme.cardDarker,
            border: Border.all(
              color: active || done ? color : AppTheme.textSecondary,
              width: 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : active
              ? Icon(Icons.circle, color: color, size: 10)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active || done ? color : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LiveStats extends StatelessWidget {
  final double km, remainingKm, co2, points;
  const _LiveStats({
    required this.km,
    required this.remainingKm,
    required this.co2,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MiniStat(
          value: km.toStringAsFixed(2),
          unit: 'km',
          label: 'Gidilen',
          color: AppTheme.accentBlue,
        ),
        _MiniStat(
          value: remainingKm.toStringAsFixed(2),
          unit: 'km',
          label: 'Kalan',
          color: AppTheme.accentOrange,
        ),
        _MiniStat(
          value: CarbonCalculator.formatCo2(co2),
          unit: '',
          label: 'CO₂',
          color: AppTheme.primaryGreen,
        ),
        _MiniStat(
          value: points.toStringAsFixed(0),
          unit: 'puan',
          label: 'BiS',
          color: AppTheme.warning,
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, unit, label;
  final Color color;
  const _MiniStat({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
