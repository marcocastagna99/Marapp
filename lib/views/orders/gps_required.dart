import 'package:geolocator/geolocator.dart';

Future<bool> handleLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return false; // Permessi negati permanentemente
    }
  }
  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}

Future<Position?> getCurrentLocation() async {
  bool hasPermission = await handleLocationPermission();
  if (!hasPermission) return null;

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}
