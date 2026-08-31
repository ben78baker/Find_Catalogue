import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/find_record.dart';

class LocationCaptureResult {
  const LocationCaptureResult({this.location, this.message});

  final FindLocation? location;
  final String? message;

  bool get hasLocation => location != null;
}

abstract interface class LocationCaptureService {
  Future<LocationCaptureResult> captureCurrentLocation();
}

class DeviceLocationCaptureService implements LocationCaptureService {
  @override
  Future<LocationCaptureResult> captureCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationCaptureResult(
          message:
              'Location services are switched off. You can save now and add a location manually later.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationCaptureResult(
          message:
              'Location permission was not granted. The record can still be saved without coordinates.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationCaptureResult(
        location: FindLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          horizontalAccuracy: position.accuracy,
          altitude: position.altitude,
          source: FieldSource.deviceCaptured,
        ),
      );
    } on TimeoutException {
      return const LocationCaptureResult(
        message:
            'A precise location was not available in time. You can retry or save without it.',
      );
    } catch (_) {
      return const LocationCaptureResult(
        message:
            'The location could not be captured. You can retry or enter it manually.',
      );
    }
  }
}
