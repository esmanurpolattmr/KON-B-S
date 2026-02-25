import 'package:flutter/material.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../merchant/models/listing.dart';

class CourierProvider extends ChangeNotifier {
  Listing? _activeDelivery;
  bool _hasPickedUp = false;
  double _distanceTravelled = 0.0;

  Listing? get activeDelivery => _activeDelivery;
  bool get hasPickedUp => _hasPickedUp;
  double get distanceTravelled => _distanceTravelled;
  bool get isDelivering => _activeDelivery != null;

  void acceptDelivery(Listing listing) {
    _activeDelivery = listing;
    _hasPickedUp = false;
    _distanceTravelled = 0.0;
    notifyListeners();
  }

  void confirmPickup() {
    _hasPickedUp = true;
    notifyListeners();
  }

  Future<void> completeDelivery({
    required double distanceKm,
    required WalletProvider walletProvider,
  }) async {
    if (_activeDelivery == null) return;
    _distanceTravelled = distanceKm;
    await walletProvider.addDelivery(
      listingId: _activeDelivery!.id,
      deliveryTitle: _activeDelivery!.title,
      distanceKm: distanceKm,
    );
    _activeDelivery = null;
    _hasPickedUp = false;
    _distanceTravelled = 0.0;
    notifyListeners();
  }

  void cancelDelivery() {
    _activeDelivery = null;
    _hasPickedUp = false;
    _distanceTravelled = 0.0;
    notifyListeners();
  }
}
