import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/record_export_service.dart';
import 'package:find_catalogue/services/sharing/find_export_workflow.dart';
import 'package:find_catalogue/services/sharing/find_pdf_generator.dart';
import 'package:find_catalogue/services/sharing/share_artifact.dart';
import 'package:find_catalogue/services/sharing/share_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test('CSV and PDF plus photos remain available through Export', () async {
    final service = _TrackingExportService();
    final workflow = FindExportWorkflow(recordExportService: service);

    await workflow.prepare([_record(1)], options: const FindExportOptions());
    await workflow.prepare(
      [_record(1), _record(2)],
      options: const FindExportOptions(
        format: FindExportFormat.pdfPhotos,
        findspotPrecision: FindspotExportPrecision.exact,
      ),
    );

    expect(service.formats, [
      RecordExportFormat.csv,
      RecordExportFormat.pdfBundle,
    ]);
    expect(service.precisions, [
      FindspotExportPrecision.hidden,
      FindspotExportPrecision.exact,
    ]);
  });

  test(
    'prepared export artifact is dispatched through ShareDispatcher',
    () async {
      ShareParams? captured;
      final workflow = FindExportWorkflow(
        recordExportService: _TrackingExportService(),
        shareDispatcher: ShareDispatcher(
          shareInvoker: (parameters) async {
            captured = parameters;
            return const ShareResult('test', ShareResultStatus.success);
          },
        ),
      );
      const artifact = ShareArtifact(
        path: '/tmp/find_records.zip',
        fileName: 'find_records.zip',
        mimeType: 'application/zip',
      );

      await workflow.dispatch(
        artifact,
        records: [_record(1), _record(2)],
        options: const FindExportOptions(format: FindExportFormat.pdfPhotos),
      );

      expect(captured!.files, hasLength(1));
      expect(captured!.files!.single.name, 'find_records.zip');
      expect(captured!.subject, 'Find Catalogue PDF and photos export');
      expect(captured!.text, '2 exported find records.');
    },
  );
}

class _TrackingExportService extends RecordExportService {
  final formats = <RecordExportFormat>[];
  final precisions = <FindspotExportPrecision>[];

  @override
  Future<ShareArtifact> prepareShareArtifact(
    List<FindRecord> records, {
    required RecordExportFormat format,
    required FindspotExportPrecision findspotPrecision,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) async {
    formats.add(format);
    precisions.add(findspotPrecision);
    return ShareArtifact(
      path: '/tmp/export.${format.name}',
      fileName: 'export.${format.name}',
      mimeType: 'application/octet-stream',
    );
  }
}

FindRecord _record(int id) => FindRecord(
  id: id,
  logNumber: 'FO-${id.toString().padLeft(6, '0')}',
  method: FindRecordMethod.manual,
  createdAt: DateTime(2026, 8, 20),
  updatedAt: DateTime(2026, 8, 20),
  discoveredAt: null,
  discoveryDateSource: FieldSource.unknown,
  discoveryDateApproximate: false,
  location: null,
  preferredIdentification: 'Test find',
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
  photos: const [],
);
