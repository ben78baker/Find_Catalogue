import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/find_record.dart';
import 'find_pdf_record_factory.dart';
import 'findspot_export_precision.dart';

enum FindPdfDocumentKind { summary, fullRecord }

typedef FindPdfAssetLoader = Future<Uint8List> Function(String assetKey);
typedef FindPdfProgressCallback = void Function(int completed, int total);
typedef FindPdfCancellationCheck = bool Function();

class FindPdfGenerationCancelledException implements Exception {
  const FindPdfGenerationCancelledException();

  @override
  String toString() => 'PDF generation was cancelled.';
}

class PreparedFindPdfPhoto {
  const PreparedFindPdfPhoto({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

/// Decodes, orients, resizes and re-encodes photographs before PDF embedding.
///
/// Re-encoding deliberately removes embedded EXIF/GPS and other metadata even
/// when exact findspots are selected. Exact coordinates belong in the PDF text;
/// source photograph metadata is never required by a human-readable report.
class FindPdfPhotoPreparer {
  const FindPdfPhotoPreparer({this.maximumDimension = 1800});

  final int maximumDimension;

  Future<PreparedFindPdfPhoto?> prepare(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    image.Image? decoded;
    try {
      decoded = image.decodeImage(await file.readAsBytes());
    } catch (_) {
      return null;
    }
    if (decoded == null) return null;

    var prepared = image.bakeOrientation(decoded)
      ..exif.clear()
      ..textData = null
      ..iccProfile = null;
    final longestEdge = math.max(prepared.width, prepared.height);
    if (longestEdge > maximumDimension) {
      if (prepared.width >= prepared.height) {
        prepared = image.copyResize(
          prepared,
          width: maximumDimension,
          interpolation: image.Interpolation.average,
        );
      } else {
        prepared = image.copyResize(
          prepared,
          height: maximumDimension,
          interpolation: image.Interpolation.average,
        );
      }
    }
    prepared
      ..exif.clear()
      ..textData = null
      ..iccProfile = null;
    return PreparedFindPdfPhoto(
      bytes: Uint8List.fromList(image.encodeJpg(prepared, quality: 92)),
      width: prepared.width,
      height: prepared.height,
    );
  }
}

class FindPdfGenerator {
  FindPdfGenerator({
    FindPdfRecordFactory recordFactory = const FindPdfRecordFactory(),
    FindPdfPhotoPreparer photoPreparer = const FindPdfPhotoPreparer(),
    FindPdfAssetLoader? assetLoader,
  }) : _recordFactory = recordFactory,
       _photoPreparer = photoPreparer,
       _assetLoader = assetLoader ?? _loadAsset;

  static const _brandAsset = 'assets/branding/find_catalogue_icon_1024.png';
  static const _olive = PdfColor.fromInt(0xff465e3b);
  static const _warmSurface = PdfColor.fromInt(0xfff7f5ef);
  static const _outline = PdfColor.fromInt(0xffc9c7bf);

  final FindPdfRecordFactory _recordFactory;
  final FindPdfPhotoPreparer _photoPreparer;
  final FindPdfAssetLoader _assetLoader;

  Future<Uint8List> buildSummary(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
    bool compress = true,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) => _build(
    records,
    kind: FindPdfDocumentKind.summary,
    findspotPrecision: findspotPrecision,
    compress: compress,
    onProgress: onProgress,
    isCancelled: isCancelled,
  );

  Future<Uint8List> buildFullRecord(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
    bool compress = true,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) => _build(
    records,
    kind: FindPdfDocumentKind.fullRecord,
    findspotPrecision: findspotPrecision,
    compress: compress,
    onProgress: onProgress,
    isCancelled: isCancelled,
  );

  Future<Uint8List> _build(
    List<FindRecord> records, {
    required FindPdfDocumentKind kind,
    required FindspotExportPrecision findspotPrecision,
    required bool compress,
    FindPdfProgressCallback? onProgress,
    FindPdfCancellationCheck? isCancelled,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one record is required.');
    }
    final icon = pw.MemoryImage(await _preparedBrandIcon());
    final preparedRecords = <_PreparedPdfRecord>[];
    for (final record in records) {
      _throwIfCancelled(isCancelled);
      final data = _recordFactory.create(
        record,
        findspotPrecision: findspotPrecision,
      );
      final photos = <PreparedFindPdfPhoto?>[];
      final selectedPhotos = kind == FindPdfDocumentKind.summary
          ? data.photos.take(1)
          : data.photos;
      for (final photo in selectedPhotos) {
        _throwIfCancelled(isCancelled);
        photos.add(await _photoPreparer.prepare(photo.path));
      }
      preparedRecords.add(_PreparedPdfRecord(data: data, photos: photos));
      onProgress?.call(preparedRecords.length, records.length);
    }
    _throwIfCancelled(isCancelled);

    final document = pw.Document(
      compress: compress,
      title: kind == FindPdfDocumentKind.summary
          ? 'Find Catalogue PDF Summary'
          : 'Find Catalogue PDF Full Record',
      author: 'Find Catalogue',
      creator: 'Find Catalogue',
    );
    if (kind == FindPdfDocumentKind.summary) {
      _addSummaryPages(document, preparedRecords, icon, findspotPrecision);
    } else {
      _addFullRecordPages(document, preparedRecords, icon, findspotPrecision);
    }
    return document.save();
  }

  void _addSummaryPages(
    pw.Document document,
    List<_PreparedPdfRecord> records,
    pw.ImageProvider icon,
    FindspotExportPrecision findspotPrecision,
  ) {
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 34, 36, 34),
        header: (context) => _pageHeader(
          icon,
          documentLabel: 'PDF Summary',
          trailing: '${records.length} record${records.length == 1 ? '' : 's'}',
        ),
        footer: _pageFooter,
        build: (context) => [
          pw.Text(
            'Find records summary',
            style: pw.TextStyle(
              color: _olive,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          _privacyNote(findspotPrecision),
          pw.SizedBox(height: 16),
          for (final record in records) _summaryCard(record),
        ],
      ),
    );
  }

  void _addFullRecordPages(
    pw.Document document,
    List<_PreparedPdfRecord> records,
    pw.ImageProvider icon,
    FindspotExportPrecision findspotPrecision,
  ) {
    for (final record in records) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 34, 36, 34),
          header: (context) => _pageHeader(
            icon,
            documentLabel: 'PDF Full Record',
            trailing: record.data.logNumber,
          ),
          footer: _pageFooter,
          build: (context) => [
            pw.Text(
              record.data.logNumber,
              style: pw.TextStyle(
                color: _olive,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              record.data.title,
              style: pw.TextStyle(fontSize: 23, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            _privacyNote(findspotPrecision),
            pw.SizedBox(height: 14),
            _fieldTable(record.data.fullFields),
            pw.SizedBox(height: 16),
            if (record.data.photos.isEmpty)
              _photoPlaceholder('No photograph recorded')
            else ...[
              _sectionHeading('Primary photograph'),
              pw.SizedBox(height: 6),
              _fullPhoto(
                record.photos.isEmpty ? null : record.photos.first,
                record.data.photos.first.caption,
              ),
            ],
            ..._textSection('Observations', record.data.observations),
            ..._textSection(
              'Research reasoning and notes',
              record.data.researchNotes,
            ),
            ..._textSection('Sources and links', record.data.sources),
            ..._textSection('Physical storage', record.data.storageLocation),
            if (record.data.photos.length > 1) ...[
              pw.NewPage(freeSpace: 420),
              _sectionHeading('Additional photographs'),
              pw.SizedBox(height: 8),
              for (var index = 1; index < record.data.photos.length; index++)
                _fullPhoto(
                  index < record.photos.length ? record.photos[index] : null,
                  record.data.photos[index].caption,
                ),
            ],
          ],
        ),
      );
    }
  }

  pw.Widget _summaryCard(_PreparedPdfRecord record) {
    final primary = record.photos.isEmpty ? null : record.photos.first;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _warmSurface,
        border: pw.Border.all(color: _outline, width: 0.6),
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  record.data.logNumber,
                  style: pw.TextStyle(
                    color: _olive,
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  record.data.title,
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 9),
                _fieldTable(record.data.summaryFields, compact: true),
                if (record.data.summaryObservations != null) ...[
                  pw.SizedBox(height: 8),
                  _sectionHeading('Observations', compact: true),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    record.data.summaryObservations!,
                    maxLines: 4,
                    overflow: pw.TextOverflow.clip,
                    style: const pw.TextStyle(fontSize: 8.8, lineSpacing: 1.5),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Container(
            width: 148,
            height: 132,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: _outline, width: 0.5),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: primary == null
                ? pw.Center(
                    child: pw.Text(
                      record.data.photos.isEmpty
                          ? 'No photograph'
                          : 'Photograph unavailable',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 8.5,
                      ),
                    ),
                  )
                : pw.Image(
                    pw.MemoryImage(primary.bytes),
                    fit: pw.BoxFit.contain,
                  ),
          ),
        ],
      ),
    );
  }

  pw.Widget _fieldTable(List<FindPdfField> fields, {bool compact = false}) =>
      pw.TableHelper.fromTextArray(
        data: [
          for (final field in fields) [field.label, field.value],
        ],
        cellPadding: pw.EdgeInsets.symmetric(
          vertical: compact ? 2.2 : 3.5,
          horizontal: compact ? 4 : 6,
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.15),
          1: pw.FlexColumnWidth(2.8),
        },
        cellStyle: pw.TextStyle(fontSize: compact ? 8.2 : 9.5),
        headerCount: 0,
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.35),
        ),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      );

  pw.Widget _fullPhoto(PreparedFindPdfPhoto? photo, String caption) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            height: 330,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: _warmSurface,
              border: pw.Border.all(color: _outline, width: 0.6),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: photo == null
                ? _photoPlaceholder('Photograph unavailable')
                : pw.Image(pw.MemoryImage(photo.bytes), fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            caption,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _photoPlaceholder(String label) => pw.Container(
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: _warmSurface,
      border: pw.Border.all(color: _outline, width: 0.5),
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Text(
      label,
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
    ),
  );

  List<pw.Widget> _textSection(String title, String? text) {
    if (text == null) return const [];
    return [
      pw.SizedBox(height: 14),
      _sectionHeading(title),
      pw.SizedBox(height: 4),
      for (final chunk in _textChunks(text))
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(
            chunk,
            style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
          ),
        ),
    ];
  }

  Iterable<String> _textChunks(String text) sync* {
    const maximumLength = 1200;
    var remaining = text.trim();
    while (remaining.length > maximumLength) {
      var splitAt = remaining.lastIndexOf(' ', maximumLength);
      if (splitAt < maximumLength ~/ 2) splitAt = maximumLength;
      yield remaining.substring(0, splitAt).trim();
      remaining = remaining.substring(splitAt).trimLeft();
    }
    if (remaining.isNotEmpty) yield remaining;
  }

  pw.Widget _sectionHeading(String value, {bool compact = false}) => pw.Text(
    value,
    style: pw.TextStyle(
      color: _olive,
      fontSize: compact ? 9 : 11,
      fontWeight: pw.FontWeight.bold,
    ),
  );

  pw.Widget _privacyNote(FindspotExportPrecision precision) => pw.Text(
    precision == FindspotExportPrecision.exact
        ? 'Exact findspots included by explicit choice.'
        : 'Findspots hidden for privacy.',
    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
  );

  pw.Widget _pageHeader(
    pw.ImageProvider icon, {
    required String documentLabel,
    required String trailing,
  }) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    margin: const pw.EdgeInsets.only(bottom: 14),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _outline, width: 0.6)),
    ),
    child: pw.Row(
      children: [
        pw.Container(
          width: 28,
          height: 28,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Image(icon, fit: pw.BoxFit.contain),
        ),
        pw.SizedBox(width: 8),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Find Catalogue',
              style: pw.TextStyle(
                color: _olive,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              documentLabel,
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Text(
          trailing,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  pw.Widget _pageFooter(pw.Context context) => pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      'Page ${context.pageNumber} of ${context.pagesCount}',
      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
    ),
  );

  Future<Uint8List> _preparedBrandIcon() async {
    final bytes = await _assetLoader(_brandAsset);
    final decoded = image.decodeImage(bytes);
    if (decoded == null) return bytes;
    final resized = image.copyResize(
      decoded,
      width: 96,
      interpolation: image.Interpolation.average,
    );
    return Uint8List.fromList(image.encodePng(resized));
  }

  void _throwIfCancelled(FindPdfCancellationCheck? isCancelled) {
    if (isCancelled?.call() ?? false) {
      throw const FindPdfGenerationCancelledException();
    }
  }

  static Future<Uint8List> _loadAsset(String assetKey) async {
    final data = await rootBundle.load(assetKey);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

class _PreparedPdfRecord {
  const _PreparedPdfRecord({required this.data, required this.photos});

  final FindPdfRecordData data;
  final List<PreparedFindPdfPhoto?> photos;
}
