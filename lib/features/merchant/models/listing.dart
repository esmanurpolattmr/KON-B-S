import 'package:latlong2/latlong.dart';

enum ListingStatus { open, assigned, delivered, cancelled }

class Listing {
  final String id;
  final String merchantId;
  final String merchantName;
  final String title;
  final String description;
  final double weightKg;
  final String pickupAddress;
  final String deliveryAddress;
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final String timeWindowStart;
  final String timeWindowEnd;
  final ListingStatus status;
  final String? assignedCourierId;
  final DateTime createdAt;
  final String qrToken; // güvenlik tokeni

  const Listing({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.title,
    required this.description,
    required this.weightKg,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.timeWindowStart,
    required this.timeWindowEnd,
    required this.status,
    required this.createdAt,
    required this.qrToken,
    this.assignedCourierId,
  });

  Listing copyWith({ListingStatus? status, String? assignedCourierId}) {
    return Listing(
      id: id,
      merchantId: merchantId,
      merchantName: merchantName,
      title: title,
      description: description,
      weightKg: weightKg,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      pickupLocation: pickupLocation,
      deliveryLocation: deliveryLocation,
      timeWindowStart: timeWindowStart,
      timeWindowEnd: timeWindowEnd,
      status: status ?? this.status,
      createdAt: createdAt,
      qrToken: qrToken,
      assignedCourierId: assignedCourierId ?? this.assignedCourierId,
    );
  }

  String get statusLabel {
    switch (status) {
      case ListingStatus.open:
        return 'Açık';
      case ListingStatus.assigned:
        return 'Atandı';
      case ListingStatus.delivered:
        return 'Teslim Edildi';
      case ListingStatus.cancelled:
        return 'İptal';
    }
  }

  String get qrPayload => '{"id":"$id","token":"$qrToken","type":"pickup"}';
  String get deliveryQrPayload =>
      '{"id":"$id","token":"$qrToken","type":"delivery"}';
}
