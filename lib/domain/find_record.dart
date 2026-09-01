enum FindRecordMethod { instant, manual }

enum FieldSource { deviceCaptured, manuallyEntered, photoMetadata, unknown }

enum IdentificationConfidence { unassessed, low, possible, probable, high }

enum FindPhotoRole { discovery, front, reverse, edge, scale, detail, context }

enum FindPhotoSource { camera, library }

bool timelineRangeIsValid(int? fromYear, int? toYear) =>
    fromYear == null || toYear == null || fromYear <= toYear;

class FindLocation {
  const FindLocation({
    required this.latitude,
    required this.longitude,
    this.horizontalAccuracy,
    this.altitude,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final double? horizontalAccuracy;
  final double? altitude;
  final FieldSource source;
}

class FindPhoto {
  const FindPhoto({
    required this.id,
    required this.path,
    required this.role,
    required this.source,
    required this.createdAt,
    required this.isOriginalEvidence,
    required this.sortOrder,
  });

  final int id;
  final String path;
  final FindPhotoRole role;
  final FindPhotoSource source;
  final DateTime createdAt;
  final bool isOriginalEvidence;
  final int sortOrder;
}

class NewFindPhoto {
  const NewFindPhoto({
    required this.path,
    required this.role,
    required this.source,
    required this.createdAt,
    required this.isOriginalEvidence,
    required this.sortOrder,
  });

  final String path;
  final FindPhotoRole role;
  final FindPhotoSource source;
  final DateTime createdAt;
  final bool isOriginalEvidence;
  final int sortOrder;
}

class FindPhotoUpdate {
  const FindPhotoUpdate({
    required this.id,
    required this.role,
    required this.sortOrder,
  });

  final int id;
  final FindPhotoRole role;
  final int sortOrder;
}

class FindDraft {
  const FindDraft({
    required this.method,
    required this.discoveredAt,
    required this.discoveryDateSource,
    required this.discoveryDateApproximate,
    required this.location,
    required this.preferredIdentification,
    required this.material,
    required this.confidence,
    required this.timelineFromYear,
    required this.timelineToYear,
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
    required this.diameterMm,
    required this.thicknessMm,
    required this.weightG,
    required this.observations,
    required this.researchNotes,
    required this.sources,
    required this.storageLocation,
  });

  final FindRecordMethod method;
  final DateTime? discoveredAt;
  final FieldSource discoveryDateSource;
  final bool discoveryDateApproximate;
  final FindLocation? location;
  final String preferredIdentification;
  final String material;
  final IdentificationConfidence confidence;
  final int? timelineFromYear;
  final int? timelineToYear;
  final double? lengthMm;
  final double? widthMm;
  final double? heightMm;
  final double? diameterMm;
  final double? thicknessMm;
  final double? weightG;
  final String observations;
  final String researchNotes;
  final String sources;
  final String storageLocation;
}

class FindRecord {
  const FindRecord({
    required this.id,
    required this.logNumber,
    required this.method,
    required this.createdAt,
    required this.updatedAt,
    required this.discoveredAt,
    required this.discoveryDateSource,
    required this.discoveryDateApproximate,
    required this.location,
    required this.preferredIdentification,
    required this.material,
    required this.confidence,
    required this.timelineFromYear,
    required this.timelineToYear,
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
    required this.diameterMm,
    required this.thicknessMm,
    required this.weightG,
    required this.observations,
    required this.researchNotes,
    required this.sources,
    required this.storageLocation,
    required this.photos,
  });

  final int id;
  final String logNumber;
  final FindRecordMethod method;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? discoveredAt;
  final FieldSource discoveryDateSource;
  final bool discoveryDateApproximate;
  final FindLocation? location;
  final String preferredIdentification;
  final String material;
  final IdentificationConfidence confidence;
  final int? timelineFromYear;
  final int? timelineToYear;
  final double? lengthMm;
  final double? widthMm;
  final double? heightMm;
  final double? diameterMm;
  final double? thicknessMm;
  final double? weightG;
  final String observations;
  final String researchNotes;
  final String sources;
  final String storageLocation;
  final List<FindPhoto> photos;

  String get displayTitle => preferredIdentification.trim().isEmpty
      ? 'Unidentified object'
      : preferredIdentification.trim();

  FindPhoto? get primaryPhoto => photos.isEmpty ? null : photos.first;

  String get searchableText => [
    logNumber,
    method.name,
    preferredIdentification,
    material,
    confidence.name,
    timelineFromYear?.toString() ?? '',
    timelineToYear?.toString() ?? '',
    observations,
    researchNotes,
    sources,
    storageLocation,
    discoveredAt?.toIso8601String() ?? '',
    if (discoveryDateApproximate) 'approximate date',
    createdAt.toIso8601String(),
    location?.latitude.toString() ?? '',
    location?.longitude.toString() ?? '',
    location?.horizontalAccuracy?.toString() ?? '',
    lengthMm?.toString() ?? '',
    widthMm?.toString() ?? '',
    heightMm?.toString() ?? '',
    diameterMm?.toString() ?? '',
    thicknessMm?.toString() ?? '',
    weightG?.toString() ?? '',
    ...photos.map((photo) => photo.role.name),
  ].join(' ').toLowerCase();
}
