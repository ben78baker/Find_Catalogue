import 'package:find_catalogue/app.dart';
import 'package:find_catalogue/data/find_repository.dart';
import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/find_record_service.dart';
import 'package:find_catalogue/services/location_capture_service.dart';
import 'package:find_catalogue/services/media_store.dart';
import 'package:find_catalogue/services/photo_capture_service.dart';
import 'package:flutter/material.dart' show Key, MaterialApp, Scrollable;
import 'package:flutter_test/flutter_test.dart';

import 'package:find_catalogue/ui/find_map_screen.dart';

void main() {
  testWidgets('home screen exposes the three catalogue routes', (tester) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(
      FindCatalogueApp(
        repository: repository,
        recordService: FindRecordService(
          repository: repository,
          mediaStore: _PassthroughMediaStore(),
        ),
        photoCaptureService: _NoPhotoCaptureService(),
        locationCaptureService: _NoLocationCaptureService(),
      ),
    );

    expect(find.text('Instant Find'), findsOneWidget);
    expect(find.text('Create Find Record'), findsOneWidget);
    expect(find.text('View Records'), findsOneWidget);
  });

  testWidgets('privacy and support are accessible from home', (tester) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('privacy_support_action')));
    await tester.pumpAndSettle();

    expect(find.text('Privacy & support'), findsOneWidget);
    expect(find.byKey(const Key('open_privacy_policy')), findsOneWidget);
    expect(find.byKey(const Key('open_support_page')), findsOneWidget);
  });

  testWidgets('cancelling the initial Instant Find camera returns home', (
    tester,
  ) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(
      FindCatalogueApp(
        repository: repository,
        recordService: FindRecordService(
          repository: repository,
          mediaStore: _PassthroughMediaStore(),
        ),
        photoCaptureService: _CancellingCameraService(),
        locationCaptureService: _NoLocationCaptureService(),
      ),
    );

    await tester.tap(find.byKey(const Key('instant_find_action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('instant_find_action')), findsOneWidget);
    expect(find.byKey(const Key('save_record_button')), findsNothing);
  });

  testWidgets('manual records offer map pinpointing', (tester) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('create_find_action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pinpoint_location_button')), findsOneWidget);
  });

  testWidgets('record map follows the current search result set', (
    tester,
  ) async {
    final repository = _StaticRepository([
      _record(
        id: 1,
        title: 'Ancient coin',
        location: const FindLocation(
          latitude: 51.5007,
          longitude: -0.1246,
          source: FieldSource.manuallyEntered,
        ),
      ),
      _record(
        id: 2,
        title: 'Bronze button',
        location: const FindLocation(
          latitude: 52.2053,
          longitude: 0.1218,
          source: FieldSource.deviceCaptured,
        ),
      ),
      _record(id: 3, title: 'Pottery fragment'),
    ]);
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('view_records_action')));
    await tester.pumpAndSettle();
    expect(find.text('Map (2)'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('record_search_field')),
      'Ancient coin',
    );
    await tester.pump();
    expect(find.text('Map (1)'), findsOneWidget);

    await tester.tap(find.text('Ancient coin').last);
    await tester.pumpAndSettle();
    expect(find.text('FO-000001'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('view_record_map_button')),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const Key('view_record_map_button')), findsOneWidget);
  });

  test('only valid record coordinates are mappable', () {
    final valid = _record(
      id: 1,
      title: 'Valid',
      location: const FindLocation(
        latitude: 51,
        longitude: -1,
        source: FieldSource.manuallyEntered,
      ),
    );
    final invalid = _record(
      id: 2,
      title: 'Invalid',
      location: const FindLocation(
        latitude: 95,
        longitude: -1,
        source: FieldSource.manuallyEntered,
      ),
    );

    expect(mappableRecords([valid, invalid]), [valid]);
    expect(isMappableLocation(null), isFalse);
    expect(isMappableLocation(invalid.location), isFalse);
  });

  testWidgets('a located record renders as an interactive map marker', (
    tester,
  ) async {
    final record = _record(
      id: 1,
      title: 'Ancient coin',
      location: const FindLocation(
        latitude: 51.5007,
        longitude: -0.1246,
        source: FieldSource.manuallyEntered,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FindMapScreen(title: record.logNumber, records: [record]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('1 find mapped'), findsOneWidget);
    expect(find.byKey(const Key('map_marker_1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('map_marker_1')));
    await tester.pumpAndSettle();
    expect(find.text('FO-000001 - Ancient coin'), findsOneWidget);
    expect(find.text('51.500700, -0.124600'), findsOneWidget);
  });
}

FindCatalogueApp _app(FindRepository repository) => FindCatalogueApp(
  repository: repository,
  recordService: FindRecordService(
    repository: repository,
    mediaStore: _PassthroughMediaStore(),
  ),
  photoCaptureService: _NoPhotoCaptureService(),
  locationCaptureService: _NoLocationCaptureService(),
);

FindRecord _record({
  required int id,
  required String title,
  FindLocation? location,
}) {
  final timestamp = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: id,
    logNumber: 'FO-${id.toString().padLeft(6, '0')}',
    method: FindRecordMethod.manual,
    createdAt: timestamp,
    updatedAt: timestamp,
    discoveredAt: timestamp,
    discoveryDateSource: FieldSource.manuallyEntered,
    discoveryDateApproximate: false,
    location: location,
    preferredIdentification: title,
    material: '',
    confidence: IdentificationConfidence.unassessed,
    timelineFromYear: null,
    timelineToYear: null,
    lengthMm: null,
    widthMm: null,
    heightMm: null,
    diameterMm: null,
    thicknessMm: null,
    weightG: null,
    observations: '',
    researchNotes: '',
    sources: '',
    storageLocation: '',
    photos: const [],
  );
}

class _EmptyRepository implements FindRepository {
  @override
  Stream<List<FindRecord>> watchAll() => Stream.value(const []);

  @override
  Stream<FindRecord?> watchById(int id) => Stream.value(null);

  @override
  Future<FindRecord?> getById(int id) async => null;

  @override
  Future<FindRecord> create(FindDraft draft, List<NewFindPhoto> photos) =>
      throw UnimplementedError();

  @override
  Future<void> update(int id, FindDraft draft) async {}

  @override
  Future<void> addPhotos(int id, List<NewFindPhoto> photos) async {}

  @override
  Future<void> updatePhotoRole(int photoId, FindPhotoRole role) async {}
}

class _StaticRepository implements FindRepository {
  _StaticRepository(this.records);

  final List<FindRecord> records;

  @override
  Stream<List<FindRecord>> watchAll() => Stream.value(records);

  @override
  Stream<FindRecord?> watchById(int id) =>
      Stream.value(records.where((record) => record.id == id).firstOrNull);

  @override
  Future<FindRecord?> getById(int id) async =>
      records.where((record) => record.id == id).firstOrNull;

  @override
  Future<FindRecord> create(FindDraft draft, List<NewFindPhoto> photos) =>
      throw UnimplementedError();

  @override
  Future<void> update(int id, FindDraft draft) async {}

  @override
  Future<void> addPhotos(int id, List<NewFindPhoto> photos) async {}

  @override
  Future<void> updatePhotoRole(int photoId, FindPhotoRole role) async {}
}

class _PassthroughMediaStore implements MediaStore {
  @override
  Future<String> preserveOriginal(String sourcePath) async => sourcePath;

  @override
  String resolvePath(String storedPath) => storedPath;
}

class _NoPhotoCaptureService implements PhotoCaptureService {
  @override
  bool get supportsCamera => false;

  @override
  Future<PickedFindPhoto?> choosePhoto() async => null;

  @override
  Future<PickedFindPhoto?> takePhoto() async => null;
}

class _CancellingCameraService implements PhotoCaptureService {
  @override
  bool get supportsCamera => true;

  @override
  Future<PickedFindPhoto?> choosePhoto() async => null;

  @override
  Future<PickedFindPhoto?> takePhoto() async => null;
}

class _NoLocationCaptureService implements LocationCaptureService {
  @override
  Future<LocationCaptureResult> captureCurrentLocation() async =>
      const LocationCaptureResult(message: 'Unavailable in test.');
}
