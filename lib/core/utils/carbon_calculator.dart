/// Bisiklet kullanımının karbon tasarrufunu hesaplar.
/// Referans: Ortalama araç CO₂ emisyonu ~0.21 kg/km (Türkiye ortalaması)
class CarbonCalculator {
  static const double _co2PerKmByCar = 0.210; // kg CO₂ per km
  static const double _bisPointsPerKm = 10.0;

  /// km başına kurtarılan CO₂ (kg)
  static double calculateCarbonSaved(double distanceKm) {
    return distanceKm * _co2PerKmByCar;
  }

  /// kazanılan BiS puanı
  static double calculateBisPoints(double distanceKm) {
    return distanceKm * _bisPointsPerKm;
  }

  /// CO₂ değerini okunabilir formata çevirir
  static String formatCo2(double kg) {
    if (kg >= 1.0) return '${kg.toStringAsFixed(2)} kg CO₂';
    return '${(kg * 1000).toStringAsFixed(0)} g CO₂';
  }

  /// Ağaçla eşdeğer (1 ağaç yılda ~21 kg CO₂ emer)
  static String treeEquivalent(double kg) {
    final trees = kg / 21.0;
    if (trees < 0.01) {
      return '${(kg * 1000).toStringAsFixed(0)} g CO₂ tasarrufu';
    }
    return '${trees.toStringAsFixed(3)} ağacın 1 yıllık etkisi';
  }
}
