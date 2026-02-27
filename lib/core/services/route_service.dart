import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  /// OSRM public API kullanarak iki nokta arası bisiklet rotasını asenkron olarak çeker.
  /// Not: OSRM koordinat formatı [Boylam, Enlem] şeklindedir (Lon, Lat).
  static Future<List<LatLng>> getBicycleRoute(LatLng start, LatLng end) async {
    // Profil: bicycle (bisiklet) - steps: false - geometries: polyline6 (default polyline5 ama dart latlong2 polyline okuması için en ideali geojson veya polyline)
    // Biz 'geojson' isteyerek kolay parse edilebilir koordinat dizisi alacağız.
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/bicycle/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          // OSRM GeoJSON koordinatları [lon, lat] olarak döner. LatLng'ye çevirirken [lat, lon] alacağız.
          return coordinates.map((c) => LatLng(c[1], c[0])).toList();
        }
      }
      return []; // Hata durumunda boş liste dön
    } catch (e) {
      print('RouteService Error: $e');
      return [];
    }
  }
}
