import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_share_card_factory.dart';
import 'package:find_catalogue/ui/sharing/find_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  const factory = FindShareCardFactory();

  test('factory maps useful fields and the primary photograph', () {
    final data = factory.create(
      _record(
        photos: [
          FindPhoto(
            id: 1,
            path: '/photos/listing.jpg',
            role: FindPhotoRole.front,
            source: FindPhotoSource.camera,
            createdAt: _photoDate,
            isOriginalEvidence: true,
            sortOrder: 0,
          ),
          FindPhoto(
            id: 2,
            path: '/photos/reverse.jpg',
            role: FindPhotoRole.reverse,
            source: FindPhotoSource.camera,
            createdAt: _photoDate,
            isOriginalEvidence: true,
            sortOrder: 1,
          ),
        ],
      ),
    );

    expect(data.heroPhotoPath, '/photos/listing.jpg');
    expect(data.photoStatus, FindShareCardPhotoStatus.available);
    expect(data.title, 'Harness fitting');
    expect(data.discoveryDate, '20 Aug 2026 (approx.)');
    expect(data.facts.map((fact) => fact.label), [
      'Material',
      'Period',
      'Confidence',
    ]);
    expect(data.facts.map((fact) => fact.value), [
      'Copper alloy',
      '50 BCE – 100 CE',
      'Probable',
    ]);
    expect(data.measurements, 'Ø 22.5 mm  ·  T 2.0 mm  ·  L 30.0 mm');
    expect(data.weight, '8.5 g');
  });

  test('presentation model has no location-derived text', () {
    final data = factory.create(_record());
    final displayedText = [
      data.logNumber,
      data.title,
      if (data.discoveryDate != null) data.discoveryDate!,
      ...data.facts.expand((fact) => [fact.label, fact.value]),
      if (data.measurements != null) data.measurements!,
      if (data.weight != null) data.weight!,
      if (data.observations != null) data.observations!,
      FindShareCardData.privacyLabel,
    ].join(' ');

    expect(displayedText, isNot(contains('51.123456')));
    expect(displayedText, isNot(contains('-1.234567')));
    expect(displayedText, isNot(contains('4.2')));
    expect(FindShareCardData.privacyLabel, 'Findspot not shared');
  });

  test(
    'optional fields are omitted and missing titles use the domain fallback',
    () {
      final data = factory.create(
        _record(
          identification: '  ',
          material: '',
          confidence: IdentificationConfidence.unassessed,
          includeDiscoveryDate: false,
          fromYear: null,
          toYear: null,
          diameter: null,
          thickness: null,
          length: null,
          width: null,
          weight: null,
          observations: '',
        ),
      );

      expect(data.title, 'Unidentified object');
      expect(data.discoveryDate, isNull);
      expect(data.facts, isEmpty);
      expect(data.measurements, isNull);
      expect(data.weight, isNull);
      expect(data.observations, isNull);
      expect(data.heroPhotoPath, isNull);
      expect(data.photoStatus, FindShareCardPhotoStatus.none);
    },
  );

  test('measurements favour a compact useful subset', () {
    final diameterOnly = factory.create(
      _record(diameter: 18.25, thickness: null, length: null, width: null),
    );
    final rectangular = factory.create(
      _record(diameter: null, length: 40, width: 16, thickness: 3),
    );

    expect(diameterOnly.measurements, 'Ø 18.25 mm');
    expect(rectangular.measurements, 'L 40.0 mm  ·  W 16.0 mm  ·  T 3.0 mm');
  });

  test('long observations become a deterministic short excerpt', () {
    final data = factory.create(
      _record(observations: List.filled(50, 'carefully observed').join(' ')),
    );

    expect(data.observations, endsWith('…'));
    expect(data.observations!.runes.length, lessThanOrEqualTo(141));
  });

  testWidgets(
    'card contains branding, privacy text, and bounded long content',
    (tester) async {
      final longTitle = List.filled(20, 'Decorated medieval fitting').join(' ');
      final data = factory.create(
        _record(
          identification: longTitle,
          observations: List.filled(40, 'Detailed observation').join(' '),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Center(child: FindShareCard(data: data)),
        ),
      );

      expect(find.text(FindShareCardData.appName), findsOneWidget);
      expect(find.text(FindShareCardData.privacyLabel), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_outlined), findsNothing);
      final title = tester.widget<Text>(find.text(longTitle));
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);
      final observations = tester.widget<Text>(find.text(data.observations!));
      expect(observations.maxLines, 2);
      expect(observations.overflow, TextOverflow.ellipsis);
    },
  );

  testWidgets('card shows a neutral no-photo placeholder', (tester) async {
    final data = factory.create(_record());

    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: FindShareCard(data: data)),
      ),
    );

    expect(find.text('No photograph available'), findsOneWidget);
    expect(
      find.byKey(const Key('find_share_card_full_photo_inset')),
      findsNothing,
    );
  });

  group('adaptive full-photo inset', () {
    final cases = <({String name, Size source, Size displayed})>[
      (
        name: 'portrait',
        source: const Size(60, 120),
        displayed: const Size(36, 72),
      ),
      (
        name: 'landscape',
        source: const Size(120, 60),
        displayed: const Size(96, 48),
      ),
      (
        name: 'square',
        source: const Size(100, 100),
        displayed: const Size(72, 72),
      ),
      (
        name: 'very wide',
        source: const Size(400, 50),
        displayed: const Size(96, 12),
      ),
      (
        name: 'very tall',
        source: const Size(50, 400),
        displayed: const Size(9, 72),
      ),
      (
        name: 'small',
        source: const Size(20, 10),
        displayed: const Size(20, 10),
      ),
    ];

    for (final testCase in cases) {
      testWidgets('${testCase.name} photo hugs its adaptive container', (
        tester,
      ) async {
        final decoded = await _decodeTestImage(
          tester,
          testCase.source.width.toInt(),
          testCase.source.height.toInt(),
        );
        final data = factory.create(
          _record(
            photos: [
              FindPhoto(
                id: 1,
                path: '/photos/${testCase.name}.png',
                role: FindPhotoRole.front,
                source: FindPhotoSource.camera,
                createdAt: _photoDate,
                isOriginalEvidence: true,
                sortOrder: 0,
              ),
            ],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: FindShareCard(data: data, heroImage: decoded),
            ),
          ),
        );

        final heroFinder = find.byKey(const Key('find_share_card_hero_image'));
        final imageFinder = find.byKey(
          const Key('find_share_card_full_photo_image'),
        );
        final containerFinder = find.byKey(
          const Key('find_share_card_full_photo_inset'),
        );
        final hero = tester.widget<RawImage>(heroFinder);
        final inset = tester.widget<RawImage>(imageFinder);
        final displayedSize = tester.getSize(imageFinder);
        final containerSize = tester.getSize(containerFinder);
        final heroRect = tester.getRect(heroFinder);
        final containerRect = tester.getRect(containerFinder);

        expect(hero.image, same(decoded));
        expect(hero.fit, BoxFit.cover);
        expect(inset.image, same(decoded));
        expect(inset.fit, BoxFit.contain);
        expect(displayedSize.width, closeTo(testCase.displayed.width, 0.01));
        expect(displayedSize.height, closeTo(testCase.displayed.height, 0.01));
        expect(
          displayedSize.width / displayedSize.height,
          closeTo(testCase.source.width / testCase.source.height, 0.001),
        );
        expect(
          displayedSize.width,
          lessThanOrEqualTo(FindShareCard.fullPhotoInsetMaxImageSize.width),
        );
        expect(
          displayedSize.height,
          lessThanOrEqualTo(FindShareCard.fullPhotoInsetMaxImageSize.height),
        );
        expect(
          containerSize.width,
          closeTo(
            displayedSize.width + FindShareCard.fullPhotoInsetPadding * 2,
            0.01,
          ),
        );
        expect(
          containerSize.height,
          closeTo(
            displayedSize.height + FindShareCard.fullPhotoInsetPadding * 2,
            0.01,
          ),
        );
        expect(containerRect.left, greaterThanOrEqualTo(heroRect.left));
        expect(containerRect.top, greaterThanOrEqualTo(heroRect.top));
        expect(heroRect.right - containerRect.right, closeTo(8, 0.01));
        expect(heroRect.bottom - containerRect.bottom, closeTo(8, 0.01));

        await tester.pumpWidget(const SizedBox.shrink());
        decoded.dispose();
      });
    }
  });
}

