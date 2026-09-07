import 'dart:async';

import 'package:find_catalogue/app.dart';
import 'package:find_catalogue/data/find_repository.dart';
import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/find_record_service.dart';
import 'package:find_catalogue/services/location_capture_service.dart';
import 'package:find_catalogue/services/media_store.dart';
import 'package:find_catalogue/services/place_geocoding_service.dart';
import 'package:find_catalogue/services/photo_capture_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:find_catalogue/ui/find_map_screen.dart';
import 'package:find_catalogue/ui/record_detail_screen.dart';
import 'package:find_catalogue/ui/record_editor_screen.dart';

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

  testWidgets('Instant Find confirms or skips location after the camera', (
    tester,
  ) async {
    final repository = _EmptyRepository();
    final locationService = _TrackingLocationCaptureService();
    await tester.pumpWidget(
      FindCatalogueApp(
        repository: repository,
        recordService: FindRecordService(
          repository: repository,
          mediaStore: _PassthroughMediaStore(),
        ),
        photoCaptureService: _SuccessfulCameraService(),
        locationCaptureService: locationService,
      ),
    );

    await tester.tap(find.byKey(const Key('instant_find_action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('location_picker_map')), findsOneWidget);
    expect(find.text('GPS accuracy ±18.0 m'), findsOneWidget);
    expect(find.text('Confirm location'), findsOneWidget);
    expect(find.text('Skip location'), findsOneWidget);
    final instantCamera = MapCamera.of(tester.element(find.byType(TileLayer)));
    expect(instantCamera.zoom, greaterThan(16));

    await tester.tap(find.byKey(const Key('skip_map_location_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Location skipped. You can add one before saving if needed.'),
      findsOneWidget,
    );
    expect(locationService.session.cancelled, isTrue);
  });

  testWidgets('map confirmation preserves GPS accuracy until the pin moves', (
    tester,
  ) async {
    const gpsLocation = FindLocation(
      latitude: 51.5007,
      longitude: -0.1246,
      horizontalAccuracy: 18,
      altitude: 42,
      source: FieldSource.deviceCaptured,
    );
    late Future<FindLocationPickerResult?> selection;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            key: const Key('open_picker'),
            onPressed: () {
              selection = Navigator.of(context).push<FindLocationPickerResult>(
                MaterialPageRoute(
                  builder: (_) => const FindLocationPickerScreen(
                    initialLocation: gpsLocation,
                    confirmLabel: 'Confirm location',
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open_picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('use_map_location_button')));
    await tester.pumpAndSettle();

    final unchanged = (await selection)!.location!;
    expect(unchanged.source, FieldSource.deviceCaptured);
    expect(unchanged.horizontalAccuracy, 18);
    expect(unchanged.altitude, 42);

    await tester.tap(find.byKey(const Key('open_picker')));
    await tester.pumpAndSettle();
    tester
        .widget<FlutterMap>(find.byKey(const Key('location_picker_map')))
        .options
        .onTap!(
      const TapPosition(Offset.zero, Offset.zero),
      const LatLng(51.501, -0.125),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('location_picker_accuracy')), findsNothing);
    await tester.tap(find.byKey(const Key('use_map_location_button')));
    await tester.pumpAndSettle();

    final moved = (await selection)!.location!;
    expect(moved.source, FieldSource.manuallyEntered);
    expect(moved.horizontalAccuracy, isNull);
  });

  testWidgets('manual records offer map pinpointing', (tester) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('create_find_action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pinpoint_location_button')), findsOneWidget);
    expect(find.byKey(const Key('delete_record_button')), findsNothing);
  });

  testWidgets('record deletion requires confirmation and returns to listing', (
    tester,
  ) async {
    final record = _record(id: 1, title: 'Delete candidate');
    final repository = _StaticRepository([record]);
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('view_records_action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete candidate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_record_button')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete_record_button')),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );

    await tester.tap(find.byKey(const Key('delete_record_button')));
    await tester.pumpAndSettle();
    expect(find.text('Delete this record?'), findsOneWidget);
    expect(
      find.text('This will remove the record from your catalogue.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('cancel_delete_record_button')));
    await tester.pumpAndSettle();
    expect(repository.records, contains(record));
    expect(repository.deletedIds, isEmpty);

    await tester.tap(find.byKey(const Key('delete_record_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete_record_button')));
    await tester.pumpAndSettle();

    expect(repository.deletedIds, [record.id]);
    expect(repository.records, isEmpty);
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Delete candidate'), findsNothing);
    expect(find.byKey(const Key('edit_record_button')), findsNothing);
  });

  testWidgets('an empty general picker centres broadly on current location', (
    tester,
  ) async {
    final locationService = _TrackingLocationCaptureService();
    await tester.pumpWidget(
      MaterialApp(
        home: FindLocationPickerScreen(locationCaptureService: locationService),
      ),
    );
    await tester.pumpAndSettle();

    final camera = MapCamera.of(tester.element(find.byType(TileLayer)));
    expect(camera.center.latitude, closeTo(51.5007, 0.000001));
    expect(camera.center.longitude, closeTo(-0.1246, 0.000001));
    expect(camera.zoom, inInclusiveRange(10, 14));
    expect(find.byKey(const Key('location_picker_marker')), findsNothing);
    expect(locationService.session.cancelled, isTrue);
  });

  testWidgets('map place search runs only when explicitly submitted', (
    tester,
  ) async {
    final geocodingService = _FakePlaceGeocodingService();
    final record = _record(
      id: 1,
      title: 'Map search',
      location: const FindLocation(
        latitude: 51.5,
        longitude: -0.12,
        source: FieldSource.manuallyEntered,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: FindMapScreen(
          title: 'Finds map',
          records: [record],
          geocodingService: geocodingService,
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('map_place_search_field')),
      'Praa Sands',
    );
    await tester.pump();
    expect(geocodingService.queries, isEmpty);

    await tester.tap(find.byKey(const Key('map_place_search_button')));
    await tester.pumpAndSettle();
    expect(geocodingService.queries, ['Praa Sands']);
    expect(find.text('Praa Sands, Cornwall'), findsOneWidget);

    final camera = MapCamera.of(tester.element(find.byType(TileLayer)));
    expect(camera.center.latitude, closeTo(50.103, 0.000001));
    expect(camera.center.longitude, closeTo(-5.390, 0.000001));
    expect(camera.zoom, inInclusiveRange(12, 17));
  });

  testWidgets('an existing Instant Find can pinpoint or clear its location', (
    tester,
  ) async {
    final record = _record(
      id: 1,
      title: 'Instant find',
      method: FindRecordMethod.instant,
      location: const FindLocation(
        latitude: 51.5,
        longitude: -0.12,
        horizontalAccuracy: 12,
        source: FieldSource.deviceCaptured,
      ),
    );
    final repository = _StaticRepository([record]);
    await tester.pumpWidget(
      MaterialApp(
        home: RecordEditorScreen(
          method: record.method,
          existingRecord: record,
          recordService: FindRecordService(
            repository: repository,
            mediaStore: _PassthroughMediaStore(),
          ),
          photoCaptureService: _NoPhotoCaptureService(),
          locationCaptureService: _NoLocationCaptureService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pinpoint_location_button')), findsOneWidget);
    expect(find.byKey(const Key('clear_location_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('clear_location_button')));
    await tester.pump();
    expect(find.text('Location cleared.'), findsOneWidget);
    expect(find.byKey(const Key('clear_location_button')), findsNothing);
  });

  testWidgets('record editor validates latitude and longitude bounds', (
    tester,
  ) async {
    final record = _record(id: 1, title: 'Bounds');
    final repository = _StaticRepository([record]);
    await tester.pumpWidget(
      MaterialApp(
        home: RecordEditorScreen(
          method: record.method,
          existingRecord: record,
          recordService: FindRecordService(
            repository: repository,
            mediaStore: _PassthroughMediaStore(),
          ),
          photoCaptureService: _NoPhotoCaptureService(),
          locationCaptureService: _NoLocationCaptureService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('latitude_field')), '91');
    await tester.enterText(find.byKey(const Key('longitude_field')), '-181');
    await tester.tap(find.byKey(const Key('save_record_button')));
    await tester.pump();

    expect(find.text('Enter -90 to 90'), findsOneWidget);
    expect(find.text('Enter -180 to 180'), findsOneWidget);
  });

  testWidgets('record editor can dismiss the keyboard', (tester) async {
    final repository = _EmptyRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('create_find_action')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('preferred_identification_field')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('preferred_identification_field'))),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('preferred_identification_field')));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isTrue);
    expect(
      tester
          .widget<ListView>(find.byType(ListView).first)
          .keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );

    await tester.tap(find.text('Basic details'));
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('record editor manages saved photographs and listing photo', (
    tester,
  ) async {
    final timestamp = DateTime(2026, 8, 30, 12);
    final record = _record(
      id: 1,
      title: 'Ancient coin',
      photos: [
        FindPhoto(
          id: 1,
          path: '/missing/front.jpg',
          role: FindPhotoRole.front,
          source: FindPhotoSource.library,
          createdAt: timestamp,
          isOriginalEvidence: true,
          sortOrder: 0,
        ),
        FindPhoto(
          id: 2,
          path: '/missing/reverse.jpg',
          role: FindPhotoRole.reverse,
          source: FindPhotoSource.library,
          createdAt: timestamp,
          isOriginalEvidence: true,
          sortOrder: 1,
        ),
      ],
    );
    final repository = _StaticRepository([record]);
    await tester.pumpWidget(
      MaterialApp(
        home: RecordEditorScreen(
          method: record.method,
          existingRecord: record,
          recordService: FindRecordService(
            repository: repository,
            mediaStore: _PassthroughMediaStore(),
          ),
          photoCaptureService: _NoPhotoCaptureService(),
          locationCaptureService: _NoLocationCaptureService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Listing photo'), findsOneWidget);
    expect(find.byKey(const Key('reorder_photo_0')), findsOneWidget);
    expect(find.byKey(const Key('reorder_photo_1')), findsOneWidget);
    expect(find.byKey(const Key('remove_photo_0')), findsOneWidget);
    expect(
      tester
          .widgetList<DropdownButton<FindPhotoRole>>(
            find.byType(DropdownButton<FindPhotoRole>),
          )
          .map((dropdown) => dropdown.value),
      [FindPhotoRole.front, FindPhotoRole.reverse],
    );

    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorder(1, 0);
    await tester.pump();
    expect(
      tester
          .widgetList<DropdownButton<FindPhotoRole>>(
            find.byType(DropdownButton<FindPhotoRole>),
          )
          .map((dropdown) => dropdown.value),
      [FindPhotoRole.reverse, FindPhotoRole.front],
    );

    await tester.tap(find.byKey(const Key('remove_photo_0')));
    await tester.pumpAndSettle();
    expect(find.text('Remove photograph?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_remove_photo')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('photo_editor_card_0')), findsOneWidget);
    expect(find.byKey(const Key('photo_editor_card_1')), findsNothing);
    expect(find.text('Listing photo'), findsOneWidget);
  });

  testWidgets('a chosen findspot stays anchored while the map zooms', (
    tester,
  ) async {
    const coordinateText = '51.500700, -0.124600';
    await tester.pumpWidget(
      const MaterialApp(
        home: FindLocationPickerScreen(
          initialLocation: FindLocation(
            latitude: 51.5007,
            longitude: -0.1246,
            source: FieldSource.manuallyEntered,
          ),
        ),
      ),
    );
    await tester.pump();

    final marker = find.byKey(const Key('location_picker_marker'));
    final map = find.byKey(const Key('location_picker_map'));
    expect(marker, findsOneWidget);
    expect(find.text(coordinateText), findsOneWidget);
    final originalMarkerPosition = tester.getCenter(marker);
    final mapRect = tester.getRect(map);
    final focalPoint = Offset(
      mapRect.left + mapRect.width * 0.25,
      mapRect.top + mapRect.height * 0.5,
    );
    final firstFinger = await tester.startGesture(
      focalPoint - const Offset(25, 0),
      pointer: 1,
    );
    final secondFinger = await tester.startGesture(
      focalPoint + const Offset(25, 0),
      pointer: 2,
    );
    await tester.pump();
    await firstFinger.moveTo(focalPoint - const Offset(50, 0));
    await secondFinger.moveTo(focalPoint + const Offset(50, 0));
    await tester.pump();

    final markerPositionDuringZoom = tester.getCenter(marker);
    expect(markerPositionDuringZoom, isNot(originalMarkerPosition));

    await firstFinger.up();
    await secondFinger.up();
    await tester.pump();

    expect(find.text(coordinateText), findsOneWidget);
    expect(tester.getCenter(marker), markerPositionDuringZoom);
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

  testWidgets('record photographs open in a full-screen viewer', (
    tester,
  ) async {
    final timestamp = DateTime(2026, 8, 30, 12);
    final record = _record(
      id: 1,
      title: 'Ancient coin',
      photos: [
        FindPhoto(
          id: 1,
          path: '/missing/demo-photo.jpg',
          role: FindPhotoRole.discovery,
          source: FindPhotoSource.camera,
          createdAt: timestamp,
          isOriginalEvidence: true,
          sortOrder: 0,
        ),
      ],
    );
    final repository = _StaticRepository([record]);
    await tester.pumpWidget(
      MaterialApp(
        home: RecordDetailScreen(
          recordId: record.id,
          repository: repository,
          recordService: FindRecordService(
            repository: repository,
            mediaStore: _PassthroughMediaStore(),
          ),
          photoCaptureService: _NoPhotoCaptureService(),
          locationCaptureService: _NoLocationCaptureService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('record_photo_0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('full_screen_photo_viewer')), findsOneWidget);
    expect(find.byKey(const Key('full_screen_photo_0')), findsOneWidget);
    expect(find.text('Discovery · 1 of 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close_full_screen_photo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('full_screen_photo_viewer')), findsNothing);
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
  FindRecordMethod method = FindRecordMethod.manual,
  FindLocation? location,
  List<FindPhoto> photos = const [],
}) {
  final timestamp = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: id,
    logNumber: 'FO-${id.toString().padLeft(6, '0')}',
    method: method,
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
    photos: photos,
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
  Future<void> delete(int id) async {}

  @override
  Future<void> update(int id, FindDraft draft) async {}

  @override
  Future<void> reconcilePhotos(
    int recordId,
    List<FindPhotoUpdate> existingPhotos,
    List<NewFindPhoto> newPhotos,
  ) async {}
}

class _StaticRepository implements FindRepository {
  _StaticRepository(this.records);

  final List<FindRecord> records;
  final List<int> deletedIds = [];
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<List<FindRecord>> watchAll() async* {
    yield List.unmodifiable(records);
    await for (final _ in _changes.stream) {
      yield List.unmodifiable(records);
    }
  }

  @override
  Stream<FindRecord?> watchById(int id) async* {
    FindRecord? current() =>
        records.where((record) => record.id == id).firstOrNull;
    yield current();
    await for (final _ in _changes.stream) {
      yield current();
    }
  }

  @override
  Future<FindRecord?> getById(int id) async =>
      records.where((record) => record.id == id).firstOrNull;

  @override
  Future<FindRecord> create(FindDraft draft, List<NewFindPhoto> photos) =>
      throw UnimplementedError();

  @override
  Future<void> delete(int id) async {
    deletedIds.add(id);
    records.removeWhere((record) => record.id == id);
    _changes.add(null);
  }

  @override
  Future<void> update(int id, FindDraft draft) async {}

  @override
  Future<void> reconcilePhotos(
    int recordId,
    List<FindPhotoUpdate> existingPhotos,
    List<NewFindPhoto> newPhotos,
  ) async {}
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

class _SuccessfulCameraService implements PhotoCaptureService {
  @override
  bool get supportsCamera => true;

  @override
  Future<PickedFindPhoto?> choosePhoto() async => null;

  @override
  Future<PickedFindPhoto?> takePhoto() async => PickedFindPhoto(
    temporaryPath: '/missing/instant-find.jpg',
    source: FindPhotoSource.camera,
    createdAt: DateTime(2026, 9, 7, 12),
  );
}

class _TrackingLocationCaptureService implements LocationCaptureService {
  _TrackingLocationCaptureService()
    : session = _TrackingLocationSession(
        const LocationCaptureResult(
          location: FindLocation(
            latitude: 51.5007,
            longitude: -0.1246,
            horizontalAccuracy: 18,
            source: FieldSource.deviceCaptured,
          ),
        ),
      );

  final _TrackingLocationSession session;

  @override
  Future<LocationCaptureResult> captureCurrentLocation() => session.completed;

  @override
  LocationCaptureSession startLocationCapture() => session;
}

class _TrackingLocationSession extends _TestLocationSession {
  _TrackingLocationSession(super.result);

  bool cancelled = false;

  @override
  Future<void> cancel() async => cancelled = true;
}

class _FakePlaceGeocodingService implements PlaceGeocodingService {
  final List<String> queries = [];

  @override
  Future<PlaceSearchResult> search(String query) async {
    queries.add(query);
    return const PlaceSearchResult(
      latitude: 50.103,
      longitude: -5.390,
      displayName: 'Praa Sands, Cornwall',
    );
  }
}

class _NoLocationCaptureService implements LocationCaptureService {
  @override
  LocationCaptureSession startLocationCapture() => _TestLocationSession(
    const LocationCaptureResult(message: 'Unavailable in test.'),
  );

  @override
  Future<LocationCaptureResult> captureCurrentLocation() async =>
      const LocationCaptureResult(message: 'Unavailable in test.');
}

class _TestLocationSession implements LocationCaptureSession {
  _TestLocationSession(this.result);

  final LocationCaptureResult result;

  @override
  LocationCaptureResult get bestResult => result;

  @override
  Future<LocationCaptureResult> get completed async => result;

  @override
  Stream<LocationCaptureResult> get updates => const Stream.empty();

  @override
  Future<void> cancel() async {}
}
