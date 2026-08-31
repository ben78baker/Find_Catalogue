// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FindRecordsTable extends FindRecords
    with TableInfo<$FindRecordsTable, FindRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FindRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _logNumberMeta = const VerificationMeta(
    'logNumber',
  );
  @override
  late final GeneratedColumn<String> logNumber = GeneratedColumn<String>(
    'log_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _recordMethodMeta = const VerificationMeta(
    'recordMethod',
  );
  @override
  late final GeneratedColumn<String> recordMethod = GeneratedColumn<String>(
    'record_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discoveredAtMeta = const VerificationMeta(
    'discoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> discoveredAt = GeneratedColumn<DateTime>(
    'discovered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discoveryDateSourceMeta =
      const VerificationMeta('discoveryDateSource');
  @override
  late final GeneratedColumn<String> discoveryDateSource =
      GeneratedColumn<String>(
        'discovery_date_source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _discoveryDateApproximateMeta =
      const VerificationMeta('discoveryDateApproximate');
  @override
  late final GeneratedColumn<bool> discoveryDateApproximate =
      GeneratedColumn<bool>(
        'discovery_date_approximate',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("discovery_date_approximate" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizontalAccuracyMeta =
      const VerificationMeta('horizontalAccuracy');
  @override
  late final GeneratedColumn<double> horizontalAccuracy =
      GeneratedColumn<double>(
        'horizontal_accuracy',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationSourceMeta = const VerificationMeta(
    'locationSource',
  );
  @override
  late final GeneratedColumn<String> locationSource = GeneratedColumn<String>(
    'location_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredIdentificationMeta =
      const VerificationMeta('preferredIdentification');
  @override
  late final GeneratedColumn<String> preferredIdentification =
      GeneratedColumn<String>(
        'preferred_identification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unassessed'),
  );
  static const VerificationMeta _timelineFromYearMeta = const VerificationMeta(
    'timelineFromYear',
  );
  @override
  late final GeneratedColumn<int> timelineFromYear = GeneratedColumn<int>(
    'timeline_from_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timelineToYearMeta = const VerificationMeta(
    'timelineToYear',
  );
  @override
  late final GeneratedColumn<int> timelineToYear = GeneratedColumn<int>(
    'timeline_to_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthMmMeta = const VerificationMeta(
    'lengthMm',
  );
  @override
  late final GeneratedColumn<double> lengthMm = GeneratedColumn<double>(
    'length_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMmMeta = const VerificationMeta(
    'widthMm',
  );
  @override
  late final GeneratedColumn<double> widthMm = GeneratedColumn<double>(
    'width_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMmMeta = const VerificationMeta(
    'heightMm',
  );
  @override
  late final GeneratedColumn<double> heightMm = GeneratedColumn<double>(
    'height_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diameterMmMeta = const VerificationMeta(
    'diameterMm',
  );
  @override
  late final GeneratedColumn<double> diameterMm = GeneratedColumn<double>(
    'diameter_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thicknessMmMeta = const VerificationMeta(
    'thicknessMm',
  );
  @override
  late final GeneratedColumn<double> thicknessMm = GeneratedColumn<double>(
    'thickness_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGMeta = const VerificationMeta(
    'weightG',
  );
  @override
  late final GeneratedColumn<double> weightG = GeneratedColumn<double>(
    'weight_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _researchNotesMeta = const VerificationMeta(
    'researchNotes',
  );
  @override
  late final GeneratedColumn<String> researchNotes = GeneratedColumn<String>(
    'research_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourcesMeta = const VerificationMeta(
    'sources',
  );
  @override
  late final GeneratedColumn<String> sources = GeneratedColumn<String>(
    'sources',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storageLocationMeta = const VerificationMeta(
    'storageLocation',
  );
  @override
  late final GeneratedColumn<String> storageLocation = GeneratedColumn<String>(
    'storage_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    logNumber,
    recordMethod,
    createdAt,
    updatedAt,
    discoveredAt,
    discoveryDateSource,
    discoveryDateApproximate,
    latitude,
    longitude,
    horizontalAccuracy,
    altitude,
    locationSource,
    preferredIdentification,
    material,
    confidence,
    timelineFromYear,
    timelineToYear,
    lengthMm,
    widthMm,
    heightMm,
    diameterMm,
    thicknessMm,
    weightG,
    observations,
    researchNotes,
    sources,
    storageLocation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'find_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FindRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('log_number')) {
      context.handle(
        _logNumberMeta,
        logNumber.isAcceptableOrUnknown(data['log_number']!, _logNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_logNumberMeta);
    }
    if (data.containsKey('record_method')) {
      context.handle(
        _recordMethodMeta,
        recordMethod.isAcceptableOrUnknown(
          data['record_method']!,
          _recordMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordMethodMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('discovered_at')) {
      context.handle(
        _discoveredAtMeta,
        discoveredAt.isAcceptableOrUnknown(
          data['discovered_at']!,
          _discoveredAtMeta,
        ),
      );
    }
    if (data.containsKey('discovery_date_source')) {
      context.handle(
        _discoveryDateSourceMeta,
        discoveryDateSource.isAcceptableOrUnknown(
          data['discovery_date_source']!,
          _discoveryDateSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discoveryDateSourceMeta);
    }
    if (data.containsKey('discovery_date_approximate')) {
      context.handle(
        _discoveryDateApproximateMeta,
        discoveryDateApproximate.isAcceptableOrUnknown(
          data['discovery_date_approximate']!,
          _discoveryDateApproximateMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('horizontal_accuracy')) {
      context.handle(
        _horizontalAccuracyMeta,
        horizontalAccuracy.isAcceptableOrUnknown(
          data['horizontal_accuracy']!,
          _horizontalAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('location_source')) {
      context.handle(
        _locationSourceMeta,
        locationSource.isAcceptableOrUnknown(
          data['location_source']!,
          _locationSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationSourceMeta);
    }
    if (data.containsKey('preferred_identification')) {
      context.handle(
        _preferredIdentificationMeta,
        preferredIdentification.isAcceptableOrUnknown(
          data['preferred_identification']!,
          _preferredIdentificationMeta,
        ),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('timeline_from_year')) {
      context.handle(
        _timelineFromYearMeta,
        timelineFromYear.isAcceptableOrUnknown(
          data['timeline_from_year']!,
          _timelineFromYearMeta,
        ),
      );
    }
    if (data.containsKey('timeline_to_year')) {
      context.handle(
        _timelineToYearMeta,
        timelineToYear.isAcceptableOrUnknown(
          data['timeline_to_year']!,
          _timelineToYearMeta,
        ),
      );
    }
    if (data.containsKey('length_mm')) {
      context.handle(
        _lengthMmMeta,
        lengthMm.isAcceptableOrUnknown(data['length_mm']!, _lengthMmMeta),
      );
    }
    if (data.containsKey('width_mm')) {
      context.handle(
        _widthMmMeta,
        widthMm.isAcceptableOrUnknown(data['width_mm']!, _widthMmMeta),
      );
    }
    if (data.containsKey('height_mm')) {
      context.handle(
        _heightMmMeta,
        heightMm.isAcceptableOrUnknown(data['height_mm']!, _heightMmMeta),
      );
    }
    if (data.containsKey('diameter_mm')) {
      context.handle(
        _diameterMmMeta,
        diameterMm.isAcceptableOrUnknown(data['diameter_mm']!, _diameterMmMeta),
      );
    }
    if (data.containsKey('thickness_mm')) {
      context.handle(
        _thicknessMmMeta,
        thicknessMm.isAcceptableOrUnknown(
          data['thickness_mm']!,
          _thicknessMmMeta,
        ),
      );
    }
    if (data.containsKey('weight_g')) {
      context.handle(
        _weightGMeta,
        weightG.isAcceptableOrUnknown(data['weight_g']!, _weightGMeta),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('research_notes')) {
      context.handle(
        _researchNotesMeta,
        researchNotes.isAcceptableOrUnknown(
          data['research_notes']!,
          _researchNotesMeta,
        ),
      );
    }
    if (data.containsKey('sources')) {
      context.handle(
        _sourcesMeta,
        sources.isAcceptableOrUnknown(data['sources']!, _sourcesMeta),
      );
    }
    if (data.containsKey('storage_location')) {
      context.handle(
        _storageLocationMeta,
        storageLocation.isAcceptableOrUnknown(
          data['storage_location']!,
          _storageLocationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FindRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FindRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      logNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_number'],
      )!,
      recordMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_method'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      ),
      discoveryDateSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discovery_date_source'],
      )!,
      discoveryDateApproximate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}discovery_date_approximate'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      horizontalAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}horizontal_accuracy'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      locationSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_source'],
      )!,
      preferredIdentification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_identification'],
      )!,
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      timelineFromYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeline_from_year'],
      ),
      timelineToYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeline_to_year'],
      ),
      lengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_mm'],
      ),
      widthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_mm'],
      ),
      heightMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_mm'],
      ),
      diameterMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}diameter_mm'],
      ),
      thicknessMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thickness_mm'],
      ),
      weightG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_g'],
      ),
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      )!,
      researchNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}research_notes'],
      )!,
      sources: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sources'],
      )!,
      storageLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_location'],
      )!,
    );
  }

  @override
  $FindRecordsTable createAlias(String alias) {
    return $FindRecordsTable(attachedDatabase, alias);
  }
}

