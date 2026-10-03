import 'dart:io';

import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/record_export_service.dart';
import 'package:find_catalogue/services/sharing/find_share_card_generator.dart';
import 'package:find_catalogue/services/sharing/find_share_workflow.dart';
import 'package:find_catalogue/services/sharing/share_artifact.dart';
import 'package:find_catalogue/services/sharing/share_dispatcher.dart';
import 'package:find_catalogue/services/sharing/share_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test('zero, one, or four photos each produce exactly one card', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_share_workflow_photo_counts_',
    );
    try {
      final workflow = _workflow(directory);
      final records = [
        _record(1),
        _record(2, photos: [_photo(1, 'primary.jpg', 0)]),
        _record(
          3,
          photos: [
            _photo(1, 'primary.jpg', 0),
            _photo(2, 'reverse.jpg', 1),
            _photo(3, 'edge.jpg', 2),
            _photo(4, 'detail.jpg', 3),
          ],
        ),
      ];

      for (final record in records) {
        final artifacts = await workflow.prepare([
          record,
        ], options: const FindShareOptions());

        expect(artifacts, hasLength(1));
        expect(
          artifacts.single.fileName,
          '01_${record.logNumber}_share_card.png',
        );
        expect(artifacts.single.mimeType, 'image/png');
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test(
    'multiple records preserve card order without photo artifacts',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_workflow_order_',
      );
      try {
        final records = [
          _record(
            7,
            photos: [
              _photo(1, 'primary_7.jpg', 0),
              _photo(2, 'reverse_7.jpg', 1),
            ],
          ),
          _record(3),
          _record(
            9,
            photos: [
              _photo(3, 'primary_9.jpg', 0),
              _photo(4, 'detail_9.jpg', 1),
              _photo(5, 'edge_9.jpg', 2),
            ],
          ),
        ];

        final artifacts = await _workflow(
          directory,
        ).prepare(records, options: const FindShareOptions());

        expect(artifacts.map((artifact) => artifact.fileName), [
          '01_FO-000007_share_card.png',
          '02_FO-000003_share_card.png',
          '03_FO-000009_share_card.png',
        ]);
        expect(
          artifacts.every((artifact) => artifact.mimeType == 'image/png'),
          isTrue,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test('cancellation is observed between records', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_share_workflow_cancel_',
    );
    try {
      final cancellationToken = FindShareCancellationToken();
      final generator = _FakeCardGenerator(
        onGenerated: (record) {
          if (record.id == 1) cancellationToken.cancel();
        },
      );
      final progress = <FindShareProgress>[];
      final workflow = _workflow(directory, cardGenerator: generator);

      await expectLater(
        workflow.prepare(
          [_record(1), _record(2)],
          options: const FindShareOptions(),
          cancellationToken: cancellationToken,
          onProgress: progress.add,
        ),
        throwsA(isA<FindSharePreparationCancelled>()),
      );

      expect(generator.generatedIds, [1]);
      expect(progress.any((item) => item.completedRecords == 1), isTrue);
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('legacy formats map to the unchanged record exporters', () async {
    final directory = await Directory.systemTemp.createTemp(
      'find_share_workflow_legacy_',
    );
    try {
      final exporter = _TrackingRecordExportService();
      final fileStore = ShareFileStore(
        temporaryDirectoryProvider: () async => directory,
      );
      final workflow = FindShareWorkflow(
        cardGenerator: _FakeCardGenerator(),
        recordExportService: exporter,
        shareFileStore: fileStore,
      );

      for (final format in const [
        FindShareFormat.pdf,
        FindShareFormat.pdfPhotos,
        FindShareFormat.csv,
      ]) {
        await workflow.prepare(
          [_record(1)],
          options: FindShareOptions(
            format: format,
            findspotPrecision: FindspotExportPrecision.exact,
          ),
        );
      }

      expect(exporter.formats, [
        RecordExportFormat.pdf,
        RecordExportFormat.pdfBundle,
        RecordExportFormat.csv,
      ]);
      expect(exporter.precisions, everyElement(FindspotExportPrecision.exact));
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('prepared Share Cards are dispatched together in order', () async {
    ShareParams? captured;
    final directory = await Directory.systemTemp.createTemp(
      'find_share_workflow_dispatch_',
    );
    try {
      final workflow = _workflow(
        directory,
        shareDispatcher: ShareDispatcher(
          shareInvoker: (parameters) async {
            captured = parameters;
            return const ShareResult('test', ShareResultStatus.success);
          },
        ),
      );
      const artifacts = [
        ShareArtifact(
          path: '/tmp/first.png',
          fileName: 'first.png',
          mimeType: 'image/png',
        ),
        ShareArtifact(
          path: '/tmp/second.png',
          fileName: 'second.png',
          mimeType: 'image/png',
        ),
      ];

      await workflow.dispatch(
        artifacts,
        records: [_record(1), _record(2)],
        options: const FindShareOptions(),
      );

      expect(captured!.files!.map((file) => file.name), [
        'first.png',
        'second.png',
      ]);
      expect(captured!.subject, 'Find Catalogue Share Cards');
      expect(captured!.text, '2 Find Catalogue Share Cards.');
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

FindShareWorkflow _workflow(
  Directory directory, {
  FindShareCardGenerator? cardGenerator,
  ShareDispatcher? shareDispatcher,
}) {
  final fileStore = ShareFileStore(
    temporaryDirectoryProvider: () async => directory,
  );
  return FindShareWorkflow(
    cardGenerator: cardGenerator ?? _FakeCardGenerator(),
    shareDispatcher: shareDispatcher,
    shareFileStore: fileStore,
  );
}

class _FakeCardGenerator extends FindShareCardGenerator {
  _FakeCardGenerator({this.onGenerated});

  final void Function(FindRecord record)? onGenerated;
  final generatedIds = <int>[];

  @override
  Future<ShareArtifact> generateToSession(
    FindRecord record, {
    required ShareFileSession session,
    required int sequence,
  }) async {
    generatedIds.add(record.id);
    onGenerated?.call(record);
    return session.writeArtifact(
      fileName:
          '${sequence.toString().padLeft(2, '0')}_${record.logNumber}_share_card.png',
      mimeType: 'image/png',
      bytes: [record.id],
    );
  }
}

class _TrackingRecordExportService extends RecordExportService {
  final formats = <RecordExportFormat>[];
  final precisions = <FindspotExportPrecision>[];

  @override
  Future<ShareArtifact> prepareShareArtifact(
    List<FindRecord> records, {
    required RecordExportFormat format,
    required FindspotExportPrecision findspotPrecision,
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

FindPhoto _photo(int id, String path, int sortOrder) => FindPhoto(
  id: id,
  path: path,
  role: FindPhotoRole.front,
  source: FindPhotoSource.camera,
  createdAt: DateTime(2026, 8, 20),
  isOriginalEvidence: true,
  sortOrder: sortOrder,
);

FindRecord _record(int id, {List<FindPhoto> photos = const []}) {
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
    location: null,
    preferredIdentification: 'Test find',
    material: 'Copper alloy',
    confidence: IdentificationConfidence.probable,
    timelineFromYear: 1200,
    timelineToYear: 1400,
    lengthMm: 20,
    widthMm: 14,
    heightMm: null,
    diameterMm: null,
    thicknessMm: 2,
    weightG: 8.5,
    observations: 'Test observation.',
    researchNotes: '',
    sources: '',
    storageLocation: '',
    photos: photos,
  );
}
