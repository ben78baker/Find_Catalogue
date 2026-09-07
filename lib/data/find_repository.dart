import 'package:drift/drift.dart';

import '../domain/find_record.dart' as domain;
import 'app_database.dart';

abstract interface class FindRepository {
  Stream<List<domain.FindRecord>> watchAll();
  Stream<domain.FindRecord?> watchById(int id);
  Future<domain.FindRecord?> getById(int id);
  Future<domain.FindRecord> create(
    domain.FindDraft draft,
    List<domain.NewFindPhoto> photos,
  );
  Future<void> update(int id, domain.FindDraft draft);
  Future<void> delete(int id);
  Future<void> reconcilePhotos(
    int recordId,
    List<domain.FindPhotoUpdate> existingPhotos,
    List<domain.NewFindPhoto> newPhotos,
  );
}

class DriftFindRepository implements FindRepository {
  DriftFindRepository(
    this.database, {
    String Function(String storedPath)? resolvePhotoPath,
  }) : _resolvePhotoPath = resolvePhotoPath ?? _identityPath;

  final AppDatabase database;
  final String Function(String storedPath) _resolvePhotoPath;

  @override
  Stream<List<domain.FindRecord>> watchAll() {
    final recordsQuery = database.select(database.findRecords);
    final photosQuery = database.select(database.findPhotos);
    return recordsQuery.watch().asyncMap((records) async {
      final photos = await photosQuery.get();
      return _assemble(records, photos)..sort(_newestFirst);
    });
  }

  @override
  Stream<domain.FindRecord?> watchById(int id) {
    final recordQuery = database.select(database.findRecords)
      ..where((table) => table.id.equals(id));
    final photosQuery = database.select(database.findPhotos)
      ..where((table) => table.findRecordId.equals(id));

    return recordQuery.watchSingleOrNull().asyncMap((record) async {
      if (record == null) return null;
      final photos = await photosQuery.get();
      return _mapRecord(record, photos);
    });
  }

  @override
  Future<domain.FindRecord?> getById(int id) async {
    final recordQuery = database.select(database.findRecords)
      ..where((table) => table.id.equals(id));
    final record = await recordQuery.getSingleOrNull();
    if (record == null) return null;
    final photosQuery = database.select(database.findPhotos)
      ..where((table) => table.findRecordId.equals(id));
    return _mapRecord(record, await photosQuery.get());
  }

  @override
  Future<domain.FindRecord> create(
    domain.FindDraft draft,
    List<domain.NewFindPhoto> photos,
  ) async {
    _validateTimeline(draft);
    final id = await database.transaction(() async {
      const counterKey = 'find_log_number';
      final counterQuery = database.select(database.catalogueCounters)
        ..where((table) => table.key.equals(counterKey));
      final counter = await counterQuery.getSingleOrNull();
      final allocated = counter?.nextValue ?? 1;
      final next = allocated + 1;

      await database
          .into(database.catalogueCounters)
          .insertOnConflictUpdate(
            CatalogueCountersCompanion.insert(key: counterKey, nextValue: next),
          );

      final now = DateTime.now();
      final recordId = await database
          .into(database.findRecords)
          .insert(
            _companionFromDraft(
              draft,
              logNumber: 'FO-${allocated.toString().padLeft(6, '0')}',
              createdAt: now,
              updatedAt: now,
            ),
          );

      if (photos.isNotEmpty) {
        await database.batch((batch) {
          batch.insertAll(
            database.findPhotos,
            photos.map((photo) => _photoCompanion(recordId, photo)).toList(),
          );
        });
      }
      return recordId;
    });

    return (await getById(id))!;
  }

