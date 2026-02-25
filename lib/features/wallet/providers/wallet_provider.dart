import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/bis_transaction.dart';
import '../../../core/utils/carbon_calculator.dart';

const _uuid = Uuid();

class WalletProvider extends ChangeNotifier {
  final List<BisTransaction> _transactions = [];
  double _totalBisPoints = 0.0;
  double _totalCo2Saved = 0.0;
  double _totalKm = 0.0;

  List<BisTransaction> get transactions =>
      List.unmodifiable(_transactions.reversed.toList());
  double get totalBisPoints => _totalBisPoints;
  double get totalCo2Saved => _totalCo2Saved;
  double get totalKm => _totalKm;

  Future<void> addDelivery({
    required String listingId,
    required String deliveryTitle,
    required double distanceKm,
  }) async {
    final co2 = CarbonCalculator.calculateCarbonSaved(distanceKm);
    final points = CarbonCalculator.calculateBisPoints(distanceKm);

    final tx = BisTransaction(
      id: _uuid.v4(),
      listingId: listingId,
      deliveryTitle: deliveryTitle,
      distanceKm: distanceKm,
      co2SavedKg: co2,
      bisPoints: points,
      completedAt: DateTime.now(),
    );

    _transactions.add(tx);
    _totalBisPoints += points;
    _totalCo2Saved += co2;
    _totalKm += distanceKm;
    notifyListeners();
  }
}
