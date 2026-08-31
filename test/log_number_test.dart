import 'package:drift/native.dart';
import 'package:find_catalogue/data/app_database.dart';
import 'package:find_catalogue/data/find_repository.dart';
import 'package:find_catalogue/domain/find_record.dart';
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
