import 'package:geolocator/geolocator.dart';

import 'Loc.dart';

Future<Map<String, dynamic>> getUserLocation() async {
  Location? userLocation = new Location();
  Map<String, dynamic> locationMap = new Map();
  LocationPermission hasLocationPermission = await GeolocatorPlatform.instance.checkPermission();

  if (hasLocationPermission == LocationPermission.always ||
      hasLocationPermission == LocationPermission.whileInUse) {
    try {
      Position location = await GeolocatorPlatform.instance.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 20));
      if (location != null) {
        userLocation = new Location();
        userLocation.latitude = location.latitude;
        userLocation.longitude = location.longitude;
      } else {
        userLocation = null;
      }
    } catch (err) {
      userLocation = null;
    }
  } else {
    hasLocationPermission = await GeolocatorPlatform.instance.requestPermission();

    if (hasLocationPermission == LocationPermission.whileInUse ||
        hasLocationPermission == LocationPermission.always) {
      try {
        Position location = await GeolocatorPlatform.instance.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 20));
        if (location != null) {
          userLocation = new Location();
          userLocation.latitude = location.latitude;
          userLocation.longitude = location.longitude;
        } else {
          userLocation = null;
        }
      } catch (err) {
        userLocation = null;
      }
    } else {
      userLocation = null;
    }
  }
  locationMap["location"] = userLocation;
  locationMap["status"] = hasLocationPermission;
  return locationMap;
}