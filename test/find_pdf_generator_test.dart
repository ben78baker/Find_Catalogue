import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_pdf_generator.dart';
import 'package:find_catalogue/services/sharing/findspot_export_precision.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Uint8List iconBytes;
  setUpAll(() {
    iconBytes = Uint8List.fromList(
      image.encodePng(image.Image(width: 12, height: 12)),
    );
  });

  test(
    'summary creates one valid PDF and prepares only primary photos',
    () async {
      final preparer = _TrackingPhotoPreparer();
      final generator = FindPdfGenerator(
        photoPreparer: preparer,
        assetLoader: (_) async => iconBytes,
      );

      final bytes = await generator.buildSummary(
        [
          _record(1, photoPaths: const ['first.jpg', 'second.jpg']),
          _record(2, photoPaths: const ['third.jpg']),
        ],
        findspotPrecision: FindspotExportPrecision.hidden,
        compress: false,
      );

      expect(utf8.decode(bytes.take(4).toList()), '%PDF');
      expect(bytes.length, greaterThan(1000));
      expect(preparer.paths, ['first.jpg', 'third.jpg']);
      expect(_pdfPageCount(bytes), greaterThanOrEqualTo(1));
    },
  );

  test('full record prepares all photos in record and photo order', () async {
    final preparer = _TrackingPhotoPreparer();
    final generator = FindPdfGenerator(
      photoPreparer: preparer,
      assetLoader: (_) async => iconBytes,
    );

    final bytes = await generator.buildFullRecord(
      [
        _record(1, photoPaths: const ['one.jpg', 'two.jpg']),
        _record(2, photoPaths: const ['three.jpg', 'four.jpg']),
      ],
      findspotPrecision: FindspotExportPrecision.hidden,
      compress: false,
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(preparer.paths, ['one.jpg', 'two.jpg', 'three.jpg', 'four.jpg']);
    expect(_pdfPageCount(bytes), greaterThanOrEqualTo(2));
  });

  test('missing and corrupt photos do not prevent either PDF', () async {
    final directory = await Directory.systemTemp.createTemp('find_pdf_bad_');
    try {
      final corrupt = File('${directory.path}/corrupt.jpg');
      await corrupt.writeAsString('not an image');
      final generator = FindPdfGenerator(assetLoader: (_) async => iconBytes);
      final records = [
        _record(1, photoPaths: [corrupt.path, '${directory.path}/missing.jpg']),
      ];

      final summary = await generator.buildSummary(
        records,
        findspotPrecision: FindspotExportPrecision.hidden,
      );
      final full = await generator.buildFullRecord(
        records,
        findspotPrecision: FindspotExportPrecision.hidden,
      );

      expect(utf8.decode(summary.take(4).toList()), '%PDF');
      expect(utf8.decode(full.take(4).toList()), '%PDF');
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('full PDF paginates long text and many photographs', () async {
    final generator = FindPdfGenerator(
      photoPreparer: _TrackingPhotoPreparer(),
      assetLoader: (_) async => iconBytes,
    );
    final record = _record(
      1,
      photoPaths: [for (var index = 0; index < 7; index++) '$index.jpg'],
      longText: true,
    );

    final bytes = await generator.buildFullRecord(
      [record],
      findspotPrecision: FindspotExportPrecision.hidden,
      compress: false,
    );

    expect(_pdfPageCount(bytes), greaterThan(3));
  });

  test(
    'photo preparation strips metadata, resizes and preserves source',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'find_pdf_photo_',
      );
      try {
        final source = image.Image(width: 2000, height: 1000)
          ..setPixelRgb(0, 0, 255, 0, 0)
          ..exif.gpsIfd.setGpsLocation(
            latitude: 51.123456,
            longitude: -1.234567,
          )
          ..textData = {'Comment': 'private metadata'};
        final originalBytes = Uint8List.fromList(image.encodeJpg(source));
        final file = File('${directory.path}/source.jpg');
        await file.writeAsBytes(originalBytes);

        final prepared = await const FindPdfPhotoPreparer().prepare(file.path);
        final decoded = image.decodeJpg(prepared!.bytes)!;

        expect(prepared.width, 1800);
        expect(prepared.height, 900);
        expect(decoded.exif.gpsIfd.hasGPSLatitude, isFalse);
        expect(decoded.exif.gpsIfd.hasGPSLongitude, isFalse);
        expect(decoded.textData, isNull);
        expect(await file.readAsBytes(), originalBytes);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'progress is sequential and cancellation stops between records',
    () async {
      final generator = FindPdfGenerator(
        photoPreparer: _TrackingPhotoPreparer(),
        assetLoader: (_) async => iconBytes,
      );
      final progress = <int>[];
      var cancelled = false;

      expect(
        generator.buildSummary(
          [_record(1), _record(2), _record(3)],
          findspotPrecision: FindspotExportPrecision.hidden,
          onProgress: (completed, total) {
            expect(total, 3);
            progress.add(completed);
            if (completed == 2) cancelled = true;
          },
          isCancelled: () => cancelled,
        ),
        throwsA(isA<FindPdfGenerationCancelledException>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(progress, [1, 2]);
    },
  );
}

class _TrackingPhotoPreparer extends FindPdfPhotoPreparer {
  _TrackingPhotoPreparer();

  final paths = <String>[];

  @override
  Future<PreparedFindPdfPhoto?> prepare(String filePath) async {
    paths.add(filePath);
    final bytes = Uint8List.fromList(
      image.encodeJpg(image.Image(width: 16, height: 10)),
    );
    return PreparedFindPdfPhoto(bytes: bytes, width: 16, height: 10);
  }
}

FindRecord _record(
  int id, {
  List<String> photoPaths = const [],
  bool longText = false,
}) {
  final notes = longText ? List.filled(1200, 'catalogue detail').join(' ') : '';
  return FindRecord(
    id: id,
    logNumber: 'FO-${id.toString().padLeft(6, '0')}',
    method: FindRecordMethod.manual,
    createdAt: DateTime(2026, 8, 20),
    updatedAt: DateTime(2026, 8, 21),
    discoveredAt: DateTime(2026, 8, 20),
    discoveryDateSource: FieldSource.manuallyEntered,
    discoveryDateApproximate: false,
    location: const FindLocation(
      latitude: 51.123456,
      longitude: -1.234567,
      horizontalAccuracy: 4.2,
      source: FieldSource.manuallyEntered,
    ),
    preferredIdentification: 'Harness fitting $id',
    material: 'Copper alloy',
    confidence: IdentificationConfidence.probable,
    timelineFromYear: 50,
    timelineToYear: 150,
    lengthMm: 25,
    widthMm: 14,
    heightMm: null,
    diameterMm: null,
    thicknessMm: 2,
    weightG: 8.5,
    observations: longText ? notes : 'Diagonal grooves survive on the edge.',
    researchNotes: notes,
    sources: longText ? notes : 'Example catalogue, p. 10',
    storageLocation: 'Finds box 2',
    photos: [
      for (final entry in photoPaths.indexed)
        FindPhoto(
          id: entry.$1 + 1,
          path: entry.$2,
          role: entry.$1 == 0 ? FindPhotoRole.front : FindPhotoRole.detail,
          source: FindPhotoSource.camera,
          createdAt: DateTime(2026, 8, 20),
          isOriginalEvidence: true,
          sortOrder: entry.$1,
        ),
    ],
  );
}

int _pdfPageCount(List<int> bytes) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;
