import 'dart:io';

import 'package:drift/native.dart';
import 'package:find_catalogue/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'migration adds timeline fields and makes stored media paths portable',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'find_catalogue_migration_',
      );
      final file = File('${directory.path}/catalogue.sqlite');

      var database = AppDatabase(NativeDatabase(file));
      await database.customSelect('SELECT 1').get();
      await database.customStatement(
        '''
      INSERT INTO find_records (
        log_number, record_method, created_at, updated_at,
        discovery_date_source, discovery_date_approximate, location_source
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
        [
          'FO-000001',
          'manual',
          DateTime(2026).millisecondsSinceEpoch ~/ 1000,
          DateTime(2026).millisecondsSinceEpoch ~/ 1000,
          'unknown',
          0,
          'unknown',
        ],
      );
      await database.customStatement(
        '''
      INSERT INTO find_photos (
        find_record_id, path, role, source, created_at,
        is_original_evidence, sort_order
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''',
        [
          1,
          '/private/var/mobile/Containers/Data/Application/OLD/Documents/'
              'find_catalogue_media/originals/discovery.jpg',
          'discovery',
          'camera',
          DateTime(2026).millisecondsSinceEpoch ~/ 1000,
          1,
          0,
        ],
      );
      await database.customStatement(
        'ALTER TABLE find_records DROP COLUMN timeline_from_year',
      );
      await database.customStatement(
        'ALTER TABLE find_records DROP COLUMN timeline_to_year',
      );
      await database.customStatement('PRAGMA user_version = 1');
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      final records = await database.select(database.findRecords).get();
      final photos = await database.select(database.findPhotos).get();

      expect(records, hasLength(1));
      expect(records.single.logNumber, 'FO-000001');
      expect(records.single.timelineFromYear, isNull);
      expect(records.single.timelineToYear, isNull);
      expect(
        photos.single.path,
        'find_catalogue_media/originals/discovery.jpg',
      );

      await database.close();
      await directory.delete(recursive: true);
    },
  );
}
