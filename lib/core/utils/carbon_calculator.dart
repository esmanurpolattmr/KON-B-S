/// Bisiklet kullanımının karbon tasarrufunu hesaplar.
/// Referans: Şehir içi ortalama motorlu kurye CO₂ emisyonu ~0.150 kg/km
class CarbonCalculator {
  static const double _co2PerKmByMotor = 0.150; // kg CO₂ per km

  /// Taşınan yüke göre Zorluk/Efor katsayısı
  /// 1 KG'ye kadar katsayı 1.0 (Standart)
  /// 1 KG üzeri her 1 KG için ekstra +0.2 katsayı eklenir.
  static double _getWeightMultiplier(double weightKg) {
    if (weightKg <= 1.0) return 1.0;
    final extraWeight = weightKg - 1.0;
    return 1.0 + (extraWeight * 0.2);
  }

  /// km başına kurtarılan CO₂ (kg) (Yük ağırlığı da hesaba katılarak)
  static double calculateCarbonSaved(
    double distanceKm, {
    double weightKg = 0.0,
  }) {
    final multiplier = _getWeightMultiplier(weightKg);
    return distanceKm * _co2PerKmByMotor * multiplier;
  }

  /// Doğaya Katkı (BiS) Puanı
  /// Her 1 kg CO₂ tasarrufu = 100 BiS Puanı
  static double calculateBisPoints(double distanceKm, {double weightKg = 0.0}) {
    final carbonSaved = calculateCarbonSaved(distanceKm, weightKg: weightKg);
    return carbonSaved * 100.0;
  }

  /// CO₂ değerini okunabilir formata çevirir (g veya kg)
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
