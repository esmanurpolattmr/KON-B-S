import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/listing.dart';

const _uuid = Uuid();

// Demo başlangıç verileri - Konya bölgesi
final List<Listing> _demoListings = [
  Listing(
    id: 'listing-001',
    merchantId: 'merchant-001',
    merchantName: 'Konya Fırını',
    title: 'Taze Ekmek & Simid',
    description:
        '5 adet kepekli ekmek ve 1 kutu pişmaniye. Dikkatli taşıyınız.',
    weightKg: 2.5,
    pickupAddress: 'Alaeddin Cad. No:12, Selçuklu',
    deliveryAddress: 'Nalçacı Cad. No:45, Selçuklu',
    pickupLocation: const LatLng(37.8713, 32.4846),
    deliveryLocation: const LatLng(37.8780, 32.4920),
    timeWindowStart: '09:00',
    timeWindowEnd: '11:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    qrToken: 'tok-firin-001',
  ),
  Listing(
    id: 'listing-002',
    merchantId: 'merchant-002',
    merchantName: 'Çiçekçi Gonca',
    title: 'Doğum Günü Çiçeği',
    description: 'Konya lalesi buketi. Serin tutunuz, dikey taşıyınız.',
    weightKg: 0.8,
    pickupAddress: 'Meram Yeni Yol No:7, Meram',
    deliveryAddress: 'Arif Hatun Mah. No:22, Meram',
    pickupLocation: const LatLng(37.8620, 32.4750),
    deliveryLocation: const LatLng(37.8550, 32.4680),
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
    pickupAddress: 'Aziziye Cad. No:3, Karatay',
    deliveryAddress: 'Fevzi Çakmak Mah. No:88, Karatay',
    pickupLocation: const LatLng(37.8760, 32.4960),
    deliveryLocation: const LatLng(37.8820, 32.5050),
    timeWindowStart: '11:00',
    timeWindowEnd: '14:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    qrToken: 'tok-eczane-003',
  ),
  Listing(
    id: 'listing-004',
    merchantId: 'merchant-004',
    merchantName: 'Meram Şelale Restoran',
    title: 'Büyük İftar Menüsü',
    description:
        '4 kişilik iftar menüsü, tatlılar ve içecekler dahil. Lütfen dökmeden taşıyınız.',
    weightKg: 4.5,
    pickupAddress: 'Yaka Mah. Şelale Sok. No:1, Meram',
    deliveryAddress: 'Yazır Mah. Barış Cad. No:120, Selçuklu',
    pickupLocation: const LatLng(37.8500, 32.4500),
    deliveryLocation: const LatLng(37.9300, 32.5100),
    timeWindowStart: '17:00',
    timeWindowEnd: '19:00',
    status: ListingStatus.open,
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    qrToken: 'tok-rest-004',
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
