class BisTransaction {
  final String id;
  final String listingId;
  final String deliveryTitle;
  final double distanceKm;
  final double co2SavedKg;
  final double bisPoints;
  final DateTime completedAt;

  const BisTransaction({
    required this.id,
    required this.listingId,
    required this.deliveryTitle,
    required this.distanceKm,
    required this.co2SavedKg,
    required this.bisPoints,
    required this.completedAt,
  });
}
