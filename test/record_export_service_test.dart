import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/record_export_service.dart';
import 'package:find_catalogue/services/sharing/share_dispatcher.dart';
import 'package:find_catalogue/services/sharing/share_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:share_plus/share_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final exporter = RecordExportService();

  test('CSV exports multiple records and escapes editable text', () {
    final csv = exporter.buildCsv([
      _record(1, identification: 'Coin, hammered'),
      _record(2, identification: 'Button "gilt"'),
    ], findspotPrecision: FindspotExportPrecision.hidden);

    expect(csv, contains('"FO-000001"'));
    expect(csv, contains('"FO-000002"'));
    expect(csv, contains('"Coin, hammered"'));
    expect(csv, contains('"Button ""gilt"""'));
  });

  test('CSV hides coordinates unless exact findspots are chosen', () {
    final record = _record(1);
    final hidden = exporter.buildCsv([
      record,
    ], findspotPrecision: FindspotExportPrecision.hidden);
    final exact = exporter.buildCsv([
      record,
    ], findspotPrecision: FindspotExportPrecision.exact);

    expect(hidden, isNot(contains('51.123456')));
    expect(hidden, isNot(contains('-1.234567')));
    expect(exact, contains('51.123456'));
    expect(exact, contains('-1.234567'));
  });

  test('PDF export produces a valid document for multiple records', () async {
    final bytes = await exporter.buildPdf([
      _record(1),
      _record(2),
    ], findspotPrecision: FindspotExportPrecision.hidden);

    expect(bytes.length, greaterThan(1000));
    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
  });

  test('PDF flows compact records together and paginates when full', () async {
    final records = [
      for (var id = 1; id <= 8; id++) _record(id, compact: true),
    ];
    final firstPageBytes = await exporter.buildPdf(
      records.take(3).toList(),
      findspotPrecision: FindspotExportPrecision.hidden,
      compress: false,
    );
    final overflowBytes = await exporter.buildPdf(
      records,
      findspotPrecision: FindspotExportPrecision.hidden,
      compress: false,
    );

    expect(_pdfPageCount(firstPageBytes), 1);
    expect(_pdfPageCount(overflowBytes), greaterThan(1));
  });

  test('Summary and Full Record PDF exports produce valid documents', () async {
    final summary = await exporter.buildSummaryPdf([
      _record(1),
      _record(2),
    ], findspotPrecision: FindspotExportPrecision.hidden);
    final full = await exporter.buildFullRecordPdf([
      _record(1),
      _record(2),
    ], findspotPrecision: FindspotExportPrecision.hidden);

    expect(utf8.decode(summary.take(4).toList()), '%PDF');
    expect(utf8.decode(full.take(4).toList()), '%PDF');
    expect(summary.length, greaterThan(1000));
    expect(full.length, greaterThan(1000));
  });

  test('new PDF artifacts use descriptive stable filenames', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_catalogue_pdf_names_',
    );
    try {
      final exporter = RecordExportService(
        shareFileStore: ShareFileStore(
          temporaryDirectoryProvider: () async => directory,
        ),
      );

      final summary = await exporter.prepareShareArtifact(
        [_record(1)],
        format: RecordExportFormat.pdfSummary,
        findspotPrecision: FindspotExportPrecision.hidden,
      );
      final full = await exporter.prepareShareArtifact(
        [_record(1), _record(2)],
        format: RecordExportFormat.pdfFullRecord,
        findspotPrecision: FindspotExportPrecision.hidden,
      );

      expect(summary.fileName, 'Find_Catalogue_FO-000001_Summary.pdf');
      expect(full.fileName, 'Find_Catalogue_2_Records_Full_Record.pdf');
      expect(summary.mimeType, 'application/pdf');
      expect(full.mimeType, 'application/pdf');
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('hidden-location bundle strips photo GPS metadata', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_catalogue_bundle_',
    );
    try {
      final photoFile = File('${directory.path}/original front.jpg');
      final sourceImage = image.Image(width: 2, height: 2)
        ..setPixelRgb(0, 0, 255, 0, 0)
        ..exif.gpsIfd.setGpsLocation(latitude: 51.123456, longitude: -1.234567);
      await photoFile.writeAsBytes(image.encodeJpg(sourceImage));
      final record = _record(1, photos: [_photo(photoFile.path)]);

      final bytes = await exporter.buildBundle([
        record,
      ], findspotPrecision: FindspotExportPrecision.hidden);
      final archive = ZipDecoder().decodeBytes(bytes);
      final files = {for (final file in archive.files) file.name: file};
      final exported = files['photos/FO-000001/01_front_original_front.jpg']!;
      final exportedImage = image.decodeJpg(exported.content)!;
      final readme = utf8.decode(files['README.txt']!.content);

      expect(files, contains('find_records.pdf'));
      expect(exportedImage.exif.gpsIfd.hasGPSLatitude, isFalse);
      expect(exportedImage.exif.gpsIfd.hasGPSLongitude, isFalse);
      expect(readme, contains('embedded metadata removed'));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('exact-location bundle preserves original photo bytes', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_catalogue_bundle_',
    );
    try {
      final photoFile = File('${directory.path}/original front.jpg');
      final sourceImage = image.Image(width: 2, height: 2)
        ..exif.gpsIfd.setGpsLocation(latitude: 51.123456, longitude: -1.234567);
      final photoBytes = image.encodeJpg(sourceImage);
      await photoFile.writeAsBytes(photoBytes);
      final record = _record(1, photos: [_photo(photoFile.path)]);

      final bytes = await exporter.buildBundle([
        record,
      ], findspotPrecision: FindspotExportPrecision.exact);
      final archive = ZipDecoder().decodeBytes(bytes);
      final files = {for (final file in archive.files) file.name: file};
      final readme = utf8.decode(files['README.txt']!.content);

      expect(
        files['photos/FO-000001/01_front_original_front.jpg']!.content,
        photoBytes,
      );
      expect(readme, contains('Untouched original photographs included: 1'));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('photo bundle fails visibly when every recorded file is missing', () {
    final record = _record(
      1,
      photos: [_photo('/definitely/missing/discovery.jpg')],
    );

    expect(
      exporter.buildBundle([
        record,
      ], findspotPrecision: FindspotExportPrecision.hidden),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'share delegates a prepared artifact to an injected dispatcher',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'find_catalogue_share_',
      );
      try {
        ShareParams? captured;
        final exporter = RecordExportService(
          shareDispatcher: ShareDispatcher(
            shareInvoker: (parameters) async {
              captured = parameters;
              return const ShareResult('test', ShareResultStatus.success);
            },
          ),
          shareFileStore: ShareFileStore(
            temporaryDirectoryProvider: () async => directory,
          ),
        );

        await exporter.share(
          [_record(1)],
          format: RecordExportFormat.csv,
          findspotPrecision: FindspotExportPrecision.hidden,
        );

        expect(captured, isNotNull);
        expect(captured!.files, hasLength(1));
        final file = File(captured!.files!.single.path);
        expect(file.path, startsWith(directory.path));
        expect(file.path, endsWith('.csv'));
        expect((await file.readAsBytes()).take(3), [0xEF, 0xBB, 0xBF]);
        expect(captured!.files!.single.mimeType, 'text/csv');
        expect(captured!.subject, 'Find Catalogue records');
        expect(captured!.text, '1 shared find record.');
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}

FindPhoto _photo(String photoPath) => FindPhoto(
  id: 1,
  path: photoPath,
  role: FindPhotoRole.front,
  source: FindPhotoSource.camera,
  createdAt: DateTime(2026, 8, 20),
  isOriginalEvidence: true,
  sortOrder: 0,
);

FindRecord _record(
  int id, {
  String identification = 'Harness fitting',
  List<FindPhoto> photos = const [],
  bool compact = false,
}) {
  final now = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: id,
    logNumber: 'FO-${id.toString().padLeft(6, '0')}',
    method: FindRecordMethod.manual,
    createdAt: now,
    updatedAt: now,
    discoveredAt: DateTime(2026, 8, 20),
    discoveryDateSource: FieldSource.manuallyEntered,
    discoveryDateApproximate: false,
    location: const FindLocation(
      latitude: 51.123456,
      longitude: -1.234567,
      horizontalAccuracy: 4.2,
      source: FieldSource.manuallyEntered,
    ),
    preferredIdentification: identification,
    material: compact ? '' : 'Copper alloy',
    confidence: IdentificationConfidence.probable,
    timelineFromYear: -50,
    timelineToYear: 100,
    lengthMm: compact ? null : 25,
    widthMm: compact ? null : 14,
    heightMm: null,
    diameterMm: null,
    thicknessMm: compact ? null : 2,
    weightG: compact ? null : 8.5,
    observations: compact
        ? ''
        : 'Regular diagonal grooves survive on the edge.',
    researchNotes: compact ? '' : 'Compared with a museum catalogue entry.',
    sources: compact ? '' : 'Example catalogue, p. 10',
    storageLocation: compact ? '' : 'Finds box 2',
    photos: photos,
  );
}

int _pdfPageCount(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;
