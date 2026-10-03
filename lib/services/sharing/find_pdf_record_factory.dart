import '../../domain/find_record.dart';
import '../../ui/formatters.dart';
import 'findspot_export_precision.dart';

class FindPdfField {
  const FindPdfField({required this.label, required this.value});

  final String label;
  final String value;
}

class FindPdfPhotoData {
  const FindPdfPhotoData({
    required this.number,
    required this.path,
    required this.role,
  });

  final int number;
  final String path;
  final String role;

  String get caption => 'Photo $number - $role';
}

class FindPdfRecordData {
  const FindPdfRecordData({
    required this.logNumber,
    required this.title,
    required this.summaryFields,
    required this.fullFields,
    required this.summaryObservations,
    required this.observations,
    required this.researchNotes,
    required this.sources,
    required this.storageLocation,
    required this.photos,
  });

  final String logNumber;
  final String title;
  final List<FindPdfField> summaryFields;
  final List<FindPdfField> fullFields;
  final String? summaryObservations;
  final String? observations;
  final String? researchNotes;
  final String? sources;
  final String? storageLocation;
  final List<FindPdfPhotoData> photos;

  FindPdfPhotoData? get primaryPhoto => photos.isEmpty ? null : photos.first;
}

class FindPdfRecordFactory {
  const FindPdfRecordFactory();

  FindPdfRecordData create(
    FindRecord record, {
    required FindspotExportPrecision findspotPrecision,
  }) {
    final discoveryDate = record.discoveredAt == null
        ? null
        : '${formatDate(record.discoveredAt!)}'
              '${record.discoveryDateApproximate ? ' (approximate)' : ''}';
    final period =
        record.timelineFromYear == null && record.timelineToYear == null
        ? null
        : formatTimelineRange(
            record.timelineFromYear,
            record.timelineToYear,
          ).replaceAll('–', '-');
    final measurements = _compactMeasurements(record);
    final findspot = _findspot(record, findspotPrecision);

    final summaryFields = <FindPdfField>[
      if (discoveryDate != null)
        FindPdfField(label: 'Discovered', value: discoveryDate),
      if (record.material.trim().isNotEmpty)
        FindPdfField(label: 'Material', value: record.material.trim()),
      if (period != null) FindPdfField(label: 'Period', value: period),
      if (record.confidence != IdentificationConfidence.unassessed)
        FindPdfField(label: 'Confidence', value: enumLabel(record.confidence)),
      if (measurements != null)
        FindPdfField(label: 'Measurements', value: measurements),
      if (record.weightG != null)
        FindPdfField(label: 'Weight', value: '${record.weightG} g'),
      FindPdfField(label: 'Findspot', value: findspot),
    ];

    final fullFields = <FindPdfField>[
      FindPdfField(label: 'Record method', value: _recordMethod(record.method)),
      if (discoveryDate != null)
        FindPdfField(label: 'Discovery date', value: discoveryDate),
      if (discoveryDate != null)
        FindPdfField(
          label: 'Discovery date source',
          value: enumLabel(record.discoveryDateSource),
        ),
      FindPdfField(label: 'Findspot', value: findspot),
      if (findspotPrecision == FindspotExportPrecision.exact &&
          record.location?.horizontalAccuracy != null)
        FindPdfField(
          label: 'Location accuracy',
          value:
              '+/-${record.location!.horizontalAccuracy!.toStringAsFixed(1)} m',
        ),
      if (findspotPrecision == FindspotExportPrecision.exact &&
          record.location?.altitude != null)
        FindPdfField(
          label: 'Altitude',
          value: '${record.location!.altitude!.toStringAsFixed(1)} m',
        ),
      if (findspotPrecision == FindspotExportPrecision.exact &&
          record.location != null)
        FindPdfField(
          label: 'Location source',
          value: enumLabel(record.location!.source),
        ),
      if (record.material.trim().isNotEmpty)
        FindPdfField(label: 'Material', value: record.material.trim()),
      if (period != null) FindPdfField(label: 'Period', value: period),
      if (record.confidence != IdentificationConfidence.unassessed)
        FindPdfField(label: 'Confidence', value: enumLabel(record.confidence)),
      if (record.lengthMm != null)
        FindPdfField(label: 'Length', value: '${record.lengthMm} mm'),
      if (record.widthMm != null)
        FindPdfField(label: 'Width', value: '${record.widthMm} mm'),
      if (record.heightMm != null)
        FindPdfField(label: 'Height', value: '${record.heightMm} mm'),
      if (record.diameterMm != null)
        FindPdfField(label: 'Diameter', value: '${record.diameterMm} mm'),
      if (record.thicknessMm != null)
        FindPdfField(label: 'Thickness', value: '${record.thicknessMm} mm'),
      if (record.weightG != null)
        FindPdfField(label: 'Weight', value: '${record.weightG} g'),
      if (record.photos.isNotEmpty)
        FindPdfField(label: 'Photographs', value: '${record.photos.length}'),
    ];

    return FindPdfRecordData(
      logNumber: record.logNumber,
      title: record.displayTitle,
      summaryFields: List.unmodifiable(summaryFields),
      fullFields: List.unmodifiable(fullFields),
      summaryObservations: _excerpt(record.observations, maximumLength: 360),
      observations: _optionalText(record.observations),
      researchNotes: _optionalText(record.researchNotes),
      sources: _optionalText(record.sources),
      storageLocation: _optionalText(record.storageLocation),
      photos: List.unmodifiable([
        for (final entry in record.photos.indexed)
          FindPdfPhotoData(
            number: entry.$1 + 1,
            path: entry.$2.path,
            role: enumLabel(entry.$2.role),
          ),
      ]),
    );
  }

  String _findspot(
    FindRecord record,
    FindspotExportPrecision findspotPrecision,
  ) {
    if (findspotPrecision == FindspotExportPrecision.hidden) {
      return 'Not shared';
    }
    final location = record.location;
    if (location == null) return 'Not recorded';
    return '${formatCoordinate(location.latitude)}, '
        '${formatCoordinate(location.longitude)}';
  }

  String _recordMethod(FindRecordMethod method) => switch (method) {
    FindRecordMethod.instant => 'Instant Find',
    FindRecordMethod.manual => 'Manual entry',
  };

  String? _compactMeasurements(FindRecord record) {
    final values = <String>[
      if (record.lengthMm != null) 'L ${record.lengthMm} mm',
      if (record.widthMm != null) 'W ${record.widthMm} mm',
      if (record.heightMm != null) 'H ${record.heightMm} mm',
      if (record.diameterMm != null) 'Diameter ${record.diameterMm} mm',
      if (record.thicknessMm != null) 'T ${record.thicknessMm} mm',
    ];
    return values.isEmpty ? null : values.join('  |  ');
  }

  String? _optionalText(String value) {
    final normalised = value.trim();
    return normalised.isEmpty ? null : normalised;
  }

  String? _excerpt(String value, {required int maximumLength}) {
    final normalised = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalised.isEmpty) return null;
    final runes = normalised.runes.toList();
    if (runes.length <= maximumLength) return normalised;
    var excerpt = String.fromCharCodes(runes.take(maximumLength).toList());
    final lastSpace = excerpt.lastIndexOf(' ');
    if (lastSpace >= maximumLength ~/ 2) {
      excerpt = excerpt.substring(0, lastSpace);
    }
    return '${excerpt.trimRight()}...';
  }
}
