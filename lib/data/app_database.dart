import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class FindRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get logNumber => text().unique()();
  TextColumn get recordMethod => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get discoveredAt => dateTime().nullable()();
  TextColumn get discoveryDateSource => text()();
  BoolColumn get discoveryDateApproximate =>
      boolean().withDefault(const Constant(false))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get horizontalAccuracy => real().nullable()();
  RealColumn get altitude => real().nullable()();
  TextColumn get locationSource => text()();
  TextColumn get preferredIdentification =>
      text().withDefault(const Constant(''))();
  TextColumn get material => text().withDefault(const Constant(''))();
  TextColumn get confidence =>
      text().withDefault(const Constant('unassessed'))();
  IntColumn get timelineFromYear => integer().nullable()();
  IntColumn get timelineToYear => integer().nullable()();
  RealColumn get lengthMm => real().nullable()();
  RealColumn get widthMm => real().nullable()();
  RealColumn get heightMm => real().nullable()();
  RealColumn get diameterMm => real().nullable()();
  RealColumn get thicknessMm => real().nullable()();
  RealColumn get weightG => real().nullable()();
  TextColumn get observations => text().withDefault(const Constant(''))();
  TextColumn get researchNotes => text().withDefault(const Constant(''))();
  TextColumn get sources => text().withDefault(const Constant(''))();
  TextColumn get storageLocation => text().withDefault(const Constant(''))();
}

class FindPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get findRecordId => integer().references(FindRecords, #id)();
  TextColumn get path => text()();
  TextColumn get role => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isOriginalEvidence => boolean()();
  IntColumn get sortOrder => integer()();
}

class CatalogueCounters extends Table {
  TextColumn get key => text()();
  IntColumn get nextValue => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [FindRecords, FindPhotos, CatalogueCounters])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults() : super(driftDatabase(name: 'find_catalogue'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(findRecords, findRecords.timelineFromYear);
        await migrator.addColumn(findRecords, findRecords.timelineToYear);
      }
      if (from < 3) {
        await customStatement('''
          UPDATE find_photos
          SET path = substr(path, instr(path, 'find_catalogue_media/'))
          WHERE instr(path, 'find_catalogue_media/') > 0
        ''');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
