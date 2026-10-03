import 'dart:io';
import 'dart:math' as math;

import 'package:find_catalogue/domain/find_record.dart';
import 'package:find_catalogue/services/sharing/find_share_card_generator.dart';
import 'package:find_catalogue/services/sharing/share_file_store.dart';
import 'package:find_catalogue/services/sharing/widget_image_renderer.dart';
import 'package:find_catalogue/ui/sharing/find_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  testWidgets('generator creates an exact PNG using only the primary photo', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_generator_',
      );
      try {
        final first = File('${directory.path}/primary.jpg');
        final second = File('${directory.path}/second.jpg');
        final primaryImage = _solidImage(80, 40, 220, 35, 25)
          ..exif.gpsIfd.setGpsLocation(
            latitude: 51.123456,
            longitude: -1.234567,
          );
        final primaryBytes = image.encodeJpg(primaryImage, quality: 100);
        await first.writeAsBytes(primaryBytes);
        await second.writeAsBytes(
          image.encodeJpg(_solidImage(40, 80, 20, 40, 220), quality: 100),
        );
        final generator = _generator(directory);
        final record = _record(
          1,
          photos: [_photo(1, first.path, 0), _photo(2, second.path, 1)],
        );

        final artifact = await generator.generateOne(record);
        final decoded = image.decodePng(
          await File(artifact.path).readAsBytes(),
        )!;
        final heroCentre = decoded.getPixel(540, 417);

        expect(artifact.fileName, '01_FO-000001_share_card.png');
        expect(artifact.mimeType, 'image/png');
        expect(decoded.width, FindShareCard.outputWidth);
        expect(decoded.height, FindShareCard.outputHeight);
        expect(heroCentre.r, greaterThan(180));
        expect(heroCentre.g, lessThan(80));
        expect(heroCentre.b, lessThan(80));
        expect(decoded.exif.gpsIfd.hasGPSLatitude, isFalse);
        expect(decoded.exif.gpsIfd.hasGPSLongitude, isFalse);
        expect(await first.readAsBytes(), primaryBytes);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('portrait and landscape primary photos both centre-crop', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_orientation_',
      );
      try {
        final portrait = File('${directory.path}/portrait.png');
        final landscape = File('${directory.path}/landscape.png');
        await portrait.writeAsBytes(
          image.encodePng(_solidImage(40, 100, 20, 190, 60)),
        );
        await landscape.writeAsBytes(
          image.encodePng(_solidImage(100, 40, 225, 190, 20)),
        );
        final generator = _generator(directory);

        final artifacts = await generator.generateMany([
          _record(1, photos: [_photo(1, portrait.path, 0)]),
          _record(2, photos: [_photo(2, landscape.path, 0)]),
        ]);
        final portraitCard = image.decodePng(
          await File(artifacts[0].path).readAsBytes(),
        )!;
        final landscapeCard = image.decodePng(
          await File(artifacts[1].path).readAsBytes(),
        )!;
        final portraitCentre = portraitCard.getPixel(540, 417);
        final landscapeCentre = landscapeCard.getPixel(540, 417);

        expect(portraitCentre.g, greaterThan(150));
        expect(landscapeCentre.r, greaterThan(180));
        expect(landscapeCentre.g, greaterThan(150));
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('wide primary photo remains complete in the contained inset', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_inset_',
      );
      try {
        final primary = File('${directory.path}/wide.png');
        await primary.writeAsBytes(image.encodePng(_wideEdgeMarkedImage()));

        final artifact = await _generator(
          directory,
        ).generateOne(_record(1, photos: [_photo(1, primary.path, 0)]));
        final decoded = image.decodePng(
          await File(artifact.path).readAsBytes(),
        )!;

        // The cover crop shows the green centre, while both coloured edges
        // remain visible in the 96 x 72 logical contained inset.
        final heroCentre = decoded.getPixel(540, 414);
        final insetLeft = decoded.getPixel(720, 522);
        final insetRight = decoded.getPixel(960, 522);

        expect(decoded.width, FindShareCard.outputWidth);
        expect(decoded.height, FindShareCard.outputHeight);
        expect(heroCentre.g, greaterThan(180));
        expect(heroCentre.r, lessThan(80));
        expect(insetLeft.r, greaterThan(180));
        expect(insetLeft.b, lessThan(80));
        expect(insetRight.b, greaterThan(180));
        expect(insetRight.r, lessThan(80));
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('absent, missing, and corrupt photos still generate cards', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_missing_',
      );
      try {
        final renderer = _TrackingRenderer();
        final generator = _generator(directory, renderer: renderer);
        final corrupt = File('${directory.path}/corrupt.jpg');
        await corrupt.writeAsBytes([1, 2, 3, 4, 5]);

        final artifacts = await generator.generateMany([
          _record(1),
          _record(2, photos: [_photo(2, '${directory.path}/missing.jpg', 0)]),
          _record(3, photos: [_photo(3, corrupt.path, 0)]),
        ]);

        expect(artifacts, hasLength(3));
        expect(
          renderer.cards[0].data.photoStatus,
          FindShareCardPhotoStatus.none,
        );
        expect(
          renderer.cards[1].data.photoStatus,
          FindShareCardPhotoStatus.unavailable,
        );
        expect(
          renderer.cards[2].data.photoStatus,
          FindShareCardPhotoStatus.unavailable,
        );
        expect(renderer.cards[0].heroImage, isNull);
        expect(renderer.cards[1].heroImage, isNull);
        expect(renderer.cards[2].heroImage, isNull);
        expect(await corrupt.readAsBytes(), [1, 2, 3, 4, 5]);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('multiple cards preserve order, filenames, and sequential work', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_multiple_',
      );
      try {
        final renderer = _TrackingRenderer();
        final generator = _generator(directory, renderer: renderer);

        final artifacts = await generator.generateMany([
          _record(7, logNumber: 'FO/unsafe 7'),
          _record(3),
          _record(9),
        ]);

        expect(artifacts, hasLength(3));
        expect(artifacts.map((artifact) => artifact.fileName), [
          '01_FO_unsafe_7_share_card.png',
          '02_FO-000003_share_card.png',
          '03_FO-000009_share_card.png',
        ]);
        expect(renderer.logNumbers, ['FO/unsafe 7', 'FO-000003', 'FO-000009']);
        expect(renderer.maximumConcurrentRenders, 1);
        expect(
          artifacts.map((artifact) => artifact.path).toSet(),
          hasLength(3),
        );
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('writes a representative preview when requested', (tester) async {
    final outputPath = Platform.environment['FIND_SHARE_CARD_PREVIEW_PATH'];
    if (outputPath == null || outputPath.isEmpty) return;
    final fontDirectory =
        Platform.environment['FIND_SHARE_CARD_PREVIEW_FONT_DIRECTORY'];
    final suppliedPhotoPath =
        Platform.environment['FIND_SHARE_CARD_PREVIEW_PHOTO_PATH'];

    await tester.runAsync(() async {
      if (fontDirectory != null && fontDirectory.isNotEmpty) {
        await _loadPreviewFonts(fontDirectory);
      }
      final directory = await Directory.systemTemp.createTemp(
        'find_share_card_preview_',
      );
      try {
        final hasSuppliedPhoto =
            suppliedPhotoPath != null && suppliedPhotoPath.isNotEmpty;
        final hero = hasSuppliedPhoto
            ? File(suppliedPhotoPath)
            : File('${directory.path}/preview_hero.jpg');
        if (!hasSuppliedPhoto) {
          await hero.writeAsBytes(image.encodeJpg(_previewHero(), quality: 94));
        }
        final artifact =
            await _generator(
              directory,
              renderer: fontDirectory == null || fontDirectory.isEmpty
                  ? null
                  : _PreviewRenderer(),
            ).generateOne(
              _record(
                42,
                identification: hasSuppliedPhoto
                    ? 'Copper-alloy coin'
                    : 'Medieval copper-alloy harness pendant',
                observations: hasSuppliedPhoto
                    ? 'Surface detail and green patina are visible under angled light.'
                    : 'A small gilded pendant with surviving punched decoration and a complete suspension loop.',
                photos: [_photo(1, hero.path, 0)],
              ),
            );
        final output = File(outputPath);
        await output.parent.create(recursive: true);
        await File(artifact.path).copy(output.path);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}

class _PreviewRenderer extends WidgetImageRenderer {
  _PreviewRenderer()
    : super(logicalSize: FindShareCard.logicalSize, pixelRatio: 3);

  @override
  Future<Uint8List> renderPng(Widget widget) => super.renderPng(
    DefaultTextStyle(
      style: const TextStyle(fontFamily: 'Roboto'),
      child: widget,
    ),
  );
}

FindShareCardGenerator _generator(
  Directory directory, {
  WidgetImageRenderer? renderer,
}) => FindShareCardGenerator(
  renderer: renderer,
  fileStore: ShareFileStore(temporaryDirectoryProvider: () async => directory),
);

class _TrackingRenderer extends WidgetImageRenderer {
  _TrackingRenderer()
    : super(logicalSize: FindShareCard.logicalSize, pixelRatio: 3);

  final cards = <FindShareCard>[];
  final logNumbers = <String>[];
  var _activeRenders = 0;
  var maximumConcurrentRenders = 0;

  @override
  Future<Uint8List> renderPng(Widget widget) async {
    _activeRenders++;
    maximumConcurrentRenders = math.max(
      maximumConcurrentRenders,
      _activeRenders,
    );
    final card = (widget as Directionality).child as FindShareCard;
    cards.add(card);
    logNumbers.add(card.data.logNumber);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    _activeRenders--;
    return Uint8List.fromList(image.encodePng(_solidImage(2, 2, 0, 0, 0)));
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

FindRecord _record(
  int id, {
  String? logNumber,
  String identification = 'Harness fitting',
  String observations = 'Regular diagonal grooves survive on the edge.',
  List<FindPhoto> photos = const [],
}) {
  final now = DateTime(2026, 8, 30, 12);
  return FindRecord(
    id: id,
    logNumber: logNumber ?? 'FO-${id.toString().padLeft(6, '0')}',
    method: FindRecordMethod.manual,
    createdAt: now,
    updatedAt: now,
    discoveredAt: DateTime(2026, 8, 20),
    discoveryDateSource: FieldSource.manuallyEntered,
    discoveryDateApproximate: false,
    location: const FindLocation(
      latitude: 51.123456,
      longitude: -1.234567,
      horizontalAccuracy: 4.2,
      source: FieldSource.manuallyEntered,
    ),
    preferredIdentification: identification,
    material: 'Copper alloy',
    confidence: IdentificationConfidence.probable,
    timelineFromYear: 1200,
    timelineToYear: 1400,
    lengthMm: 31,
    widthMm: 21,
    heightMm: null,
    diameterMm: null,
    thicknessMm: 2.5,
    weightG: 9.4,
    observations: observations,
    researchNotes: 'Private research notes',
    sources: 'Private reference',
    storageLocation: 'Private storage box',
    photos: photos,
  );
}

image.Image _solidImage(int width, int height, int red, int green, int blue) {
  final result = image.Image(width: width, height: height);
  image.fill(result, color: image.ColorRgb8(red, green, blue));
  return result;
}

image.Image _wideEdgeMarkedImage() {
  final result = image.Image(width: 200, height: 50);
  for (var y = 0; y < result.height; y++) {
    for (var x = 0; x < result.width; x++) {
      if (x < 50) {
        result.setPixelRgb(x, y, 230, 25, 25);
      } else if (x >= 150) {
        result.setPixelRgb(x, y, 25, 25, 230);
      } else {
        result.setPixelRgb(x, y, 25, 210, 25);
      }
    }
  }
  return result;
}

Future<void> _loadPreviewFonts(String directory) async {
  Future<ByteData> fontData(String fileName) async =>
      ByteData.sublistView(await File('$directory/$fileName').readAsBytes());

  await (FontLoader('Roboto')
        ..addFont(fontData('Roboto-Regular.ttf'))
        ..addFont(fontData('Roboto-Bold.ttf'))
        ..addFont(fontData('Roboto-Italic.ttf')))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(fontData('MaterialIcons-Regular.otf'))).load();
}

image.Image _previewHero() {
  const width = 900;
  const height = 520;
  final result = image.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final noise = ((x * 13 + y * 7) % 18) - 9;
      result.setPixelRgb(
        x,
        y,
        (112 + noise).clamp(0, 255),
        (91 + noise).clamp(0, 255),
        (61 + noise).clamp(0, 255),
      );
    }
  }
  const centreX = 450;
  const centreY = 260;
  const radius = 155;
  for (var y = centreY - radius; y <= centreY + radius; y++) {
    for (var x = centreX - radius; x <= centreX + radius; x++) {
      final dx = x - centreX;
      final dy = y - centreY;
      final distance = math.sqrt(dx * dx + dy * dy);
      if (distance <= radius) {
        final shade = (1 - distance / radius) * 38;
        result.setPixelRgb(
          x,
          y,
          (139 + shade).round().clamp(0, 255),
          (104 + shade).round().clamp(0, 255),
          (48 + shade / 2).round().clamp(0, 255),
        );
      }
    }
  }
  image.drawCircle(
    result,
    x: centreX,
    y: centreY,
    radius: radius,
    color: image.ColorRgb8(70, 52, 29),
    antialias: true,
  );
  image.drawCircle(
    result,
    x: centreX,
    y: centreY,
    radius: 108,
    color: image.ColorRgb8(91, 67, 31),
    antialias: true,
  );
  return result;
}
