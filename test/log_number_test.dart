import 'package:drift/native.dart';
import 'package:find_catalogue/data/app_database.dart';
import 'package:find_catalogue/data/find_repository.dart';
import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/find_record_service.dart';
import 'package:find_catalogue/services/media_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftFindRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftFindRepository(database);
  });

  tearDown(() => database.close());

  test('allocates permanent sequential log numbers', () async {
    final first = await repository.create(_draft(), const []);
    final second = await repository.create(_draft(), const []);

    expect(first.logNumber, 'FO-000001');
    expect(second.logNumber, 'FO-000002');
    expect(second.id, isNot(first.id));
  });

  test('deleting a record preserves existing and future log numbers', () async {
    final first = await repository.create(_draft(), const []);
    final deleted = await repository.create(_draft(), [
      _photo('deleted-record.jpg', 0),
    ]);
    final third = await repository.create(_draft(), const []);

    await repository.delete(deleted.id);

    final remaining = await repository.watchAll().first;
    expect(remaining.map((record) => record.logNumber).toSet(), {
      first.logNumber,
      third.logNumber,
    });
    expect(await repository.getById(deleted.id), isNull);
    expect(await database.select(database.findPhotos).get(), isEmpty);

    final next = await repository.create(_draft(), const []);
    expect(first.logNumber, 'FO-000001');
    expect(deleted.logNumber, 'FO-000002');
    expect(third.logNumber, 'FO-000003');
    expect(next.logNumber, 'FO-000004');
  });

  test(
    'global search text includes research, measurements and location',
    () async {
      final record = await repository.create(
        _draft(
          identification: 'Possible harness fitting',
          research: 'Compared with a museum catalogue entry',
          diameter: 24.5,
          location: const FindLocation(
            latitude: 51.123456,
            longitude: -1.234567,
            horizontalAccuracy: 4.2,
            source: FieldSource.manuallyEntered,
          ),
        ),
        const [],
      );

      expect(record.searchableText, contains('harness fitting'));
      expect(record.searchableText, contains('museum catalogue'));
      expect(record.searchableText, contains('24.5'));
      expect(record.searchableText, contains('51.123456'));
    },
  );

  test('persists and searches the interpreted timeline range', () async {
    final record = await repository.create(
      _draft(timelineFromYear: -50, timelineToYear: 100),
      const [],
    );

    expect(record.timelineFromYear, -50);
    expect(record.timelineToYear, 100);
    expect(record.searchableText, contains('-50'));
    expect(record.searchableText, contains('100'));
  });

  test('rejects a timeline whose To year precedes its From year', () async {
    expect(
      () => repository.create(
        _draft(timelineFromYear: 200, timelineToYear: 100),
        const [],
      ),
      throwsArgumentError,
    );
  });

  test('resolves portable photo paths when records are read', () async {
    final resolvingRepository = DriftFindRepository(
      database,
      resolvePhotoPath: (storedPath) => '/current/Documents/$storedPath',
    );
    final record = await resolvingRepository.create(_draft(), [
      NewFindPhoto(
        path: 'find_catalogue_media/originals/discovery.jpg',
        role: FindPhotoRole.discovery,
        source: FindPhotoSource.camera,
        createdAt: DateTime(2026),
        isOriginalEvidence: true,
        sortOrder: 0,
      ),
    ]);

    expect(
      record.photos.single.path,
      '/current/Documents/find_catalogue_media/originals/discovery.jpg',
    );
  });

  test('reconciles photo removal, roles and listing order', () async {
    final record = await repository.create(_draft(), [
      _photo('first.jpg', 0),
      _photo('second.jpg', 1),
      _photo('third.jpg', 2),
    ]);

    await repository.reconcilePhotos(
      record.id,
      [
        FindPhotoUpdate(
          id: record.photos[2].id,
          role: FindPhotoRole.reverse,
          sortOrder: 0,
        ),
        FindPhotoUpdate(
          id: record.photos[0].id,
          role: FindPhotoRole.front,
          sortOrder: 1,
        ),
      ],
      [_photo('new-detail.jpg', 2)],
    );

    final updated = (await repository.getById(record.id))!;
    expect(updated.photos.map((photo) => photo.path), [
      'third.jpg',
      'first.jpg',
      'new-detail.jpg',
    ]);
    expect(updated.primaryPhoto?.path, 'third.jpg');
    expect(updated.photos.map((photo) => photo.role), [
      FindPhotoRole.reverse,
      FindPhotoRole.front,
      FindPhotoRole.detail,
    ]);
  });

  test('record service persists the editor photo sequence', () async {
    final service = FindRecordService(
      repository: repository,
      mediaStore: _PassthroughMediaStore(),
    );
    final record = await repository.create(_draft(), [
      _photo('first.jpg', 0),
      _photo('second.jpg', 1),
      _photo('third.jpg', 2),
    ]);
    final reordered = [
      PhotoDraft.fromStored(record.photos[2]),
      PhotoDraft.fromStored(record.photos[0]),
      PhotoDraft(
        path: 'new.jpg',
        role: FindPhotoRole.context,
        source: FindPhotoSource.library,
        createdAt: DateTime(2026),
        isOriginalEvidence: true,
        sortOrder: 99,
        needsPreserving: false,
      ),
    ];

    await service.update(record.id, _draft(), reordered);

    final updated = (await repository.getById(record.id))!;
    expect(updated.photos.map((photo) => photo.path), [
      'third.jpg',
      'first.jpg',
      'new.jpg',
    ]);
    expect(updated.photos.map((photo) => photo.sortOrder), [0, 1, 2]);
    expect(updated.primaryPhoto?.path, 'third.jpg');
  });
}

NewFindPhoto _photo(String photoPath, int sortOrder) => NewFindPhoto(
  path: photoPath,
  role: FindPhotoRole.detail,
  source: FindPhotoSource.library,
  createdAt: DateTime(2026),
  isOriginalEvidence: true,
  sortOrder: sortOrder,
);

class _PassthroughMediaStore implements MediaStore {
  @override
  Future<String> preserveOriginal(String sourcePath) async => sourcePath;

  @override
  String resolvePath(String storedPath) => storedPath;
}

FindDraft _draft({
  String identification = '',
  String research = '',
  double? diameter,
  FindLocation? location,
  int? timelineFromYear,
  int? timelineToYear,
}) => FindDraft(
  method: FindRecordMethod.manual,
  discoveredAt: null,
  discoveryDateSource: FieldSource.unknown,
  discoveryDateApproximate: false,
  location: location,
  preferredIdentification: identification,
  material: '',
  confidence: IdentificationConfidence.unassessed,
  timelineFromYear: timelineFromYear,
  timelineToYear: timelineToYear,
  lengthMm: null,
  widthMm: null,
  heightMm: null,
  diameterMm: diameter,
  thicknessMm: null,
  weightG: null,
  observations: '',
  researchNotes: research,
  sources: '',
  storageLocation: '',
);