  @override
  Future<void> update(int id, domain.FindDraft draft) async {
    _validateTimeline(draft);
    final statement = database.update(database.findRecords)
      ..where((table) => table.id.equals(id));
    await statement.write(
      _companionFromDraft(draft, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> delete(int id) async {
    await database.transaction(() async {
      final photos = database.delete(database.findPhotos)
        ..where((table) => table.findRecordId.equals(id));
      await photos.go();

      final record = database.delete(database.findRecords)
        ..where((table) => table.id.equals(id));
      await record.go();
    });
  }

  @override
  Future<void> reconcilePhotos(
    int recordId,
    List<domain.FindPhotoUpdate> existingPhotos,
    List<domain.NewFindPhoto> newPhotos,
  ) async {
    await database.transaction(() async {
      final storedQuery = database.select(database.findPhotos)
        ..where((table) => table.findRecordId.equals(recordId));
      final stored = await storedQuery.get();
      final storedIds = stored.map((photo) => photo.id).toSet();
      final retainedIds = existingPhotos.map((photo) => photo.id).toSet();
      if (!storedIds.containsAll(retainedIds)) {
        throw ArgumentError('A photograph does not belong to this record.');
      }

      for (final photo in stored) {
        if (retainedIds.contains(photo.id)) continue;
        final deletion = database.delete(database.findPhotos)
          ..where((table) => table.id.equals(photo.id));
        await deletion.go();
      }

      for (final photo in existingPhotos) {
        final update = database.update(database.findPhotos)
          ..where((table) => table.id.equals(photo.id));
        await update.write(
          FindPhotosCompanion(
            role: Value(photo.role.name),
            sortOrder: Value(photo.sortOrder),
          ),
        );
      }

      if (newPhotos.isNotEmpty) {
        await database.batch((batch) {
          batch.insertAll(
            database.findPhotos,
            newPhotos.map((photo) => _photoCompanion(recordId, photo)).toList(),
          );
        });
      }

      final recordStatement = database.update(database.findRecords)
        ..where((table) => table.id.equals(recordId));
      await recordStatement.write(
        FindRecordsCompanion(updatedAt: Value(DateTime.now())),
      );
    });
  }

  FindRecordsCompanion _companionFromDraft(
    domain.FindDraft draft, {
    String? logNumber,
    DateTime? createdAt,
    required DateTime updatedAt,
  }) {
    return FindRecordsCompanion(
      logNumber: logNumber == null ? const Value.absent() : Value(logNumber),
      recordMethod: Value(draft.method.name),
      createdAt: createdAt == null ? const Value.absent() : Value(createdAt),
      updatedAt: Value(updatedAt),
      discoveredAt: Value(draft.discoveredAt),
      discoveryDateSource: Value(draft.discoveryDateSource.name),
      discoveryDateApproximate: Value(draft.discoveryDateApproximate),
      latitude: Value(draft.location?.latitude),
      longitude: Value(draft.location?.longitude),
      horizontalAccuracy: Value(draft.location?.horizontalAccuracy),
      altitude: Value(draft.location?.altitude),
      locationSource: Value(
        draft.location?.source.name ?? domain.FieldSource.unknown.name,
      ),
      preferredIdentification: Value(draft.preferredIdentification.trim()),
      material: Value(draft.material.trim()),
      confidence: Value(draft.confidence.name),
      timelineFromYear: Value(draft.timelineFromYear),
      timelineToYear: Value(draft.timelineToYear),
      lengthMm: Value(draft.lengthMm),
      widthMm: Value(draft.widthMm),
      heightMm: Value(draft.heightMm),
      diameterMm: Value(draft.diameterMm),
      thicknessMm: Value(draft.thicknessMm),
      weightG: Value(draft.weightG),
      observations: Value(draft.observations.trim()),
      researchNotes: Value(draft.researchNotes.trim()),
      sources: Value(draft.sources.trim()),
      storageLocation: Value(draft.storageLocation.trim()),
    );
  }

  FindPhotosCompanion _photoCompanion(int recordId, domain.NewFindPhoto photo) {
    return FindPhotosCompanion.insert(
      findRecordId: recordId,
      path: photo.path,
      role: photo.role.name,
      source: photo.source.name,
      createdAt: photo.createdAt,
      isOriginalEvidence: photo.isOriginalEvidence,
      sortOrder: photo.sortOrder,
    );
  }

  List<domain.FindRecord> _assemble(
    List<FindRecord> records,
    List<FindPhoto> photos,
  ) {
    final photosByRecord = <int, List<FindPhoto>>{};
    for (final photo in photos) {
      photosByRecord.putIfAbsent(photo.findRecordId, () => []).add(photo);
    }
    return records
        .map((record) => _mapRecord(record, photosByRecord[record.id] ?? []))
        .toList();
  }

  domain.FindRecord _mapRecord(FindRecord record, List<FindPhoto> photos) {
    photos.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final method = _enumByName(
      domain.FindRecordMethod.values,
      record.recordMethod,
      domain.FindRecordMethod.manual,
    );
    final dateSource = _enumByName(
      domain.FieldSource.values,
      record.discoveryDateSource,
      domain.FieldSource.unknown,
    );
    final location = record.latitude == null || record.longitude == null
        ? null
        : domain.FindLocation(
            latitude: record.latitude!,
            longitude: record.longitude!,
            horizontalAccuracy: record.horizontalAccuracy,
            altitude: record.altitude,
            source: _enumByName(
              domain.FieldSource.values,
              record.locationSource,
              domain.FieldSource.unknown,
            ),
          );

    return domain.FindRecord(
      id: record.id,
      logNumber: record.logNumber,
      method: method,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      discoveredAt: record.discoveredAt,
      discoveryDateSource: dateSource,
      discoveryDateApproximate: record.discoveryDateApproximate,
      location: location,
      preferredIdentification: record.preferredIdentification,
      material: record.material,
      confidence: _enumByName(
        domain.IdentificationConfidence.values,
        record.confidence,
        domain.IdentificationConfidence.unassessed,
      ),
      timelineFromYear: record.timelineFromYear,
      timelineToYear: record.timelineToYear,
      lengthMm: record.lengthMm,
      widthMm: record.widthMm,
      heightMm: record.heightMm,
      diameterMm: record.diameterMm,
      thicknessMm: record.thicknessMm,
      weightG: record.weightG,
      observations: record.observations,
      researchNotes: record.researchNotes,
      sources: record.sources,
      storageLocation: record.storageLocation,
      photos: photos
          .map(
            (photo) => domain.FindPhoto(
              id: photo.id,
              path: _resolvePhotoPath(photo.path),
              role: _enumByName(
                domain.FindPhotoRole.values,
                photo.role,
                domain.FindPhotoRole.detail,
              ),
              source: _enumByName(
                domain.FindPhotoSource.values,
                photo.source,
                domain.FindPhotoSource.library,
              ),
              createdAt: photo.createdAt,
              isOriginalEvidence: photo.isOriginalEvidence,
              sortOrder: photo.sortOrder,
            ),
          )
          .toList(),
    );
  }

  T _enumByName<T extends Enum>(List<T> values, String name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  void _validateTimeline(domain.FindDraft draft) {
    if (!domain.timelineRangeIsValid(
      draft.timelineFromYear,
      draft.timelineToYear,
    )) {
      throw ArgumentError(
        'Timeline To year must not be earlier than From year.',
      );
    }
  }

  int _newestFirst(domain.FindRecord a, domain.FindRecord b) {
    final aDate = a.discoveredAt ?? a.createdAt;
    final bDate = b.discoveredAt ?? b.createdAt;
    return bDate.compareTo(aDate);
  }
}

String _identityPath(String storedPath) => storedPath;
