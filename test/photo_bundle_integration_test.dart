import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:find_catalogue/data/app_database.dart';
import 'package:find_catalogue/data/find_repository.dart';
import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/find_record_service.dart';
import 'package:find_catalogue/services/media_store.dart';
import 'package:find_catalogue/services/record_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  test('a preserved record photo survives through PDF bundle export', () async {
    final root = await Directory.systemTemp.createTemp(
      'find_catalogue_bundle_integration_',
    );
    final database = AppDatabase(NativeDatabase.memory());
    try {
      final documents = Directory('${root.path}/current/Documents');
      await documents.create(recursive: true);
      final pickedFile = File('${root.path}/picked.jpg');
      final pickedImage = image.Image(width: 3, height: 2)
        ..exif.gpsIfd.setGpsLocation(latitude: 10, longitude: 20);
      await pickedFile.writeAsBytes(image.encodeJpg(pickedImage));

      final mediaStore = LocalMediaStore(
        documentsDirectory: documents,
        random: Random(1),
      );
      final repository = DriftFindRepository(
        database,
        resolvePhotoPath: mediaStore.resolvePath,
      );
      final record =
          await FindRecordService(
            repository: repository,
            mediaStore: mediaStore,
          ).create(_draft(), [
            PhotoDraft(
              path: pickedFile.path,
              role: FindPhotoRole.discovery,
              source: FindPhotoSource.camera,
              createdAt: DateTime(2026),
              isOriginalEvidence: true,
              sortOrder: 0,
            ),
          ]);

      expect(record.photos.single.path, startsWith(documents.path));
      expect(File(record.photos.single.path).existsSync(), isTrue);

      final bundle = await RecordExportService().buildBundle([
        record,
      ], findspotPrecision: FindspotExportPrecision.hidden);
      final archive = ZipDecoder().decodeBytes(bundle);
      final photo = archive.files.singleWhere(
        (file) => file.name.startsWith('photos/FO-000001/'),
      );
      final sharedImage = image.decodeJpg(photo.content)!;

      expect(
        archive.files.map((file) => file.name),
        contains('find_records.pdf'),
      );
      expect(sharedImage.exif.gpsIfd.hasGPSLatitude, isFalse);
      expect(sharedImage.exif.gpsIfd.hasGPSLongitude, isFalse);
    } finally {
      await database.close();
      await root.delete(recursive: true);
    }
  });
}

FindDraft _draft() => const FindDraft(
  method: FindRecordMethod.instant,
  discoveredAt: null,
  discoveryDateSource: FieldSource.unknown,
  discoveryDateApproximate: false,
  location: null,
  preferredIdentification: 'Synthetic test object',
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
);
