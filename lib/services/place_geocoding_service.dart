import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaceSearchResult {
  const PlaceSearchResult({
    this.latitude,
    this.longitude,
    this.displayName,
    this.message,
  });

  final double? latitude;
  final double? longitude;
  final String? displayName;
  final String? message;

  bool get found => latitude != null && longitude != null;
}

abstract interface class PlaceGeocodingService {
  Future<PlaceSearchResult> search(String query);
}

class NominatimPlaceGeocodingService implements PlaceGeocodingService {
  NominatimPlaceGeocodingService({http.Client? client})
    : _client = client ?? http.Client();

  static const _userAgent =
      'FindCatalogue/1.0 (com.ingeneralapps.findCatalogue; '
      'https://ben78baker.github.io/find-catalogue-privacy-policy/find-catalogue-support/)';
  static const _minimumRequestInterval = Duration(seconds: 1);
  static DateTime? _lastRequestAt;
  static Future<void> _requestGate = Future<void>.value();
  static final Map<String, PlaceSearchResult> _cache = {};

  final http.Client _client;

  @override
  Future<PlaceSearchResult> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const PlaceSearchResult(message: 'Enter a place or address.');
    }
    final cacheKey = trimmed.toLowerCase();
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final turn = _requestGate.then((_) async {
      final previousRequest = _lastRequestAt;
      if (previousRequest != null) {
        final wait =
            _minimumRequestInterval -
            DateTime.now().difference(previousRequest);
        if (!wait.isNegative) await Future<void>.delayed(wait);
      }
      _lastRequestAt = DateTime.now();
    });
    _requestGate = turn;
    await turn;

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': trimmed,
        'format': 'jsonv2',
        'limit': '1',
      });
      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent': _userAgent,
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const PlaceSearchResult(
          message: 'Place search is unavailable right now. Try again later.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
        const result = PlaceSearchResult(
          message: 'No matching place was found.',
        );
        _cache[cacheKey] = result;
        return result;
      }
      final item = Map<String, dynamic>.from(decoded.first as Map);
      final latitude = double.tryParse(item['lat']?.toString() ?? '');
      final longitude = double.tryParse(item['lon']?.toString() ?? '');
      if (latitude == null ||
          longitude == null ||
          !latitude.isFinite ||
          !longitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        return const PlaceSearchResult(
          message: 'The place search returned an invalid location.',
        );
      }
      final result = PlaceSearchResult(
        latitude: latitude,
        longitude: longitude,
        displayName: item['display_name']?.toString(),
      );
      _cache[cacheKey] = result;
      return result;
    } on TimeoutException {
      return const PlaceSearchResult(
        message: 'Place search timed out. Check your connection and try again.',
      );
    } catch (_) {
      return const PlaceSearchResult(
        message: 'Place search failed. Check your connection and try again.',
      );
    }
  }
}
