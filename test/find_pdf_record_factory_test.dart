import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_pdf_record_factory.dart';
import 'package:find_catalogue/services/sharing/findspot_export_precision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const factory = FindPdfRecordFactory();

  test('hidden presentation contains no precise location data', () {
    final data = factory.create(
      _record(),
      findspotPrecision: FindspotExportPrecision.hidden,
    );
    final presented = [
      ...data.summaryFields,
      ...data.fullFields,
    ].map((field) => '${field.label}: ${field.value}').join('\n');

    expect(presented, contains('Findspot: Not shared'));
    expect(presented, isNot(contains('51.123456')));
    expect(presented, isNot(contains('-1.234567')));
    expect(presented, isNot(contains('Location accuracy')));
    expect(presented, isNot(contains('Location source')));
  });

  test('exact presentation includes the chosen findspot details', () {
    final data = factory.create(
      _record(),
      findspotPrecision: FindspotExportPrecision.exact,
    );
    final fields = {
      for (final field in data.fullFields) field.label: field.value,
    };

    expect(fields['Findspot'], '51.123456, -1.234567');
    expect(fields['Location accuracy'], '+/-4.2 m');
    expect(fields['Altitude'], '83.5 m');
    expect(fields['Location source'], 'Device Captured');
  });

  test('summary is concise and optional fields are omitted', () {
    final data = factory.create(
      _record(
        material: '',
        confidence: IdentificationConfidence.unassessed,
        observations: '',
        noMeasurements: true,
      ),
      findspotPrecision: FindspotExportPrecision.hidden,
    );
    final labels = data.summaryFields.map((field) => field.label);

    expect(labels, isNot(contains('Material')));
    expect(labels, isNot(contains('Confidence')));
    expect(labels, isNot(contains('Measurements')));
    expect(labels, isNot(contains('Weight')));
    expect(data.summaryObservations, isNull);
  });

  test('summary excerpt and measurements use application conventions', () {
    final data = factory.create(
      _record(observations: List.filled(100, 'detail').join(' ')),
      findspotPrecision: FindspotExportPrecision.hidden,
    );
    final fields = {
      for (final field in data.summaryFields) field.label: field.value,
    };

    expect(fields['Measurements'], 'L 25.0 mm  |  W 14.0 mm  |  T 2.0 mm');
    expect(fields['Weight'], '8.5 g');
    expect(data.summaryObservations, endsWith('...'));
    expect(data.summaryObservations!.runes.length, lessThanOrEqualTo(363));
  });

  test('photographs retain persisted order without exposing internal ids', () {
    final data = factory.create(
      _record(
        photos: [
          _photo(90, '/private/front.jpg', FindPhotoRole.front, 0),
          _photo(12, '/private/reverse.jpg', FindPhotoRole.reverse, 1),
        ],
      ),
      findspotPrecision: FindspotExportPrecision.hidden,
    );

    expect(data.photos.map((photo) => photo.path), [
      '/private/front.jpg',
      '/private/reverse.jpg',
    ]);
    expect(data.photos.map((photo) => photo.caption), [
      'Photo 1 - Front',
      'Photo 2 - Reverse',
    ]);
    expect(data.fullFields.map((field) => field.value), isNot(contains('90')));
    expect(data.fullFields.map((field) => field.value), isNot(contains('12')));
  });
}

FindRecord _record({
  String material = 'Copper alloy',
  IdentificationConfidence confidence = IdentificationConfidence.probable,
  String observations = 'Diagonal grooves survive on the edge.',
  bool noMeasurements = false,
  List<FindPhoto> photos = const [],
}) => FindRecord(
  id: 42,
  logNumber: 'FO-000042',
  method: FindRecordMethod.instant,
  createdAt: DateTime(2026, 9, 1),
  updatedAt: DateTime(2026, 9, 2),
  discoveredAt: DateTime(2026, 8, 20),
  discoveryDateSource: FieldSource.photoMetadata,
  discoveryDateApproximate: true,
  location: const FindLocation(
    latitude: 51.123456,
    longitude: -1.234567,
    horizontalAccuracy: 4.2,
    altitude: 83.5,
    source: FieldSource.deviceCaptured,
  ),
  preferredIdentification: 'Roman brooch',
  material: material,
  confidence: confidence,
  timelineFromYear: 43,
  timelineToYear: 200,
  lengthMm: noMeasurements ? null : 25,
  widthMm: noMeasurements ? null : 14,
  heightMm: null,
  diameterMm: null,
  thicknessMm: noMeasurements ? null : 2,
  weightG: noMeasurements ? null : 8.5,
  observations: observations,
  researchNotes: 'Compared with a museum catalogue.',
  sources: 'Example catalogue, p. 10',
  storageLocation: 'Finds box 2',
  photos: photos,
);

FindPhoto _photo(int id, String path, FindPhotoRole role, int sortOrder) =>
    FindPhoto(
      id: id,
      path: path,
      role: role,
      source: FindPhotoSource.camera,
      createdAt: DateTime(2026, 8, 20),
      isOriginalEvidence: true,
      sortOrder: sortOrder,
    );
