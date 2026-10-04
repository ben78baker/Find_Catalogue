import 'dart:convert';
import 'dart:typed_data';

import '../domain/find_record.dart';
import '../ui/formatters.dart';
import 'sharing/find_pdf_generator.dart';
import 'sharing/findspot_export_precision.dart';
import 'sharing/share_artifact.dart';
import 'sharing/share_file_store.dart';

export 'sharing/findspot_export_precision.dart';

enum RecordExportFormat { csv, pdfSummary, pdfFullRecord }

class RecordExportService {
  RecordExportService({
    ShareFileStore? shareFileStore,
    FindPdfGenerator? findPdfGenerator,
  }) : _shareFileStore = shareFileStore ?? ShareFileStore(),
       _findPdfGenerator = findPdfGenerator ?? FindPdfGenerator();

  final ShareFileStore _shareFileStore;
  final FindPdfGenerator _findPdfGenerator;

  String buildCsv(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
  }) {
    final rows = <List<String>>[
      const [
        'Log number',
        'Identification',
        'Material',
        'Confidence',
        'Timeline from',
        'Timeline to',
        'Discovery date',
        'Discovery date approximate',
        'Latitude',
        'Longitude',
        'Location accuracy metres',
        'Length mm',
        'Width mm',
        'Height mm',
        'Diameter mm',
        'Thickness mm',
        'Weight g',
        'Observations',
        'Research notes',
        'Sources',
        'Storage location',
      ],
      ...records.map((record) {
        final shareExact = findspotPrecision == FindspotExportPrecision.exact;
        return [
          record.logNumber,
          record.displayTitle,
          record.material,
          enumLabel(record.confidence),
          _value(record.timelineFromYear),
          _value(record.timelineToYear),
          record.discoveredAt?.toIso8601String() ?? '',
          record.discoveryDateApproximate ? 'Yes' : 'No',
          shareExact ? _value(record.location?.latitude) : '',
          shareExact ? _value(record.location?.longitude) : '',
          shareExact ? _value(record.location?.horizontalAccuracy) : '',
          _value(record.lengthMm),
          _value(record.widthMm),
          _value(record.heightMm),
          _value(record.diameterMm),
          _value(record.thicknessMm),
          _value(record.weightG),
          record.observations,
          record.researchNotes,
          record.sources,
          record.storageLocation,
        ];
      }),
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }

  Future<Uint8List> buildSummaryPdf(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
    bool compress = true,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) => _findPdfGenerator.buildSummary(
    records,
    findspotPrecision: findspotPrecision,
    compress: compress,
    onProgress: onProgress,
    isCancelled: isCancelled,
  );

  Future<Uint8List> buildFullRecordPdf(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
    bool compress = true,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) => _findPdfGenerator.buildFullRecord(
    records,
    findspotPrecision: findspotPrecision,
    compress: compress,
    onProgress: onProgress,
    isCancelled: isCancelled,
  );

  Future<ShareArtifact> prepareShareArtifact(
    List<FindRecord> records, {
    required RecordExportFormat format,
    required FindspotExportPrecision findspotPrecision,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one record is required.');
    }
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final extension = format == RecordExportFormat.csv ? 'csv' : 'pdf';
    final mimeType = format == RecordExportFormat.csv
        ? 'text/csv'
        : 'application/pdf';
    late final List<int> bytes;
    if (format == RecordExportFormat.csv) {
      final csv = buildCsv(records, findspotPrecision: findspotPrecision);
      bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)];
    } else if (format == RecordExportFormat.pdfSummary) {
      bytes = await buildSummaryPdf(
        records,
        findspotPrecision: findspotPrecision,
        onProgress: onProgress,
        isCancelled: isCancelled,
      );
    } else {
      bytes = await buildFullRecordPdf(
        records,
        findspotPrecision: findspotPrecision,
        onProgress: onProgress,
        isCancelled: isCancelled,
      );
    }

    return _shareFileStore.writeArtifact(
      fileName: _artifactFileName(records, format, timestamp, extension),
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  String _value(Object? value) => value?.toString() ?? '';

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  String _safeFileName(String value) {
    final safe = value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    return safe.isEmpty ? 'photo' : safe;
  }

  String _artifactFileName(
    List<FindRecord> records,
    RecordExportFormat format,
    String timestamp,
    String extension,
  ) {
    final descriptor = switch (format) {
      RecordExportFormat.pdfSummary => 'Summary',
      RecordExportFormat.pdfFullRecord => 'Full_Record',
      RecordExportFormat.csv => null,
    };
    if (descriptor == null) return 'find_records_$timestamp.$extension';
    final recordPart = records.length == 1
        ? _safeFileName(records.single.logNumber)
        : '${records.length}_Records';
    return 'Find_Catalogue_${recordPart}_$descriptor.$extension';
  }
}
