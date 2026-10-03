import 'dart:ui' show Rect;

import '../../domain/find_record.dart';
import '../record_export_service.dart';
import 'share_artifact.dart';
import 'share_dispatcher.dart';

enum FindExportFormat { csv, pdfPhotos }

class FindExportOptions {
  const FindExportOptions({
    this.format = FindExportFormat.csv,
    this.findspotPrecision = FindspotExportPrecision.hidden,
  });

  final FindExportFormat format;
  final FindspotExportPrecision findspotPrecision;
}

class FindExportWorkflow {
  FindExportWorkflow({
    RecordExportService? recordExportService,
    ShareDispatcher? shareDispatcher,
  }) : _recordExportService = recordExportService ?? RecordExportService(),
       _shareDispatcher = shareDispatcher ?? ShareDispatcher();

  final RecordExportService _recordExportService;
  final ShareDispatcher _shareDispatcher;

  Future<ShareArtifact> prepare(
    List<FindRecord> records, {
    required FindExportOptions options,
  }) {
    if (records.isEmpty) {
      throw ArgumentError('At least one find record is required.');
    }
    return _recordExportService.prepareShareArtifact(
      records,
      format: switch (options.format) {
        FindExportFormat.csv => RecordExportFormat.csv,
        FindExportFormat.pdfPhotos => RecordExportFormat.pdfBundle,
      },
      findspotPrecision: options.findspotPrecision,
    );
  }

  Future<void> dispatch(
    ShareArtifact artifact, {
    required List<FindRecord> records,
    required FindExportOptions options,
    Rect? sharePositionOrigin,
  }) => _shareDispatcher.dispatch(
    artifacts: [artifact],
    subject: options.format == FindExportFormat.pdfPhotos
        ? 'Find Catalogue PDF and photos export'
        : 'Find Catalogue CSV export',
    text:
        '${records.length} exported find record${records.length == 1 ? '' : 's'}.',
    sharePositionOrigin: sharePositionOrigin,
  );
}
