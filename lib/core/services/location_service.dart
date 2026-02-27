import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Konum izinlerini kontrol eder ve ister.
  static Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// Tek seferlik mevcut konumu döndürür.
  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Kullanıcıdan GPS'i açmasını isteyebiliriz.
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  /// Konum değişikliklerini dinlemek için Stream döndürür.
  static Stream<Position>? getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter:
            3, // Her 3 metrede bir güncelle (gereksiz rebuild'i önler)
      ),
    );
  }

  /// İki konum arasındaki mesafeyi metre cinsinden hesaplar.
  static double getDistanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }
}
