import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/carbon_calculator.dart';
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
  // Simulated route - Kadıköy İstanbul waypoints
  static final List<LatLng> _routePoints = [
    const LatLng(40.9849, 29.0270),
    const LatLng(40.9855, 29.0260),
    const LatLng(40.9862, 29.0248),
    const LatLng(40.9870, 29.0237),
    const LatLng(40.9875, 29.0232),
    const LatLng(40.9880, 29.0228),
    const LatLng(40.9885, 29.0225),
    const LatLng(40.9889, 29.0222),
    const LatLng(40.9893, 29.0220),
    const LatLng(40.9898, 29.0219),
    const LatLng(40.9901, 29.0218),
  ];

  int _currentStep = 0;
  LatLng _courierPos = _routePoints[0];
  double _distanceTravelled = 0.0;
  Timer? _moveTimer;
  final MapController _mapController = MapController();
  bool _hasPickedUp = false;

  // ValueNotifiers — sadece ilgili widget'ı rebuild eder, tüm sayfayı değil
  final ValueNotifier<LatLng> _posNotifier = ValueNotifier(_routePoints[0]);
  final ValueNotifier<double> _distNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> _stepNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _hasPickedUp = context.read<CourierProvider>().hasPickedUp;
    if (_hasPickedUp) _startMoving();
  }

  void _startMoving() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStep < _routePoints.length - 1) {
        final prev = _routePoints[_currentStep];
        _currentStep++;
        final next = _routePoints[_currentStep];
        const dist = Distance();
        _distanceTravelled += dist.as(LengthUnit.Kilometer, prev, next);
        _courierPos = next;
        // ValueNotifier üzerinden güncelle — setState yok, tam ekran rebuild yok
        _posNotifier.value = next;
        _distNotifier.value = _distanceTravelled;
        _stepNotifier.value = _currentStep;
        try {
          _mapController.move(_courierPos, 15.5);
        } catch (_) {}
      } else {
        timer.cancel();
        // Sadece "atDestination" durumu için setState — tek seferlik
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _posNotifier.dispose();
    _distNotifier.dispose();
    _stepNotifier.dispose();
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
      _startMoving();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.darkNavy),
              SizedBox(width: 8),
              Text('Paket alındı! Teslimat başladı.'),
            ],
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      _moveTimer?.cancel();
      final km = _distanceTravelled < 0.01 ? 1.2 : _distanceTravelled;
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
              carbonSaved: CarbonCalculator.calculateCarbonSaved(km),
              bisPoints: CarbonCalculator.calculateBisPoints(km),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final atDestination = _currentStep >= _routePoints.length - 1;

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
            child: RepaintBoundary(
              child: _MapSection(
                mapController: _mapController,
                routePoints: _routePoints,
                posNotifier: _posNotifier,
                stepNotifier: _stepNotifier,
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
                ValueListenableBuilder<double>(
                  valueListenable: _distNotifier,
                  builder: (_, km, __) => _LiveStats(
                    km: km,
                    co2: CarbonCalculator.calculateCarbonSaved(km),
                    points: CarbonCalculator.calculateBisPoints(km),
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
  final ValueNotifier<LatLng> posNotifier;
  final ValueNotifier<int> stepNotifier;

  const _MapSection({
    required this.mapController,
    required this.routePoints,
    required this.posNotifier,
    required this.stepNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: routePoints[0],
        initialZoom: 15.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.konbis.konbis',
          keepBuffer: 2,
          maxZoom: 18,
          tileSize: 256,
        ),
        // Polyline — sadece step değişince rebuild
        ValueListenableBuilder<int>(
          valueListenable: stepNotifier,
          builder: (_, step, __) => PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                strokeWidth: 4,
              ),
              Polyline(
                points: routePoints.sublist(0, step + 1),
                color: AppTheme.primaryGreen,
                strokeWidth: 5,
              ),
            ],
          ),
        ),
        // Statik markerlar (pickup & delivery) — hiç rebuild olmaz
        MarkerLayer(
          markers: [
            Marker(
              point: routePoints.first,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.store_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            Marker(
              point: routePoints.last,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.flag_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        // Kurye marker — sadece pozisyon değişince rebuild
        ValueListenableBuilder<LatLng>(
          valueListenable: posNotifier,
          builder: (_, pos, __) => MarkerLayer(
            markers: [
              Marker(
                point: pos,
                width: 52,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGreen, width: 3),
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
          ),
        ),
      ],
    );
  }
}

class _DeliveryStepBar extends StatelessWidget {
  final bool hasPickedUp;
  final bool atDestination;
  const _DeliveryStepBar(
      {required this.hasPickedUp, required this.atDestination});

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
              color: AppTheme.accentOrange),
          Expanded(
              child: Container(
                  height: 2,
                  color: hasPickedUp
                      ? AppTheme.primaryGreen
                      : AppTheme.cardDarker)),
          _Step(
              label: 'Götür',
              done: atDestination && hasPickedUp,
              active: hasPickedUp,
              color: AppTheme.primaryGreen),
          Expanded(
              child: Container(
                  height: 2,
                  color: atDestination
                      ? AppTheme.primaryGreen
                      : AppTheme.cardDarker)),
          _Step(
              label: 'Teslim',
              done: false,
              active: atDestination && hasPickedUp,
              color: AppTheme.accentBlue),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool done, active;
  final Color color;
  const _Step(
      {required this.label,
      required this.done,
      required this.active,
      required this.color});

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
                width: 2),
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
  final double km, co2, points;
  const _LiveStats({required this.km, required this.co2, required this.points});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MiniStat(
            value: km.toStringAsFixed(2),
            unit: 'km',
            label: 'Mesafe',
            color: AppTheme.accentBlue),
        _MiniStat(
            value: CarbonCalculator.formatCo2(co2),
            unit: '',
            label: 'CO₂ Tasarruf',
            color: AppTheme.primaryGreen),
        _MiniStat(
            value: points.toStringAsFixed(0),
            unit: 'puan',
            label: 'BiS',
            color: AppTheme.warning),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, unit, label;
  final Color color;
  const _MiniStat(
      {required this.value,
      required this.unit,
      required this.label,
      required this.color});

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
                    color: color, fontWeight: FontWeight.w800, fontSize: 18),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                        color: color.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        ),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}
