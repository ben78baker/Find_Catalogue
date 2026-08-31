import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'data/find_repository.dart';
import 'services/find_record_service.dart';
import 'services/location_capture_service.dart';
import 'services/media_store.dart';
import 'services/photo_capture_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mediaStore = await LocalMediaStore.create();
  final database = AppDatabase.defaults();
  final repository = DriftFindRepository(
    database,
    resolvePhotoPath: mediaStore.resolvePath,
  );
  final photoCaptureService = ImagePickerPhotoCaptureService();
  final locationCaptureService = DeviceLocationCaptureService();
  final recordService = FindRecordService(
    repository: repository,
    mediaStore: mediaStore,
  );

  runApp(
    FindCatalogueApp(
      repository: repository,
      recordService: recordService,
      photoCaptureService: photoCaptureService,
      locationCaptureService: locationCaptureService,
    ),
  );
}
