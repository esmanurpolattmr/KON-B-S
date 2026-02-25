import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/listing.dart';

const _uuid = Uuid();

// Demo başlangıç verileri - İstanbul Kadıköy bölgesi
final List<Listing> _demoListings = [
  Listing(
    id: 'listing-001',
    merchantId: 'merchant-001',
    merchantName: 'Karadeniz Fırını',
    title: 'Taze Ekmek & Pasta',
    description: '3 adet çavdar ekmeği ve 1 kutu sütlaç. Dikkatli taşıyınız.',
    weightKg: 2.5,
    pickupAddress: 'Moda Cad. No:12, Kadıköy',
    deliveryAddress: 'Bahariye Cad. No:45, Kadıköy',
    pickupLocation: const LatLng(40.9849, 29.0270),
    deliveryLocation: const LatLng(40.9901, 29.0218),
    timeWindowStart: '09:00',
    timeWindowEnd: '11:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    qrToken: 'tok-firin-001',
  ),
  Listing(
    id: 'listing-002',
    merchantId: 'merchant-002',
    merchantName: 'Çiçekçi Gülistan',
    title: 'Doğum Günü Çiçeği',
    description: 'Kırmızı gül buketi. Serin tutunuz, dikey taşıyınız.',
    weightKg: 0.8,
    pickupAddress: 'Söğütlüçeşme Cad. No:7, Kadıköy',
    deliveryAddress: 'Fenerbahçe Mah. No:22, Kadıköy',
    pickupLocation: const LatLng(40.9780, 29.0310),
    deliveryLocation: const LatLng(40.9710, 29.0380),
    timeWindowStart: '10:00',
    timeWindowEnd: '13:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    qrToken: 'tok-cicek-002',
  ),
  Listing(
    id: 'listing-003',
    merchantId: 'merchant-003',
    merchantName: 'Eczane Şifa',
    title: 'İlaç Paketi',
    description: 'Reçeteli ilaçlar. Kimlik kontrolü gerekebilir.',
    weightKg: 0.5,
    pickupAddress: 'Rıhtım Cad. No:3, Kadıköy',
    deliveryAddress: 'Acıbadem Mah. No:88, Kadıköy',
    pickupLocation: const LatLng(40.9920, 29.0250),
    deliveryLocation: const LatLng(40.9950, 29.0430),
    timeWindowStart: '11:00',
    timeWindowEnd: '14:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    qrToken: 'tok-eczane-003',
  ),
];

class MerchantProvider extends ChangeNotifier {
  final List<Listing> _listings = List.from(_demoListings);

  List<Listing> get listings => List.unmodifiable(_listings);

  List<Listing> get openListings =>
      _listings.where((l) => l.status == ListingStatus.open).toList();

  void addListing({
    required String title,
    required String description,
    required double weightKg,
    required String pickupAddress,
    required String deliveryAddress,
    required LatLng pickupLocation,
    required LatLng deliveryLocation,
    required String timeStart,
    required String timeEnd,
  }) {
    final listing = Listing(
      id: _uuid.v4(),
      merchantId: 'merchant-current',
      merchantName: 'Benim Dükkanım',
      title: title,
      description: description,
      weightKg: weightKg,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      timeWindowStart: timeStart,
      timeWindowEnd: timeEnd,
      status: ListingStatus.open,
      createdAt: DateTime.now(),
      qrToken: _uuid.v4().substring(0, 8),
    );
    _listings.insert(0, listing);
    notifyListeners();
  }

  void updateListingStatus(
    String id,
    ListingStatus status, {
    String? courierId,
  }) {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _listings[idx] = _listings[idx].copyWith(
        status: status,
        assignedCourierId: courierId,
      );
      notifyListeners();
    }
  }

  Listing? findById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
