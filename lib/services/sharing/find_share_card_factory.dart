import '../../domain/find_record.dart';
import '../../ui/formatters.dart';
import '../../ui/sharing/find_share_card.dart';

class FindShareCardFactory {
  const FindShareCardFactory();

  FindShareCardData create(FindRecord record) {
    final facts = <FindShareCardFact>[
      if (record.material.trim().isNotEmpty)
        FindShareCardFact(label: 'Material', value: record.material.trim()),
      if (record.timelineFromYear != null || record.timelineToYear != null)
        FindShareCardFact(
          label: 'Period',
          value: formatTimelineRange(
            record.timelineFromYear,
            record.timelineToYear,
          ),
        ),
      if (record.confidence != IdentificationConfidence.unassessed)
        FindShareCardFact(
          label: 'Confidence',
          value: enumLabel(record.confidence),
        ),
    ];
    final discoveryDate = record.discoveredAt == null
        ? null
        : '${formatDate(record.discoveredAt!)}${record.discoveryDateApproximate ? ' (approx.)' : ''}';
    final observation = _observationExcerpt(record.observations);

    return FindShareCardData(
      logNumber: record.logNumber,
      title: record.displayTitle,
      discoveryDate: discoveryDate,
      facts: List.unmodifiable(facts),
      measurements: _measurements(record),
      weight: record.weightG == null ? null : '${record.weightG} g',
      observations: observation,
      heroPhotoPath: record.primaryPhoto?.path,
      photoStatus: record.primaryPhoto == null
          ? FindShareCardPhotoStatus.none
          : FindShareCardPhotoStatus.available,
    );
  }

  String? _measurements(FindRecord record) {
    final values = <String>[];
    if (record.diameterMm != null) {
      values.add('Ø ${record.diameterMm} mm');
      if (record.thicknessMm != null) {
        values.add('T ${record.thicknessMm} mm');
      }
      if (record.heightMm != null) values.add('H ${record.heightMm} mm');
      if (record.lengthMm != null) values.add('L ${record.lengthMm} mm');
      if (record.widthMm != null) values.add('W ${record.widthMm} mm');
    } else {
      if (record.lengthMm != null) values.add('L ${record.lengthMm} mm');
      if (record.widthMm != null) values.add('W ${record.widthMm} mm');
      if (record.thicknessMm != null) {
        values.add('T ${record.thicknessMm} mm');
      }
      if (record.heightMm != null) values.add('H ${record.heightMm} mm');
    }
    if (values.isEmpty) return null;
    return values.take(3).join('  ·  ');
  }

  String? _observationExcerpt(String value) {
    final normalised = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalised.isEmpty) return null;
    const maximumLength = 140;
    final runes = normalised.runes.toList();
    if (runes.length <= maximumLength) return normalised;

    var excerpt = String.fromCharCodes(runes.take(maximumLength).toList());
    final lastSpace = excerpt.lastIndexOf(' ');
    if (lastSpace >= maximumLength ~/ 2) {
      excerpt = excerpt.substring(0, lastSpace);
    }
    return '${excerpt.trimRight()}…';
  }
}
