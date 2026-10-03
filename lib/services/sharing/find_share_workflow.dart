import 'dart:ui' show Rect;

import 'package:path/path.dart' as path;

import '../../domain/find_record.dart';
import '../record_export_service.dart';
import 'find_share_card_generator.dart';
import 'share_artifact.dart';
import 'share_dispatcher.dart';
import 'share_file_store.dart';
import 'share_photo_processor.dart';

enum FindShareFormat { shareCard, pdf, pdfPhotos, csv }

class FindShareOptions {
  const FindShareOptions({
    this.format = FindShareFormat.shareCard,
    this.includeAllPhotos = false,
    this.findspotPrecision = FindspotExportPrecision.hidden,
  });

  final FindShareFormat format;
  final bool includeAllPhotos;
  final FindspotExportPrecision findspotPrecision;

  bool get needsFindspotChoice =>
      format != FindShareFormat.shareCard || includeAllPhotos;
}

class FindShareProgress {
  const FindShareProgress({
    required this.completedRecords,
    required this.totalRecords,
    required this.message,
  });

  final int completedRecords;
  final int totalRecords;
  final String message;

  double get fraction =>
      totalRecords == 0 ? 0 : (completedRecords / totalRecords).clamp(0, 1);
}

class FindShareCancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const FindSharePreparationCancelled();
  }
}

class FindSharePreparationCancelled implements Exception {
  const FindSharePreparationCancelled();

  @override
  String toString() => 'Share preparation was cancelled.';
}

class FindSharePreparationException implements Exception {
  const FindSharePreparationException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef FindShareProgressCallback = void Function(FindShareProgress progress);

class FindShareWorkflow {
  factory FindShareWorkflow({
    FindShareCardGenerator? cardGenerator,
    RecordExportService? recordExportService,
    ShareDispatcher? shareDispatcher,
    ShareFileStore? shareFileStore,
    SharePhotoProcessor? sharePhotoProcessor,
  }) {
    final fileStore = shareFileStore ?? ShareFileStore();
    return FindShareWorkflow._(
      cardGenerator ?? FindShareCardGenerator(fileStore: fileStore),
      recordExportService ?? RecordExportService(),
      shareDispatcher ?? ShareDispatcher(),
      fileStore,
      sharePhotoProcessor ?? const SharePhotoProcessor(),
    );
  }

  const FindShareWorkflow._(
    this._cardGenerator,
    this._recordExportService,
    this._shareDispatcher,
    this._shareFileStore,
    this._sharePhotoProcessor,
  );

  final FindShareCardGenerator _cardGenerator;
  final RecordExportService _recordExportService;
  final ShareDispatcher _shareDispatcher;
  final ShareFileStore _shareFileStore;
  final SharePhotoProcessor _sharePhotoProcessor;

  static int additionalPhotoCount(List<FindRecord> records) => records.fold(
    0,
    (total, record) =>
        total + (record.photos.length > 1 ? record.photos.length - 1 : 0),
  );

  Future<List<ShareArtifact>> prepare(
    List<FindRecord> records, {
    required FindShareOptions options,
    FindShareProgressCallback? onProgress,
    FindShareCancellationToken? cancellationToken,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one find record is required.');
    }
    onProgress?.call(
      FindShareProgress(
        completedRecords: 0,
        totalRecords: records.length,
        message: options.format == FindShareFormat.shareCard
            ? 'Preparing Share Card 1 of ${records.length}'
            : 'Preparing shared records',
      ),
    );

    if (options.format != FindShareFormat.shareCard) {
      cancellationToken?.throwIfCancelled();
      final artifact = await _recordExportService.prepareShareArtifact(
        records,
        format: _recordExportFormat(options.format),
        findspotPrecision: options.findspotPrecision,
      );
      onProgress?.call(
        FindShareProgress(
          completedRecords: records.length,
          totalRecords: records.length,
          message: 'Shared file ready',
        ),
      );
      return [artifact];
    }

    await _shareFileStore.deleteStaleSessions();
    final session = await _shareFileStore.createSession(
      prefix: 'find_share_operation_',
    );
    final artifacts = <ShareArtifact>[];
    for (final entry in records.indexed) {
      cancellationToken?.throwIfCancelled();
      final recordIndex = entry.$1;
      final record = entry.$2;
      onProgress?.call(
        FindShareProgress(
          completedRecords: recordIndex,
          totalRecords: records.length,
          message:
              'Preparing Share Card ${recordIndex + 1} of ${records.length}',
        ),
      );
      artifacts.add(
        await _cardGenerator.generateToSession(
          record,
          session: session,
          sequence: recordIndex + 1,
        ),
      );

      if (options.includeAllPhotos) {
        for (final photoEntry in record.photos.skip(1).indexed) {
          final photo = photoEntry.$2;
          late final ProcessedSharePhoto processed;
          try {
            processed = await _sharePhotoProcessor.process(
              photo.path,
              findspotPrecision: options.findspotPrecision,
            );
          } on SharePhotoProcessingException catch (error) {
            throw FindSharePreparationException(
              '${record.logNumber} photograph ${photoEntry.$1 + 2} '
              'could not be prepared: ${error.message}',
            );
          }
          final recordPrefix = (recordIndex + 1).toString().padLeft(2, '0');
          final photoPrefix = (photoEntry.$1 + 2).toString().padLeft(2, '0');
          final sourceName = path.basenameWithoutExtension(photo.path);
          final fileName = [
            recordPrefix,
            _safeFileComponent(record.logNumber),
            photoPrefix,
            _safeFileComponent(photo.role.name),
            _safeFileComponent(sourceName),
          ].join('_');
          artifacts.add(
            await session.writeArtifact(
              fileName: '$fileName${processed.extension}',
              mimeType: processed.mimeType,
              bytes: processed.bytes,
            ),
          );
        }
      }

      onProgress?.call(
        FindShareProgress(
          completedRecords: recordIndex + 1,
          totalRecords: records.length,
          message: recordIndex + 1 == records.length
              ? 'Share files ready'
              : 'Prepared ${recordIndex + 1} of ${records.length} records',
        ),
      );
      cancellationToken?.throwIfCancelled();
    }
    return artifacts;
  }

  Future<void> dispatch(
    List<ShareArtifact> artifacts, {
    required List<FindRecord> records,
    required FindShareOptions options,
    Rect? sharePositionOrigin,
  }) => _shareDispatcher.dispatch(
    artifacts: artifacts,
    subject: options.format == FindShareFormat.shareCard
        ? 'Find Catalogue Share Cards'
        : options.format == FindShareFormat.pdfPhotos
        ? 'Find Catalogue records and photographs'
        : 'Find Catalogue records',
    text: options.format == FindShareFormat.shareCard
        ? '${records.length} Find Catalogue Share '
              'Card${records.length == 1 ? '' : 's'}.'
        : '${records.length} shared find record${records.length == 1 ? '' : 's'}.',
    sharePositionOrigin: sharePositionOrigin,
  );

  RecordExportFormat _recordExportFormat(FindShareFormat format) =>
      switch (format) {
        FindShareFormat.pdf => RecordExportFormat.pdf,
        FindShareFormat.pdfPhotos => RecordExportFormat.pdfBundle,
        FindShareFormat.csv => RecordExportFormat.csv,
        FindShareFormat.shareCard => throw ArgumentError.value(
          format,
          'format',
          'Share Cards are not record exports.',
        ),
      };

  static String _safeFileComponent(String value) {
    final safe = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return safe.isEmpty ? 'photo' : safe;
  }
}