class FindRecord extends DataClass implements Insertable<FindRecord> {
  final int id;
  final String logNumber;
  final String recordMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? discoveredAt;
  final String discoveryDateSource;
  final bool discoveryDateApproximate;
  final double? latitude;
  final double? longitude;
  final double? horizontalAccuracy;
  final double? altitude;
  final String locationSource;
  final String preferredIdentification;
  final String material;
  final String confidence;
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
  const FindRecord({
    required this.id,
    required this.logNumber,
    required this.recordMethod,
    required this.createdAt,
    required this.updatedAt,
    this.discoveredAt,
    required this.discoveryDateSource,
    required this.discoveryDateApproximate,
    this.latitude,
    this.longitude,
    this.horizontalAccuracy,
    this.altitude,
    required this.locationSource,
    required this.preferredIdentification,
    required this.material,
    required this.confidence,
    this.timelineFromYear,
    this.timelineToYear,
    this.lengthMm,
    this.widthMm,
    this.heightMm,
    this.diameterMm,
    this.thicknessMm,
    this.weightG,
    required this.observations,
    required this.researchNotes,
    required this.sources,
    required this.storageLocation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['log_number'] = Variable<String>(logNumber);
    map['record_method'] = Variable<String>(recordMethod);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || discoveredAt != null) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt);
    }
    map['discovery_date_source'] = Variable<String>(discoveryDateSource);
    map['discovery_date_approximate'] = Variable<bool>(
      discoveryDateApproximate,
    );
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || horizontalAccuracy != null) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['location_source'] = Variable<String>(locationSource);
    map['preferred_identification'] = Variable<String>(preferredIdentification);
    map['material'] = Variable<String>(material);
    map['confidence'] = Variable<String>(confidence);
    if (!nullToAbsent || timelineFromYear != null) {
      map['timeline_from_year'] = Variable<int>(timelineFromYear);
    }
    if (!nullToAbsent || timelineToYear != null) {
      map['timeline_to_year'] = Variable<int>(timelineToYear);
    }
    if (!nullToAbsent || lengthMm != null) {
      map['length_mm'] = Variable<double>(lengthMm);
    }
    if (!nullToAbsent || widthMm != null) {
      map['width_mm'] = Variable<double>(widthMm);
    }
    if (!nullToAbsent || heightMm != null) {
      map['height_mm'] = Variable<double>(heightMm);
    }
    if (!nullToAbsent || diameterMm != null) {
      map['diameter_mm'] = Variable<double>(diameterMm);
    }
    if (!nullToAbsent || thicknessMm != null) {
      map['thickness_mm'] = Variable<double>(thicknessMm);
    }
    if (!nullToAbsent || weightG != null) {
      map['weight_g'] = Variable<double>(weightG);
    }
    map['observations'] = Variable<String>(observations);
    map['research_notes'] = Variable<String>(researchNotes);
    map['sources'] = Variable<String>(sources);
    map['storage_location'] = Variable<String>(storageLocation);
    return map;
  }

  FindRecordsCompanion toCompanion(bool nullToAbsent) {
    return FindRecordsCompanion(
      id: Value(id),
      logNumber: Value(logNumber),
      recordMethod: Value(recordMethod),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      discoveredAt: discoveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(discoveredAt),
      discoveryDateSource: Value(discoveryDateSource),
      discoveryDateApproximate: Value(discoveryDateApproximate),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      horizontalAccuracy: horizontalAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(horizontalAccuracy),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      locationSource: Value(locationSource),
      preferredIdentification: Value(preferredIdentification),
      material: Value(material),
      confidence: Value(confidence),
      timelineFromYear: timelineFromYear == null && nullToAbsent
          ? const Value.absent()
          : Value(timelineFromYear),
      timelineToYear: timelineToYear == null && nullToAbsent
          ? const Value.absent()
          : Value(timelineToYear),
      lengthMm: lengthMm == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthMm),
      widthMm: widthMm == null && nullToAbsent
          ? const Value.absent()
          : Value(widthMm),
      heightMm: heightMm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightMm),
      diameterMm: diameterMm == null && nullToAbsent
          ? const Value.absent()
          : Value(diameterMm),
      thicknessMm: thicknessMm == null && nullToAbsent
          ? const Value.absent()
          : Value(thicknessMm),
      weightG: weightG == null && nullToAbsent
          ? const Value.absent()
          : Value(weightG),
      observations: Value(observations),
      researchNotes: Value(researchNotes),
      sources: Value(sources),
      storageLocation: Value(storageLocation),
    );
  }

  factory FindRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FindRecord(
      id: serializer.fromJson<int>(json['id']),
      logNumber: serializer.fromJson<String>(json['logNumber']),
      recordMethod: serializer.fromJson<String>(json['recordMethod']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      discoveredAt: serializer.fromJson<DateTime?>(json['discoveredAt']),
      discoveryDateSource: serializer.fromJson<String>(
        json['discoveryDateSource'],
      ),
      discoveryDateApproximate: serializer.fromJson<bool>(
        json['discoveryDateApproximate'],
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      horizontalAccuracy: serializer.fromJson<double?>(
        json['horizontalAccuracy'],
      ),
      altitude: serializer.fromJson<double?>(json['altitude']),
      locationSource: serializer.fromJson<String>(json['locationSource']),
      preferredIdentification: serializer.fromJson<String>(
        json['preferredIdentification'],
      ),
      material: serializer.fromJson<String>(json['material']),
      confidence: serializer.fromJson<String>(json['confidence']),
      timelineFromYear: serializer.fromJson<int?>(json['timelineFromYear']),
      timelineToYear: serializer.fromJson<int?>(json['timelineToYear']),
      lengthMm: serializer.fromJson<double?>(json['lengthMm']),
      widthMm: serializer.fromJson<double?>(json['widthMm']),
      heightMm: serializer.fromJson<double?>(json['heightMm']),
      diameterMm: serializer.fromJson<double?>(json['diameterMm']),
      thicknessMm: serializer.fromJson<double?>(json['thicknessMm']),
      weightG: serializer.fromJson<double?>(json['weightG']),
      observations: serializer.fromJson<String>(json['observations']),
      researchNotes: serializer.fromJson<String>(json['researchNotes']),
      sources: serializer.fromJson<String>(json['sources']),
      storageLocation: serializer.fromJson<String>(json['storageLocation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'logNumber': serializer.toJson<String>(logNumber),
      'recordMethod': serializer.toJson<String>(recordMethod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'discoveredAt': serializer.toJson<DateTime?>(discoveredAt),
      'discoveryDateSource': serializer.toJson<String>(discoveryDateSource),
      'discoveryDateApproximate': serializer.toJson<bool>(
        discoveryDateApproximate,
      ),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'horizontalAccuracy': serializer.toJson<double?>(horizontalAccuracy),
      'altitude': serializer.toJson<double?>(altitude),
      'locationSource': serializer.toJson<String>(locationSource),
      'preferredIdentification': serializer.toJson<String>(
        preferredIdentification,
      ),
      'material': serializer.toJson<String>(material),
      'confidence': serializer.toJson<String>(confidence),
      'timelineFromYear': serializer.toJson<int?>(timelineFromYear),
      'timelineToYear': serializer.toJson<int?>(timelineToYear),
      'lengthMm': serializer.toJson<double?>(lengthMm),
      'widthMm': serializer.toJson<double?>(widthMm),
      'heightMm': serializer.toJson<double?>(heightMm),
      'diameterMm': serializer.toJson<double?>(diameterMm),
      'thicknessMm': serializer.toJson<double?>(thicknessMm),
      'weightG': serializer.toJson<double?>(weightG),
      'observations': serializer.toJson<String>(observations),
      'researchNotes': serializer.toJson<String>(researchNotes),
      'sources': serializer.toJson<String>(sources),
      'storageLocation': serializer.toJson<String>(storageLocation),
    };
  }

  FindRecord copyWith({
    int? id,
    String? logNumber,
    String? recordMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> discoveredAt = const Value.absent(),
    String? discoveryDateSource,
    bool? discoveryDateApproximate,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> horizontalAccuracy = const Value.absent(),
    Value<double?> altitude = const Value.absent(),
    String? locationSource,
    String? preferredIdentification,
    String? material,
    String? confidence,
    Value<int?> timelineFromYear = const Value.absent(),
    Value<int?> timelineToYear = const Value.absent(),
    Value<double?> lengthMm = const Value.absent(),
    Value<double?> widthMm = const Value.absent(),
    Value<double?> heightMm = const Value.absent(),
    Value<double?> diameterMm = const Value.absent(),
    Value<double?> thicknessMm = const Value.absent(),
    Value<double?> weightG = const Value.absent(),
    String? observations,
    String? researchNotes,
    String? sources,
    String? storageLocation,
  }) => FindRecord(
    id: id ?? this.id,
    logNumber: logNumber ?? this.logNumber,
    recordMethod: recordMethod ?? this.recordMethod,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    discoveredAt: discoveredAt.present ? discoveredAt.value : this.discoveredAt,
    discoveryDateSource: discoveryDateSource ?? this.discoveryDateSource,
    discoveryDateApproximate:
        discoveryDateApproximate ?? this.discoveryDateApproximate,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    horizontalAccuracy: horizontalAccuracy.present
        ? horizontalAccuracy.value
        : this.horizontalAccuracy,
    altitude: altitude.present ? altitude.value : this.altitude,
    locationSource: locationSource ?? this.locationSource,
    preferredIdentification:
        preferredIdentification ?? this.preferredIdentification,
    material: material ?? this.material,
    confidence: confidence ?? this.confidence,
    timelineFromYear: timelineFromYear.present
        ? timelineFromYear.value
        : this.timelineFromYear,
    timelineToYear: timelineToYear.present
        ? timelineToYear.value
        : this.timelineToYear,
    lengthMm: lengthMm.present ? lengthMm.value : this.lengthMm,
    widthMm: widthMm.present ? widthMm.value : this.widthMm,
    heightMm: heightMm.present ? heightMm.value : this.heightMm,
    diameterMm: diameterMm.present ? diameterMm.value : this.diameterMm,
    thicknessMm: thicknessMm.present ? thicknessMm.value : this.thicknessMm,
    weightG: weightG.present ? weightG.value : this.weightG,
    observations: observations ?? this.observations,
    researchNotes: researchNotes ?? this.researchNotes,
    sources: sources ?? this.sources,
    storageLocation: storageLocation ?? this.storageLocation,
  );
  FindRecord copyWithCompanion(FindRecordsCompanion data) {
    return FindRecord(
      id: data.id.present ? data.id.value : this.id,
      logNumber: data.logNumber.present ? data.logNumber.value : this.logNumber,
      recordMethod: data.recordMethod.present
          ? data.recordMethod.value
          : this.recordMethod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
      discoveryDateSource: data.discoveryDateSource.present
          ? data.discoveryDateSource.value
          : this.discoveryDateSource,
      discoveryDateApproximate: data.discoveryDateApproximate.present
          ? data.discoveryDateApproximate.value
          : this.discoveryDateApproximate,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      horizontalAccuracy: data.horizontalAccuracy.present
          ? data.horizontalAccuracy.value
          : this.horizontalAccuracy,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      locationSource: data.locationSource.present
          ? data.locationSource.value
          : this.locationSource,
      preferredIdentification: data.preferredIdentification.present
          ? data.preferredIdentification.value
          : this.preferredIdentification,
      material: data.material.present ? data.material.value : this.material,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      timelineFromYear: data.timelineFromYear.present
          ? data.timelineFromYear.value
          : this.timelineFromYear,
      timelineToYear: data.timelineToYear.present
          ? data.timelineToYear.value
          : this.timelineToYear,
      lengthMm: data.lengthMm.present ? data.lengthMm.value : this.lengthMm,
      widthMm: data.widthMm.present ? data.widthMm.value : this.widthMm,
      heightMm: data.heightMm.present ? data.heightMm.value : this.heightMm,
      diameterMm: data.diameterMm.present
          ? data.diameterMm.value
          : this.diameterMm,
      thicknessMm: data.thicknessMm.present
          ? data.thicknessMm.value
          : this.thicknessMm,
      weightG: data.weightG.present ? data.weightG.value : this.weightG,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      researchNotes: data.researchNotes.present
          ? data.researchNotes.value
          : this.researchNotes,
      sources: data.sources.present ? data.sources.value : this.sources,
      storageLocation: data.storageLocation.present
          ? data.storageLocation.value
          : this.storageLocation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FindRecord(')
          ..write('id: $id, ')
          ..write('logNumber: $logNumber, ')
          ..write('recordMethod: $recordMethod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('discoveryDateSource: $discoveryDateSource, ')
          ..write('discoveryDateApproximate: $discoveryDateApproximate, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('altitude: $altitude, ')
          ..write('locationSource: $locationSource, ')
          ..write('preferredIdentification: $preferredIdentification, ')
          ..write('material: $material, ')
          ..write('confidence: $confidence, ')
          ..write('timelineFromYear: $timelineFromYear, ')
          ..write('timelineToYear: $timelineToYear, ')
          ..write('lengthMm: $lengthMm, ')
          ..write('widthMm: $widthMm, ')
          ..write('heightMm: $heightMm, ')
          ..write('diameterMm: $diameterMm, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('weightG: $weightG, ')
          ..write('observations: $observations, ')
          ..write('researchNotes: $researchNotes, ')
          ..write('sources: $sources, ')
          ..write('storageLocation: $storageLocation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    logNumber,
    recordMethod,
    createdAt,
    updatedAt,
    discoveredAt,
    discoveryDateSource,
    discoveryDateApproximate,
    latitude,
    longitude,
    horizontalAccuracy,
    altitude,
    locationSource,
    preferredIdentification,
    material,
    confidence,
    timelineFromYear,
    timelineToYear,
    lengthMm,
    widthMm,
    heightMm,
    diameterMm,
    thicknessMm,
    weightG,
    observations,
    researchNotes,
    sources,
    storageLocation,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FindRecord &&
          other.id == this.id &&
          other.logNumber == this.logNumber &&
          other.recordMethod == this.recordMethod &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.discoveredAt == this.discoveredAt &&
          other.discoveryDateSource == this.discoveryDateSource &&
          other.discoveryDateApproximate == this.discoveryDateApproximate &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.horizontalAccuracy == this.horizontalAccuracy &&
          other.altitude == this.altitude &&
          other.locationSource == this.locationSource &&
          other.preferredIdentification == this.preferredIdentification &&
          other.material == this.material &&
          other.confidence == this.confidence &&
          other.timelineFromYear == this.timelineFromYear &&
          other.timelineToYear == this.timelineToYear &&
          other.lengthMm == this.lengthMm &&
          other.widthMm == this.widthMm &&
          other.heightMm == this.heightMm &&
          other.diameterMm == this.diameterMm &&
          other.thicknessMm == this.thicknessMm &&
          other.weightG == this.weightG &&
          other.observations == this.observations &&
          other.researchNotes == this.researchNotes &&
          other.sources == this.sources &&
          other.storageLocation == this.storageLocation);
}

class FindRecordsCompanion extends UpdateCompanion<FindRecord> {
  final Value<int> id;
  final Value<String> logNumber;
  final Value<String> recordMethod;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> discoveredAt;
  final Value<String> discoveryDateSource;
  final Value<bool> discoveryDateApproximate;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> horizontalAccuracy;
  final Value<double?> altitude;
  final Value<String> locationSource;
  final Value<String> preferredIdentification;
  final Value<String> material;
  final Value<String> confidence;
  final Value<int?> timelineFromYear;
  final Value<int?> timelineToYear;
  final Value<double?> lengthMm;
  final Value<double?> widthMm;
  final Value<double?> heightMm;
  final Value<double?> diameterMm;
  final Value<double?> thicknessMm;
  final Value<double?> weightG;
  final Value<String> observations;
  final Value<String> researchNotes;
  final Value<String> sources;
  final Value<String> storageLocation;
  const FindRecordsCompanion({
    this.id = const Value.absent(),
    this.logNumber = const Value.absent(),
    this.recordMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.discoveryDateSource = const Value.absent(),
    this.discoveryDateApproximate = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.locationSource = const Value.absent(),
    this.preferredIdentification = const Value.absent(),
    this.material = const Value.absent(),
    this.confidence = const Value.absent(),
    this.timelineFromYear = const Value.absent(),
    this.timelineToYear = const Value.absent(),
    this.lengthMm = const Value.absent(),
    this.widthMm = const Value.absent(),
    this.heightMm = const Value.absent(),
    this.diameterMm = const Value.absent(),
    this.thicknessMm = const Value.absent(),
    this.weightG = const Value.absent(),
    this.observations = const Value.absent(),
    this.researchNotes = const Value.absent(),
    this.sources = const Value.absent(),
    this.storageLocation = const Value.absent(),
  });
  FindRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String logNumber,
    required String recordMethod,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.discoveredAt = const Value.absent(),
    required String discoveryDateSource,
    this.discoveryDateApproximate = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    required String locationSource,
    this.preferredIdentification = const Value.absent(),
    this.material = const Value.absent(),
    this.confidence = const Value.absent(),
    this.timelineFromYear = const Value.absent(),
    this.timelineToYear = const Value.absent(),
    this.lengthMm = const Value.absent(),
    this.widthMm = const Value.absent(),
    this.heightMm = const Value.absent(),
    this.diameterMm = const Value.absent(),
    this.thicknessMm = const Value.absent(),
    this.weightG = const Value.absent(),
    this.observations = const Value.absent(),
    this.researchNotes = const Value.absent(),
    this.sources = const Value.absent(),
    this.storageLocation = const Value.absent(),
  }) : logNumber = Value(logNumber),
       recordMethod = Value(recordMethod),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       discoveryDateSource = Value(discoveryDateSource),
       locationSource = Value(locationSource);
  static Insertable<FindRecord> custom({
    Expression<int>? id,
    Expression<String>? logNumber,
    Expression<String>? recordMethod,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? discoveredAt,
    Expression<String>? discoveryDateSource,
    Expression<bool>? discoveryDateApproximate,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? horizontalAccuracy,
    Expression<double>? altitude,
    Expression<String>? locationSource,
    Expression<String>? preferredIdentification,
    Expression<String>? material,
    Expression<String>? confidence,
    Expression<int>? timelineFromYear,
    Expression<int>? timelineToYear,
    Expression<double>? lengthMm,
    Expression<double>? widthMm,
    Expression<double>? heightMm,
    Expression<double>? diameterMm,
    Expression<double>? thicknessMm,
    Expression<double>? weightG,
    Expression<String>? observations,
    Expression<String>? researchNotes,
    Expression<String>? sources,
    Expression<String>? storageLocation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (logNumber != null) 'log_number': logNumber,
      if (recordMethod != null) 'record_method': recordMethod,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (discoveryDateSource != null)
        'discovery_date_source': discoveryDateSource,
      if (discoveryDateApproximate != null)
        'discovery_date_approximate': discoveryDateApproximate,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (horizontalAccuracy != null) 'horizontal_accuracy': horizontalAccuracy,
      if (altitude != null) 'altitude': altitude,
      if (locationSource != null) 'location_source': locationSource,
      if (preferredIdentification != null)
        'preferred_identification': preferredIdentification,
      if (material != null) 'material': material,
      if (confidence != null) 'confidence': confidence,
      if (timelineFromYear != null) 'timeline_from_year': timelineFromYear,
      if (timelineToYear != null) 'timeline_to_year': timelineToYear,
      if (lengthMm != null) 'length_mm': lengthMm,
      if (widthMm != null) 'width_mm': widthMm,
      if (heightMm != null) 'height_mm': heightMm,
      if (diameterMm != null) 'diameter_mm': diameterMm,
      if (thicknessMm != null) 'thickness_mm': thicknessMm,
      if (weightG != null) 'weight_g': weightG,
      if (observations != null) 'observations': observations,
      if (researchNotes != null) 'research_notes': researchNotes,
      if (sources != null) 'sources': sources,
      if (storageLocation != null) 'storage_location': storageLocation,
    });
  }

  FindRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? logNumber,
    Value<String>? recordMethod,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? discoveredAt,
    Value<String>? discoveryDateSource,
    Value<bool>? discoveryDateApproximate,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? horizontalAccuracy,
    Value<double?>? altitude,
    Value<String>? locationSource,
    Value<String>? preferredIdentification,
    Value<String>? material,
    Value<String>? confidence,
    Value<int?>? timelineFromYear,
    Value<int?>? timelineToYear,
    Value<double?>? lengthMm,
    Value<double?>? widthMm,
    Value<double?>? heightMm,
    Value<double?>? diameterMm,
    Value<double?>? thicknessMm,
    Value<double?>? weightG,
    Value<String>? observations,
    Value<String>? researchNotes,
    Value<String>? sources,
    Value<String>? storageLocation,
  }) {
    return FindRecordsCompanion(
      id: id ?? this.id,
      logNumber: logNumber ?? this.logNumber,
      recordMethod: recordMethod ?? this.recordMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      discoveryDateSource: discoveryDateSource ?? this.discoveryDateSource,
      discoveryDateApproximate:
          discoveryDateApproximate ?? this.discoveryDateApproximate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      altitude: altitude ?? this.altitude,
      locationSource: locationSource ?? this.locationSource,
      preferredIdentification:
          preferredIdentification ?? this.preferredIdentification,
      material: material ?? this.material,
      confidence: confidence ?? this.confidence,
      timelineFromYear: timelineFromYear ?? this.timelineFromYear,
      timelineToYear: timelineToYear ?? this.timelineToYear,
      lengthMm: lengthMm ?? this.lengthMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      diameterMm: diameterMm ?? this.diameterMm,
      thicknessMm: thicknessMm ?? this.thicknessMm,
      weightG: weightG ?? this.weightG,
      observations: observations ?? this.observations,
      researchNotes: researchNotes ?? this.researchNotes,
      sources: sources ?? this.sources,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (logNumber.present) {
      map['log_number'] = Variable<String>(logNumber.value);
    }
    if (recordMethod.present) {
      map['record_method'] = Variable<String>(recordMethod.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt.value);
    }
    if (discoveryDateSource.present) {
      map['discovery_date_source'] = Variable<String>(
        discoveryDateSource.value,
      );
    }
    if (discoveryDateApproximate.present) {
      map['discovery_date_approximate'] = Variable<bool>(
        discoveryDateApproximate.value,
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (horizontalAccuracy.present) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (locationSource.present) {
      map['location_source'] = Variable<String>(locationSource.value);
    }
    if (preferredIdentification.present) {
      map['preferred_identification'] = Variable<String>(
        preferredIdentification.value,
      );
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (timelineFromYear.present) {
      map['timeline_from_year'] = Variable<int>(timelineFromYear.value);
    }
    if (timelineToYear.present) {
      map['timeline_to_year'] = Variable<int>(timelineToYear.value);
    }
    if (lengthMm.present) {
      map['length_mm'] = Variable<double>(lengthMm.value);
    }
    if (widthMm.present) {
      map['width_mm'] = Variable<double>(widthMm.value);
    }
    if (heightMm.present) {
      map['height_mm'] = Variable<double>(heightMm.value);
    }
    if (diameterMm.present) {
      map['diameter_mm'] = Variable<double>(diameterMm.value);
    }
    if (thicknessMm.present) {
      map['thickness_mm'] = Variable<double>(thicknessMm.value);
    }
    if (weightG.present) {
      map['weight_g'] = Variable<double>(weightG.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (researchNotes.present) {
      map['research_notes'] = Variable<String>(researchNotes.value);
    }
    if (sources.present) {
      map['sources'] = Variable<String>(sources.value);
    }
    if (storageLocation.present) {
      map['storage_location'] = Variable<String>(storageLocation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FindRecordsCompanion(')
          ..write('id: $id, ')
          ..write('logNumber: $logNumber, ')
          ..write('recordMethod: $recordMethod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('discoveryDateSource: $discoveryDateSource, ')
          ..write('discoveryDateApproximate: $discoveryDateApproximate, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('altitude: $altitude, ')
          ..write('locationSource: $locationSource, ')
          ..write('preferredIdentification: $preferredIdentification, ')
          ..write('material: $material, ')
          ..write('confidence: $confidence, ')
          ..write('timelineFromYear: $timelineFromYear, ')
          ..write('timelineToYear: $timelineToYear, ')
          ..write('lengthMm: $lengthMm, ')
          ..write('widthMm: $widthMm, ')
          ..write('heightMm: $heightMm, ')
          ..write('diameterMm: $diameterMm, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('weightG: $weightG, ')
          ..write('observations: $observations, ')
          ..write('researchNotes: $researchNotes, ')
          ..write('sources: $sources, ')
          ..write('storageLocation: $storageLocation')
          ..write(')'))
        .toString();
  }
}

class $FindPhotosTable extends FindPhotos
    with TableInfo<$FindPhotosTable, FindPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FindPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _findRecordIdMeta = const VerificationMeta(
    'findRecordId',
  );
  @override
  late final GeneratedColumn<int> findRecordId = GeneratedColumn<int>(
    'find_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES find_records (id)',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOriginalEvidenceMeta =
      const VerificationMeta('isOriginalEvidence');
  @override
  late final GeneratedColumn<bool> isOriginalEvidence = GeneratedColumn<bool>(
    'is_original_evidence',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_original_evidence" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    findRecordId,
    path,
    role,
    source,
    createdAt,
    isOriginalEvidence,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'find_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<FindPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('find_record_id')) {
      context.handle(
        _findRecordIdMeta,
        findRecordId.isAcceptableOrUnknown(
          data['find_record_id']!,
          _findRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_findRecordIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_original_evidence')) {
      context.handle(
        _isOriginalEvidenceMeta,
        isOriginalEvidence.isAcceptableOrUnknown(
          data['is_original_evidence']!,
          _isOriginalEvidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isOriginalEvidenceMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FindPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FindPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      findRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}find_record_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isOriginalEvidence: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_original_evidence'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $FindPhotosTable createAlias(String alias) {
    return $FindPhotosTable(attachedDatabase, alias);
  }
}

class FindPhoto extends DataClass implements Insertable<FindPhoto> {
  final int id;
  final int findRecordId;
  final String path;
  final String role;
  final String source;
  final DateTime createdAt;
  final bool isOriginalEvidence;
  final int sortOrder;
  const FindPhoto({
    required this.id,
    required this.findRecordId,
    required this.path,
    required this.role,
    required this.source,
    required this.createdAt,
    required this.isOriginalEvidence,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['find_record_id'] = Variable<int>(findRecordId);
    map['path'] = Variable<String>(path);
    map['role'] = Variable<String>(role);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_original_evidence'] = Variable<bool>(isOriginalEvidence);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  FindPhotosCompanion toCompanion(bool nullToAbsent) {
    return FindPhotosCompanion(
      id: Value(id),
      findRecordId: Value(findRecordId),
      path: Value(path),
      role: Value(role),
      source: Value(source),
      createdAt: Value(createdAt),
      isOriginalEvidence: Value(isOriginalEvidence),
      sortOrder: Value(sortOrder),
    );
  }

  factory FindPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FindPhoto(
      id: serializer.fromJson<int>(json['id']),
      findRecordId: serializer.fromJson<int>(json['findRecordId']),
      path: serializer.fromJson<String>(json['path']),
      role: serializer.fromJson<String>(json['role']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isOriginalEvidence: serializer.fromJson<bool>(json['isOriginalEvidence']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'findRecordId': serializer.toJson<int>(findRecordId),
      'path': serializer.toJson<String>(path),
      'role': serializer.toJson<String>(role),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isOriginalEvidence': serializer.toJson<bool>(isOriginalEvidence),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  FindPhoto copyWith({
    int? id,
    int? findRecordId,
    String? path,
    String? role,
    String? source,
    DateTime? createdAt,
    bool? isOriginalEvidence,
    int? sortOrder,
  }) => FindPhoto(
    id: id ?? this.id,
    findRecordId: findRecordId ?? this.findRecordId,
    path: path ?? this.path,
    role: role ?? this.role,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    isOriginalEvidence: isOriginalEvidence ?? this.isOriginalEvidence,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  FindPhoto copyWithCompanion(FindPhotosCompanion data) {
    return FindPhoto(
      id: data.id.present ? data.id.value : this.id,
      findRecordId: data.findRecordId.present
          ? data.findRecordId.value
          : this.findRecordId,
      path: data.path.present ? data.path.value : this.path,
      role: data.role.present ? data.role.value : this.role,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isOriginalEvidence: data.isOriginalEvidence.present
          ? data.isOriginalEvidence.value
          : this.isOriginalEvidence,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FindPhoto(')
          ..write('id: $id, ')
          ..write('findRecordId: $findRecordId, ')
          ..write('path: $path, ')
          ..write('role: $role, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('isOriginalEvidence: $isOriginalEvidence, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    findRecordId,
    path,
    role,
    source,
    createdAt,
    isOriginalEvidence,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FindPhoto &&
          other.id == this.id &&
          other.findRecordId == this.findRecordId &&
          other.path == this.path &&
          other.role == this.role &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.isOriginalEvidence == this.isOriginalEvidence &&
          other.sortOrder == this.sortOrder);
}

class FindPhotosCompanion extends UpdateCompanion<FindPhoto> {
  final Value<int> id;
  final Value<int> findRecordId;
  final Value<String> path;
  final Value<String> role;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<bool> isOriginalEvidence;
  final Value<int> sortOrder;
  const FindPhotosCompanion({
    this.id = const Value.absent(),
    this.findRecordId = const Value.absent(),
    this.path = const Value.absent(),
    this.role = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isOriginalEvidence = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  FindPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int findRecordId,
    required String path,
    required String role,
    required String source,
    required DateTime createdAt,
    required bool isOriginalEvidence,
    required int sortOrder,
  }) : findRecordId = Value(findRecordId),
       path = Value(path),
       role = Value(role),
       source = Value(source),
       createdAt = Value(createdAt),
       isOriginalEvidence = Value(isOriginalEvidence),
       sortOrder = Value(sortOrder);
  static Insertable<FindPhoto> custom({
    Expression<int>? id,
    Expression<int>? findRecordId,
    Expression<String>? path,
    Expression<String>? role,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<bool>? isOriginalEvidence,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (findRecordId != null) 'find_record_id': findRecordId,
      if (path != null) 'path': path,
      if (role != null) 'role': role,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (isOriginalEvidence != null)
        'is_original_evidence': isOriginalEvidence,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  FindPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? findRecordId,
    Value<String>? path,
    Value<String>? role,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<bool>? isOriginalEvidence,
    Value<int>? sortOrder,
  }) {
    return FindPhotosCompanion(
      id: id ?? this.id,
      findRecordId: findRecordId ?? this.findRecordId,
      path: path ?? this.path,
      role: role ?? this.role,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      isOriginalEvidence: isOriginalEvidence ?? this.isOriginalEvidence,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (findRecordId.present) {
      map['find_record_id'] = Variable<int>(findRecordId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isOriginalEvidence.present) {
      map['is_original_evidence'] = Variable<bool>(isOriginalEvidence.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FindPhotosCompanion(')
          ..write('id: $id, ')
          ..write('findRecordId: $findRecordId, ')
          ..write('path: $path, ')
          ..write('role: $role, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('isOriginalEvidence: $isOriginalEvidence, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CatalogueCountersTable extends CatalogueCounters
    with TableInfo<$CatalogueCountersTable, CatalogueCounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogueCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextValueMeta = const VerificationMeta(
    'nextValue',
  );
  @override
  late final GeneratedColumn<int> nextValue = GeneratedColumn<int>(
    'next_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, nextValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalogue_counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogueCounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('next_value')) {
      context.handle(
        _nextValueMeta,
        nextValue.isAcceptableOrUnknown(data['next_value']!, _nextValueMeta),
      );
    } else if (isInserting) {
      context.missing(_nextValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CatalogueCounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogueCounter(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      nextValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_value'],
      )!,
    );
  }

  @override
  $CatalogueCountersTable createAlias(String alias) {
    return $CatalogueCountersTable(attachedDatabase, alias);
  }
}

class CatalogueCounter extends DataClass
    implements Insertable<CatalogueCounter> {
  final String key;
  final int nextValue;
  const CatalogueCounter({required this.key, required this.nextValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['next_value'] = Variable<int>(nextValue);
    return map;
  }

  CatalogueCountersCompanion toCompanion(bool nullToAbsent) {
    return CatalogueCountersCompanion(
      key: Value(key),
      nextValue: Value(nextValue),
    );
  }

  factory CatalogueCounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogueCounter(
      key: serializer.fromJson<String>(json['key']),
      nextValue: serializer.fromJson<int>(json['nextValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'nextValue': serializer.toJson<int>(nextValue),
    };
  }

  CatalogueCounter copyWith({String? key, int? nextValue}) => CatalogueCounter(
    key: key ?? this.key,
    nextValue: nextValue ?? this.nextValue,
  );
  CatalogueCounter copyWithCompanion(CatalogueCountersCompanion data) {
    return CatalogueCounter(
      key: data.key.present ? data.key.value : this.key,
      nextValue: data.nextValue.present ? data.nextValue.value : this.nextValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueCounter(')
          ..write('key: $key, ')
          ..write('nextValue: $nextValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, nextValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogueCounter &&
          other.key == this.key &&
          other.nextValue == this.nextValue);
}

class CatalogueCountersCompanion extends UpdateCompanion<CatalogueCounter> {
  final Value<String> key;
  final Value<int> nextValue;
  final Value<int> rowid;
  const CatalogueCountersCompanion({
    this.key = const Value.absent(),
    this.nextValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogueCountersCompanion.insert({
    required String key,
    required int nextValue,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       nextValue = Value(nextValue);
  static Insertable<CatalogueCounter> custom({
    Expression<String>? key,
    Expression<int>? nextValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (nextValue != null) 'next_value': nextValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogueCountersCompanion copyWith({
    Value<String>? key,
    Value<int>? nextValue,
    Value<int>? rowid,
  }) {
    return CatalogueCountersCompanion(
      key: key ?? this.key,
      nextValue: nextValue ?? this.nextValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (nextValue.present) {
      map['next_value'] = Variable<int>(nextValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogueCountersCompanion(')
          ..write('key: $key, ')
          ..write('nextValue: $nextValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FindRecordsTable findRecords = $FindRecordsTable(this);
  late final $FindPhotosTable findPhotos = $FindPhotosTable(this);
  late final $CatalogueCountersTable catalogueCounters =
      $CatalogueCountersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    findRecords,
    findPhotos,
    catalogueCounters,
  ];
}

typedef $$FindRecordsTableCreateCompanionBuilder =
    FindRecordsCompanion Function({
      Value<int> id,
      required String logNumber,
      required String recordMethod,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> discoveredAt,
      required String discoveryDateSource,
      Value<bool> discoveryDateApproximate,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> horizontalAccuracy,
      Value<double?> altitude,
      required String locationSource,
      Value<String> preferredIdentification,
      Value<String> material,
      Value<String> confidence,
      Value<int?> timelineFromYear,
      Value<int?> timelineToYear,
      Value<double?> lengthMm,
      Value<double?> widthMm,
      Value<double?> heightMm,
      Value<double?> diameterMm,
      Value<double?> thicknessMm,
      Value<double?> weightG,
      Value<String> observations,
      Value<String> researchNotes,
      Value<String> sources,
      Value<String> storageLocation,
    });
typedef $$FindRecordsTableUpdateCompanionBuilder =
    FindRecordsCompanion Function({
      Value<int> id,
      Value<String> logNumber,
      Value<String> recordMethod,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> discoveredAt,
      Value<String> discoveryDateSource,
      Value<bool> discoveryDateApproximate,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> horizontalAccuracy,
      Value<double?> altitude,
      Value<String> locationSource,
      Value<String> preferredIdentification,
      Value<String> material,
      Value<String> confidence,
      Value<int?> timelineFromYear,
      Value<int?> timelineToYear,
      Value<double?> lengthMm,
      Value<double?> widthMm,
      Value<double?> heightMm,
      Value<double?> diameterMm,
      Value<double?> thicknessMm,
      Value<double?> weightG,
      Value<String> observations,
      Value<String> researchNotes,
      Value<String> sources,
      Value<String> storageLocation,
    });

final class $$FindRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $FindRecordsTable, FindRecord> {
  $$FindRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FindPhotosTable, List<FindPhoto>>
  _findPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.findPhotos,
    aliasName: 'find_records__id__find_photos__find_record_id',
  );

  $$FindPhotosTableProcessedTableManager get findPhotosRefs {
    final manager = $$FindPhotosTableTableManager(
      $_db,
      $_db.findPhotos,
    ).filter((f) => f.findRecordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_findPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FindRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FindRecordsTable> {
  $$FindRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logNumber => $composableBuilder(
    column: $table.logNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discoveryDateSource => $composableBuilder(
    column: $table.discoveryDateSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get discoveryDateApproximate => $composableBuilder(
    column: $table.discoveryDateApproximate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationSource => $composableBuilder(
    column: $table.locationSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredIdentification => $composableBuilder(
    column: $table.preferredIdentification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timelineFromYear => $composableBuilder(
    column: $table.timelineFromYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timelineToYear => $composableBuilder(
    column: $table.timelineToYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthMm => $composableBuilder(
    column: $table.lengthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get diameterMm => $composableBuilder(
    column: $table.diameterMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightG => $composableBuilder(
    column: $table.weightG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get researchNotes => $composableBuilder(
    column: $table.researchNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sources => $composableBuilder(
    column: $table.sources,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> findPhotosRefs(
    Expression<bool> Function($$FindPhotosTableFilterComposer f) f,
  ) {
    final $$FindPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.findPhotos,
      getReferencedColumn: (t) => t.findRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FindPhotosTableFilterComposer(
            $db: $db,
            $table: $db.findPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FindRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FindRecordsTable> {
  $$FindRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logNumber => $composableBuilder(
    column: $table.logNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discoveryDateSource => $composableBuilder(
    column: $table.discoveryDateSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get discoveryDateApproximate => $composableBuilder(
    column: $table.discoveryDateApproximate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationSource => $composableBuilder(
    column: $table.locationSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredIdentification => $composableBuilder(
    column: $table.preferredIdentification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timelineFromYear => $composableBuilder(
    column: $table.timelineFromYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timelineToYear => $composableBuilder(
    column: $table.timelineToYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthMm => $composableBuilder(
    column: $table.lengthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthMm => $composableBuilder(
    column: $table.widthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightMm => $composableBuilder(
    column: $table.heightMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get diameterMm => $composableBuilder(
    column: $table.diameterMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightG => $composableBuilder(
    column: $table.weightG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get researchNotes => $composableBuilder(
    column: $table.researchNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sources => $composableBuilder(
    column: $table.sources,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FindRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FindRecordsTable> {
  $$FindRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get logNumber =>
      $composableBuilder(column: $table.logNumber, builder: (column) => column);

  GeneratedColumn<String> get recordMethod => $composableBuilder(
    column: $table.recordMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discoveryDateSource => $composableBuilder(
    column: $table.discoveryDateSource,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get discoveryDateApproximate => $composableBuilder(
    column: $table.discoveryDateApproximate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<String> get locationSource => $composableBuilder(
    column: $table.locationSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredIdentification => $composableBuilder(
    column: $table.preferredIdentification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timelineFromYear => $composableBuilder(
    column: $table.timelineFromYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timelineToYear => $composableBuilder(
    column: $table.timelineToYear,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lengthMm =>
      $composableBuilder(column: $table.lengthMm, builder: (column) => column);

  GeneratedColumn<double> get widthMm =>
      $composableBuilder(column: $table.widthMm, builder: (column) => column);

  GeneratedColumn<double> get heightMm =>
      $composableBuilder(column: $table.heightMm, builder: (column) => column);

  GeneratedColumn<double> get diameterMm => $composableBuilder(
    column: $table.diameterMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightG =>
      $composableBuilder(column: $table.weightG, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get researchNotes => $composableBuilder(
    column: $table.researchNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sources =>
      $composableBuilder(column: $table.sources, builder: (column) => column);

  GeneratedColumn<String> get storageLocation => $composableBuilder(
    column: $table.storageLocation,
    builder: (column) => column,
  );

  Expression<T> findPhotosRefs<T extends Object>(
    Expression<T> Function($$FindPhotosTableAnnotationComposer a) f,
  ) {
    final $$FindPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.findPhotos,
      getReferencedColumn: (t) => t.findRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FindPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.findPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FindRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FindRecordsTable,
          FindRecord,
          $$FindRecordsTableFilterComposer,
          $$FindRecordsTableOrderingComposer,
          $$FindRecordsTableAnnotationComposer,
          $$FindRecordsTableCreateCompanionBuilder,
          $$FindRecordsTableUpdateCompanionBuilder,
          (FindRecord, $$FindRecordsTableReferences),
          FindRecord,
          PrefetchHooks Function({bool findPhotosRefs})
        > {
  $$FindRecordsTableTableManager(_$AppDatabase db, $FindRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FindRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FindRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FindRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> logNumber = const Value.absent(),
                Value<String> recordMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> discoveredAt = const Value.absent(),
                Value<String> discoveryDateSource = const Value.absent(),
                Value<bool> discoveryDateApproximate = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<String> locationSource = const Value.absent(),
                Value<String> preferredIdentification = const Value.absent(),
                Value<String> material = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<int?> timelineFromYear = const Value.absent(),
                Value<int?> timelineToYear = const Value.absent(),
                Value<double?> lengthMm = const Value.absent(),
                Value<double?> widthMm = const Value.absent(),
                Value<double?> heightMm = const Value.absent(),
                Value<double?> diameterMm = const Value.absent(),
                Value<double?> thicknessMm = const Value.absent(),
                Value<double?> weightG = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<String> researchNotes = const Value.absent(),
                Value<String> sources = const Value.absent(),
                Value<String> storageLocation = const Value.absent(),
              }) => FindRecordsCompanion(
                id: id,
                logNumber: logNumber,
                recordMethod: recordMethod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                discoveredAt: discoveredAt,
                discoveryDateSource: discoveryDateSource,
                discoveryDateApproximate: discoveryDateApproximate,
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracy: horizontalAccuracy,
                altitude: altitude,
                locationSource: locationSource,
                preferredIdentification: preferredIdentification,
                material: material,
                confidence: confidence,
                timelineFromYear: timelineFromYear,
                timelineToYear: timelineToYear,
                lengthMm: lengthMm,
                widthMm: widthMm,
                heightMm: heightMm,
                diameterMm: diameterMm,
                thicknessMm: thicknessMm,
                weightG: weightG,
                observations: observations,
                researchNotes: researchNotes,
                sources: sources,
                storageLocation: storageLocation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String logNumber,
                required String recordMethod,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> discoveredAt = const Value.absent(),
                required String discoveryDateSource,
                Value<bool> discoveryDateApproximate = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                required String locationSource,
                Value<String> preferredIdentification = const Value.absent(),
                Value<String> material = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<int?> timelineFromYear = const Value.absent(),
                Value<int?> timelineToYear = const Value.absent(),
                Value<double?> lengthMm = const Value.absent(),
                Value<double?> widthMm = const Value.absent(),
                Value<double?> heightMm = const Value.absent(),
                Value<double?> diameterMm = const Value.absent(),
                Value<double?> thicknessMm = const Value.absent(),
                Value<double?> weightG = const Value.absent(),
                Value<String> observations = const Value.absent(),
                Value<String> researchNotes = const Value.absent(),
                Value<String> sources = const Value.absent(),
                Value<String> storageLocation = const Value.absent(),
              }) => FindRecordsCompanion.insert(
                id: id,
                logNumber: logNumber,
                recordMethod: recordMethod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                discoveredAt: discoveredAt,
                discoveryDateSource: discoveryDateSource,
                discoveryDateApproximate: discoveryDateApproximate,
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracy: horizontalAccuracy,
                altitude: altitude,
                locationSource: locationSource,
                preferredIdentification: preferredIdentification,
                material: material,
                confidence: confidence,
                timelineFromYear: timelineFromYear,
                timelineToYear: timelineToYear,
                lengthMm: lengthMm,
                widthMm: widthMm,
                heightMm: heightMm,
                diameterMm: diameterMm,
                thicknessMm: thicknessMm,
                weightG: weightG,
                observations: observations,
                researchNotes: researchNotes,
                sources: sources,
                storageLocation: storageLocation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FindRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({findPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (findPhotosRefs) db.findPhotos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (findPhotosRefs)
                    await $_getPrefetchedData<
                      FindRecord,
                      $FindRecordsTable,
                      FindPhoto
                    >(
                      currentTable: table,
                      referencedTable: $$FindRecordsTableReferences
                          ._findPhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FindRecordsTableReferences(
                            db,
                            table,
                            p0,
                          ).findPhotosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.findRecordId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FindRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FindRecordsTable,
      FindRecord,
      $$FindRecordsTableFilterComposer,
      $$FindRecordsTableOrderingComposer,
      $$FindRecordsTableAnnotationComposer,
      $$FindRecordsTableCreateCompanionBuilder,
      $$FindRecordsTableUpdateCompanionBuilder,
      (FindRecord, $$FindRecordsTableReferences),
      FindRecord,
      PrefetchHooks Function({bool findPhotosRefs})
    >;
typedef $$FindPhotosTableCreateCompanionBuilder =
    FindPhotosCompanion Function({
      Value<int> id,
      required int findRecordId,
      required String path,
      required String role,
      required String source,
      required DateTime createdAt,
      required bool isOriginalEvidence,
      required int sortOrder,
    });
typedef $$FindPhotosTableUpdateCompanionBuilder =
    FindPhotosCompanion Function({
      Value<int> id,
      Value<int> findRecordId,
      Value<String> path,
      Value<String> role,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<bool> isOriginalEvidence,
      Value<int> sortOrder,
    });

final class $$FindPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $FindPhotosTable, FindPhoto> {
  $$FindPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FindRecordsTable _findRecordIdTable(_$AppDatabase db) => db
      .findRecords
      .createAlias('find_photos__find_record_id__find_records__id');

  $$FindRecordsTableProcessedTableManager get findRecordId {
    final $_column = $_itemColumn<int>('find_record_id')!;

    final manager = $$FindRecordsTableTableManager(
      $_db,
      $_db.findRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_findRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FindPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $FindPhotosTable> {
  $$FindPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOriginalEvidence => $composableBuilder(
    column: $table.isOriginalEvidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$FindRecordsTableFilterComposer get findRecordId {
    final $$FindRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.findRecordId,
      referencedTable: $db.findRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FindRecordsTableFilterComposer(
            $db: $db,
            $table: $db.findRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FindPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $FindPhotosTable> {
  $$FindPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOriginalEvidence => $composableBuilder(
    column: $table.isOriginalEvidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$FindRecordsTableOrderingComposer get findRecordId {
    final $$FindRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.findRecordId,
      referencedTable: $db.findRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FindRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.findRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FindPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $FindPhotosTable> {
  $$FindPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isOriginalEvidence => $composableBuilder(
    column: $table.isOriginalEvidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$FindRecordsTableAnnotationComposer get findRecordId {
    final $$FindRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.findRecordId,
      referencedTable: $db.findRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FindRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.findRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FindPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FindPhotosTable,
          FindPhoto,
          $$FindPhotosTableFilterComposer,
          $$FindPhotosTableOrderingComposer,
          $$FindPhotosTableAnnotationComposer,
          $$FindPhotosTableCreateCompanionBuilder,
          $$FindPhotosTableUpdateCompanionBuilder,
          (FindPhoto, $$FindPhotosTableReferences),
          FindPhoto,
          PrefetchHooks Function({bool findRecordId})
        > {
  $$FindPhotosTableTableManager(_$AppDatabase db, $FindPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FindPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FindPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FindPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> findRecordId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isOriginalEvidence = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => FindPhotosCompanion(
                id: id,
                findRecordId: findRecordId,
                path: path,
                role: role,
                source: source,
                createdAt: createdAt,
                isOriginalEvidence: isOriginalEvidence,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int findRecordId,
                required String path,
                required String role,
                required String source,
                required DateTime createdAt,
                required bool isOriginalEvidence,
                required int sortOrder,
              }) => FindPhotosCompanion.insert(
                id: id,
                findRecordId: findRecordId,
                path: path,
                role: role,
                source: source,
                createdAt: createdAt,
                isOriginalEvidence: isOriginalEvidence,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FindPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({findRecordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (findRecordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.findRecordId,
                                referencedTable: $$FindPhotosTableReferences
                                    ._findRecordIdTable(db),
                                referencedColumn: $$FindPhotosTableReferences
                                    ._findRecordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FindPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FindPhotosTable,
      FindPhoto,
      $$FindPhotosTableFilterComposer,
      $$FindPhotosTableOrderingComposer,
      $$FindPhotosTableAnnotationComposer,
      $$FindPhotosTableCreateCompanionBuilder,
      $$FindPhotosTableUpdateCompanionBuilder,
      (FindPhoto, $$FindPhotosTableReferences),
      FindPhoto,
      PrefetchHooks Function({bool findRecordId})
    >;
typedef $$CatalogueCountersTableCreateCompanionBuilder =
    CatalogueCountersCompanion Function({
      required String key,
      required int nextValue,
      Value<int> rowid,
    });
typedef $$CatalogueCountersTableUpdateCompanionBuilder =
    CatalogueCountersCompanion Function({
      Value<String> key,
      Value<int> nextValue,
      Value<int> rowid,
    });

class $$CatalogueCountersTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogueCountersTable> {
  $$CatalogueCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogueCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogueCountersTable> {
  $$CatalogueCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogueCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogueCountersTable> {
  $$CatalogueCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get nextValue =>
      $composableBuilder(column: $table.nextValue, builder: (column) => column);
}

class $$CatalogueCountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogueCountersTable,
          CatalogueCounter,
          $$CatalogueCountersTableFilterComposer,
          $$CatalogueCountersTableOrderingComposer,
          $$CatalogueCountersTableAnnotationComposer,
          $$CatalogueCountersTableCreateCompanionBuilder,
          $$CatalogueCountersTableUpdateCompanionBuilder,
          (
            CatalogueCounter,
            BaseReferences<
              _$AppDatabase,
              $CatalogueCountersTable,
              CatalogueCounter
            >,
          ),
          CatalogueCounter,
          PrefetchHooks Function()
        > {
  $$CatalogueCountersTableTableManager(
    _$AppDatabase db,
    $CatalogueCountersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogueCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogueCountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogueCountersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> nextValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogueCountersCompanion(
                key: key,
                nextValue: nextValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int nextValue,
                Value<int> rowid = const Value.absent(),
              }) => CatalogueCountersCompanion.insert(
                key: key,
                nextValue: nextValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogueCountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogueCountersTable,
      CatalogueCounter,
      $$CatalogueCountersTableFilterComposer,
      $$CatalogueCountersTableOrderingComposer,
      $$CatalogueCountersTableAnnotationComposer,
      $$CatalogueCountersTableCreateCompanionBuilder,
      $$CatalogueCountersTableUpdateCompanionBuilder,
      (
        CatalogueCounter,
        BaseReferences<
          _$AppDatabase,
          $CatalogueCountersTable,
          CatalogueCounter
        >,
      ),
      CatalogueCounter,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FindRecordsTableTableManager get findRecords =>
      $$FindRecordsTableTableManager(_db, _db.findRecords);
  $$FindPhotosTableTableManager get findPhotos =>
      $$FindPhotosTableTableManager(_db, _db.findPhotos);
  $$CatalogueCountersTableTableManager get catalogueCounters =>
      $$CatalogueCountersTableTableManager(_db, _db.catalogueCounters);
}
