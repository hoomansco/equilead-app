import 'dart:math' as math;

class LocationService {
  bool isWithinDiameter(
      double lat1, double lon1, double lat2, double lon2, double radius) {
    const earthRadius = 6371000; // Earth's radius in meters

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = earthRadius * c;

    return distance <= radius;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
