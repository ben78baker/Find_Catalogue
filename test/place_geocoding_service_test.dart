import 'package:find_catalogue/services/place_geocoding_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'Nominatim search encodes the query and parses the first result',
    () async {
      late http.Request request;
      var requestCount = 0;
      final service = NominatimPlaceGeocodingService(
        client: MockClient((incoming) async {
          requestCount++;
          request = incoming;
          return http.Response(
            '[{"lat":"50.103","lon":"-5.390","display_name":"Praa Sands, Cornwall"}]',
            200,
          );
        }),
      );

      final result = await service.search('TR20 9TQ');
      final cachedResult = await service.search('tr20 9tq');

      expect(request.url.host, 'nominatim.openstreetmap.org');
      expect(request.url.path, '/search');
      expect(request.url.queryParameters['q'], 'TR20 9TQ');
      expect(request.url.queryParameters['limit'], '1');
      expect(request.headers['User-Agent'], contains('FindCatalogue'));
      expect(result.latitude, 50.103);
      expect(result.longitude, -5.390);
      expect(result.displayName, 'Praa Sands, Cornwall');
      expect(cachedResult.latitude, result.latitude);
      expect(requestCount, 1);
    },
  );

  test('Nominatim search reports an empty result cleanly', () async {
    final service = NominatimPlaceGeocodingService(
      client: MockClient((_) async => http.Response('[]', 200)),
    );

    final result = await service.search('No such place');

    expect(result.found, isFalse);
    expect(result.message, 'No matching place was found.');
  });

  test('Nominatim search reports service errors cleanly', () async {
    final service = NominatimPlaceGeocodingService(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );

    final result = await service.search('Service error test');

    expect(result.found, isFalse);
    expect(
      result.message,
      'Place search is unavailable right now. Try again later.',
    );
  });
}
