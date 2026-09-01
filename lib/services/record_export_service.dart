import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Rect;
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../domain/find_record.dart';
import '../ui/formatters.dart';

enum RecordExportFormat { csv, pdf, pdfBundle }

enum FindspotExportPrecision { hidden, exact }

class RecordExportService {
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

  Future<Uint8List> buildPdf(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
    bool photosBundled = false,
    bool compress = true,
  }) async {
    final document = pw.Document(
      compress: compress,
      title: 'Find Catalogue records',
      author: 'Find Catalogue',
    );
    final generated = DateTime.now();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Find Catalogue',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${records.length} record${records.length == 1 ? '' : 's'}',
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Shared find records',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated ${formatDateTime(generated)} - findspots ${findspotPrecision == FindspotExportPrecision.exact ? 'included exactly' : 'hidden'}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          pw.Wrap(
            children: records
                .map(
                  (record) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 14),
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                        width: 0.6,
                      ),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${record.logNumber} - ${record.displayTitle}',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _pdfTable(
                          record,
                          findspotPrecision,
                          photosBundled: photosBundled,
                        ),
                        ..._pdfNotes(record),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<Uint8List> buildBundle(
    List<FindRecord> records, {
    required FindspotExportPrecision findspotPrecision,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one record is required.');
    }
    final archive = Archive();
    final pdfBytes = await buildPdf(
      records,
      findspotPrecision: findspotPrecision,
      photosBundled: true,
    );
    archive.addFile(ArchiveFile('find_records.pdf', pdfBytes.length, pdfBytes));

    var includedPhotos = 0;
    final omittedPhotos = <String>[];
    for (final record in records) {
      for (final entry in record.photos.indexed) {
        final photo = entry.$2;
        final file = File(photo.path);
        if (!await file.exists()) {
          omittedPhotos.add(
            '${record.logNumber}: ${enumLabel(photo.role)} (file unavailable)',
          );
          continue;
        }
        var bytes = await file.readAsBytes();
        final originalName = path.basenameWithoutExtension(file.path);
        var extension = path.extension(file.path).toLowerCase();
        if (findspotPrecision == FindspotExportPrecision.hidden) {
          final decoded = image.decodeImage(bytes);
          if (decoded == null) {
            omittedPhotos.add(
              '${record.logNumber}: ${enumLabel(photo.role)} '
              '(image metadata could not be removed safely)',
            );
            continue;
          }
          final sanitised = image.bakeOrientation(decoded)
            ..exif.clear()
            ..textData = null
            ..iccProfile = null;
          if (extension == '.png') {
            bytes = image.encodePng(sanitised);
          } else {
            bytes = image.encodeJpg(sanitised, quality: 95);
            extension = '.jpg';
          }
        }
        final name = [
          (entry.$1 + 1).toString().padLeft(2, '0'),
          photo.role.name,
          _safeFileName(originalName),
        ].join('_');
        archive.addFile(
          ArchiveFile(
            'photos/${record.logNumber}/$name$extension',
            bytes.length,
            bytes,
          ),
        );
        includedPhotos++;
      }
    }

    final manifest = StringBuffer()
      ..writeln('Find Catalogue photo bundle')
      ..writeln()
      ..writeln('Records: ${records.length}')
      ..writeln(
        findspotPrecision == FindspotExportPrecision.exact
            ? 'Untouched original photographs included: $includedPhotos'
            : 'Privacy-safe photograph copies included: $includedPhotos',
      )
      ..writeln(
        'Exact findspots: ${findspotPrecision == FindspotExportPrecision.exact ? 'included in the PDF' : 'hidden'}',
      )
      ..writeln()
      ..writeln('The photographs are organised by permanent log number.')
      ..writeln(
        findspotPrecision == FindspotExportPrecision.exact
            ? 'Photo files are untouched originals and may retain their embedded metadata.'
            : 'Photo copies were re-encoded with embedded metadata removed, including any GPS data.',
      );
    if (omittedPhotos.isNotEmpty) {
      manifest
        ..writeln()
        ..writeln('Photographs omitted when this bundle was created:')
        ..writeAll(omittedPhotos.map((item) => '- $item\n'));
    }
    final recordedPhotoCount = records.fold<int>(
      0,
      (total, record) => total + record.photos.length,
    );
    if (recordedPhotoCount > 0 && includedPhotos == 0) {
      throw StateError(
        'No recorded photographs could be added to the bundle. '
        'Open the record and confirm its photograph is still visible.',
      );
    }
    final manifestBytes = utf8.encode(manifest.toString());
    archive.addFile(
      ArchiveFile('README.txt', manifestBytes.length, manifestBytes),
    );

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  Future<void> share(
    List<FindRecord> records, {
    required RecordExportFormat format,
    required FindspotExportPrecision findspotPrecision,
    Rect? sharePositionOrigin,
  }) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one record is required.');
    }
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final extension = switch (format) {
      RecordExportFormat.csv => 'csv',
      RecordExportFormat.pdf => 'pdf',
      RecordExportFormat.pdfBundle => 'zip',
    };
    final file = File('${directory.path}/find_records_$timestamp.$extension');
    if (format == RecordExportFormat.csv) {
      final csv = buildCsv(records, findspotPrecision: findspotPrecision);
      await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
    } else if (format == RecordExportFormat.pdf) {
      await file.writeAsBytes(
        await buildPdf(records, findspotPrecision: findspotPrecision),
      );
    } else {
      await file.writeAsBytes(
        await buildBundle(records, findspotPrecision: findspotPrecision),
      );
    }

    await SharePlus.instance.share(
      ShareParams(
        subject: format == RecordExportFormat.pdfBundle
            ? 'Find Catalogue records and photographs'
            : 'Find Catalogue records',
        text:
            '${records.length} shared find record${records.length == 1 ? '' : 's'}.',
        files: [
          XFile(
            file.path,
            name: file.uri.pathSegments.last,
            mimeType: switch (format) {
              RecordExportFormat.csv => 'text/csv',
              RecordExportFormat.pdf => 'application/pdf',
              RecordExportFormat.pdfBundle => 'application/zip',
            },
          ),
        ],
        sharePositionOrigin:
            sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }

  pw.Widget _pdfTable(
    FindRecord record,
    FindspotExportPrecision precision, {
    required bool photosBundled,
  }) {
    final rows = <List<String>>[
      ['Material', record.material.isEmpty ? 'Not recorded' : record.material],
      ['Confidence', enumLabel(record.confidence)],
      [
        'Timeline',
        formatTimelineRange(
          record.timelineFromYear,
          record.timelineToYear,
        ).replaceAll('–', '-'),
      ],
      [
        'Discovered',
        record.discoveredAt == null
            ? 'Unknown'
            : '${formatDateTime(record.discoveredAt!)}${record.discoveryDateApproximate ? ' (approximate)' : ''}',
      ],
      [
        'Findspot',
        precision == FindspotExportPrecision.hidden
            ? 'Hidden'
            : record.location == null
            ? 'Unknown'
            : '${record.location!.latitude.toStringAsFixed(6)}, ${record.location!.longitude.toStringAsFixed(6)}',
      ],
      if (record.lengthMm != null) ['Length', '${record.lengthMm} mm'],
      if (record.widthMm != null) ['Width', '${record.widthMm} mm'],
      if (record.heightMm != null) ['Height', '${record.heightMm} mm'],
      if (record.diameterMm != null) ['Diameter', '${record.diameterMm} mm'],
      if (record.thicknessMm != null) ['Thickness', '${record.thicknessMm} mm'],
      if (record.weightG != null) ['Weight', '${record.weightG} g'],
      [
        'Photographs',
        photosBundled
            ? '${record.photos.length} recorded; see the bundle photo folder and README'
            : '${record.photos.length} held in private catalogue',
      ],
    ];
    return pw.TableHelper.fromTextArray(
      data: rows,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.1),
        1: const pw.FlexColumnWidth(3.2),
      },
      cellStyle: const pw.TextStyle(fontSize: 9.5),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  List<pw.Widget> _pdfNotes(FindRecord record) {
    final fields = [
      ('Observations', record.observations),
      ('Research reasoning and notes', record.researchNotes),
      ('Sources and links', record.sources),
      ('Physical storage', record.storageLocation),
    ];
    return [
      for (final field in fields)
        if (field.$2.trim().isNotEmpty) ...[
          pw.SizedBox(height: 7),
          pw.Text(
            field.$1,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(field.$2, style: const pw.TextStyle(fontSize: 9.5)),
        ],
    ];
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
}