Future<ui.Image> _decodeTestImage(
  WidgetTester tester,
  int width,
  int height,
) async {
  final source = image.Image(width: width, height: height);
  image.fill(source, color: image.ColorRgb8(70, 120, 50));
  late final ui.Image decoded;
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(
      Uint8List.fromList(image.encodePng(source)),
    );
    decoded = (await codec.getNextFrame()).image;
    codec.dispose();
  });
  return decoded;
}

final _photoDate = DateTime(2026, 8, 20);

FindRecord _record({
  String identification = 'Harness fitting',
  String material = 'Copper alloy',
  IdentificationConfidence confidence = IdentificationConfidence.probable,
  bool includeDiscoveryDate = true,
  int? fromYear = -50,
  int? toYear = 100,
  double? length = 30,
  double? width = 14,
  double? diameter = 22.5,
  double? thickness = 2,
  double? weight = 8.5,
  String observations = 'Regular diagonal grooves survive on the edge.',
  List<FindPhoto> photos = const [],
}) {
  final now = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: 1,
    logNumber: 'FO-000001',
    method: FindRecordMethod.manual,
    createdAt: now,
    updatedAt: now,
    discoveredAt: includeDiscoveryDate ? DateTime(2026, 8, 20) : null,
    discoveryDateSource: FieldSource.manuallyEntered,
    discoveryDateApproximate: true,
    location: const FindLocation(
      latitude: 51.123456,
      longitude: -1.234567,
      horizontalAccuracy: 4.2,
      source: FieldSource.manuallyEntered,
    ),
    preferredIdentification: identification,
    material: material,
    confidence: confidence,
    timelineFromYear: fromYear,
    timelineToYear: toYear,
    lengthMm: length,
    widthMm: width,
    heightMm: null,
    diameterMm: diameter,
    thicknessMm: thickness,
    weightG: weight,
    observations: observations,
    researchNotes: 'Private research notes',
    sources: 'Private reference',
    storageLocation: 'Private storage box',
    photos: photos,
  );
}
