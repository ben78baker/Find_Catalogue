import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/find_record.dart';

class LocationCaptureResult {
  const LocationCaptureResult({this.location, this.message});

  final FindLocation? location;
  final String? message;

  bool get hasLocation => location != null;
}

abstract interface class LocationCaptureSession {
  Stream<LocationCaptureResult> get updates;
  LocationCaptureResult? get bestResult;
  Future<LocationCaptureResult> get completed;
  Future<void> cancel();
}

abstract interface class LocationCaptureService {
  LocationCaptureSession startLocationCapture();
  Future<LocationCaptureResult> captureCurrentLocation();
}

class DeviceLocationCaptureService implements LocationCaptureService {
  @override
  LocationCaptureSession startLocationCapture() =>
      _DeviceLocationCaptureSession();

  @override
  Future<LocationCaptureResult> captureCurrentLocation() async {
    final session = startLocationCapture();
    try {
      return await session.completed;
    } finally {
      await session.cancel();
    }
  }
}

class _DeviceLocationCaptureSession implements LocationCaptureSession {
  _DeviceLocationCaptureSession() {
    unawaited(_start());
  }

  static const _excellentAccuracyMetres = 10.0;
  static const _maximumFixAge = Duration(seconds: 10);
  static const _timeLimit = Duration(seconds: 15);

  final _updates = StreamController<LocationCaptureResult>.broadcast();
  final _completed = Completer<LocationCaptureResult>();
  StreamSubscription<Position>? _subscription;
  Timer? _timer;
  LocationCaptureResult? _bestResult;
  bool _cancelled = false;

  @override
  Stream<LocationCaptureResult> get updates => _updates.stream;

  @override
  LocationCaptureResult? get bestResult => _bestResult;

  @override
  Future<LocationCaptureResult> get completed => _completed.future;

  Future<void> _start() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _finish(
          const LocationCaptureResult(
            message:
                'Location services are switched off. You can save now and add a location manually later.',
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _finish(
          const LocationCaptureResult(
            message:
                'Location permission was not granted. The record can still be saved without coordinates.',
          ),
        );
        return;
      }

      final precision = await Geolocator.getLocationAccuracy();
      final precisionMessage = precision == LocationAccuracyStatus.reduced
          ? 'Precise Location is off. Confirm the proposed point carefully or enable it in Settings.'
          : null;

      _timer = Timer(_timeLimit, () {
        _finish(
          _bestResult ??
              const LocationCaptureResult(
                message:
                    'A location was not available in time. You can retry, choose a point on the map, or skip it.',
              ),
        );
      });
      _subscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 0,
            ),
          ).listen(
            (position) => _consider(position, precisionMessage),
            onError: (_) => _finish(
              _bestResult ??
                  const LocationCaptureResult(
                    message:
                        'The location could not be captured. You can retry, choose it manually, or skip it.',
                  ),
            ),
          );
    } catch (_) {
      _finish(
        _bestResult ??
            const LocationCaptureResult(
              message:
                  'The location could not be captured. You can retry, choose it manually, or skip it.',
            ),
      );
    }
  }

  void _consider(Position position, String? precisionMessage) {
    if (_cancelled ||
        !position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude < -90 ||
        position.latitude > 90 ||
        position.longitude < -180 ||
        position.longitude > 180 ||
        !position.accuracy.isFinite ||
        position.accuracy <= 0) {
      return;
    }
    if (DateTime.now().difference(position.timestamp).abs() > _maximumFixAge) {
      return;
    }
    final currentAccuracy = _bestResult?.location?.horizontalAccuracy;
    if (currentAccuracy != null && currentAccuracy <= position.accuracy) return;

    final result = LocationCaptureResult(
      location: FindLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        horizontalAccuracy: position.accuracy,
        altitude: position.altitude,
        source: FieldSource.deviceCaptured,
      ),
      message: precisionMessage,
    );
    _bestResult = result;
    if (!_updates.isClosed) _updates.add(result);
    if (position.accuracy <= _excellentAccuracyMetres) _finish(result);
  }

  void _finish(LocationCaptureResult result) {
    if (_cancelled || _completed.isCompleted) return;
    _bestResult ??= result;
    _completed.complete(_bestResult!);
    _timer?.cancel();
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  @override
  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    _timer?.cancel();
    await _subscription?.cancel();
    if (!_completed.isCompleted) {
      _completed.complete(
        _bestResult ??
            const LocationCaptureResult(message: 'Location capture cancelled.'),
      );
    }
    await _updates.close();
  }
}
