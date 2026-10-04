import 'dart:convert';
import 'dart:io';

import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/record_export_service.dart';
import 'package:find_catalogue/services/sharing/share_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('Summary and Full Record PDFs produce valid documents', () async {
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

  test('shared document artifacts retain format and filenames', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_catalogue_shared_documents_',
    );
    try {
      final exporter = RecordExportService(
        shareFileStore: ShareFileStore(
          temporaryDirectoryProvider: () async => directory,
        ),
      );

      final csv = await exporter.prepareShareArtifact(
        [_record(1)],
        format: RecordExportFormat.csv,
        findspotPrecision: FindspotExportPrecision.hidden,
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

      expect(csv.fileName, startsWith('find_records_'));
      expect(csv.fileName, endsWith('.csv'));
      expect(csv.mimeType, 'text/csv');
      expect((await File(csv.path).readAsBytes()).take(3), [0xEF, 0xBB, 0xBF]);
      expect(summary.fileName, 'Find_Catalogue_FO-000001_Summary.pdf');
      expect(full.fileName, 'Find_Catalogue_2_Records_Full_Record.pdf');
      expect(summary.mimeType, 'application/pdf');
      expect(full.mimeType, 'application/pdf');
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

FindRecord _record(int id, {String identification = 'Harness fitting'}) {
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
    material: 'Copper alloy',
    confidence: IdentificationConfidence.probable,
    timelineFromYear: -50,
    timelineToYear: 100,
    lengthMm: 25,
    widthMm: 14,
    heightMm: null,
    diameterMm: null,
    thicknessMm: 2,
    weightG: 8.5,
    observations: 'Regular diagonal grooves survive on the edge.',
    researchNotes: 'Compared with a museum catalogue entry.',
    sources: 'Example catalogue, p. 10',
    storageLocation: 'Finds box 2',
    photos: const [],
  );
}
