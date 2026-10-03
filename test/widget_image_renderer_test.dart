import 'dart:typed_data';

import 'package:find_catalogue/services/sharing/widget_image_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

void main() {
  testWidgets('renderer produces an exact 1080 by 1350 PNG', (tester) async {
    final renderer = WidgetImageRenderer(
      logicalSize: const Size(360, 450),
      pixelRatio: 3,
    );

    final bytes = (await tester.runAsync(
      () => renderer.renderPng(const ColoredBox(color: Color(0xFFFF0000))),
    ))!;
    final decoded = image.decodePng(bytes);

    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    expect(decoded, isNotNull);
    expect(decoded!.width, 1080);
    expect(decoded.height, 1350);
    expect(decoded.getPixel(540, 675).r, 255);
    expect(decoded.getPixel(540, 675).b, 0);
  });

  testWidgets('repeated rendering does not reuse stale pixels', (tester) async {
    final renderer = WidgetImageRenderer(
      logicalSize: const Size(24, 30),
      pixelRatio: 2,
    );

    final redBytes = (await tester.runAsync(
      () => renderer.renderPng(const ColoredBox(color: Color(0xFFFF0000))),
    ))!;
    final blueBytes = (await tester.runAsync(
      () => renderer.renderPng(const ColoredBox(color: Color(0xFF0000FF))),
    ))!;
    final red = image.decodePng(redBytes)!;
    final blue = image.decodePng(blueBytes)!;

    expect(red.width, 48);
    expect(red.height, 60);
    expect(red.getPixel(24, 30).r, 255);
    expect(red.getPixel(24, 30).b, 0);
    expect(blue.getPixel(24, 30).r, 0);
    expect(blue.getPixel(24, 30).b, 255);
  });

  testWidgets('renderer captures an in-memory image widget', (tester) async {
    final renderer = WidgetImageRenderer(
      logicalSize: const Size(24, 30),
      pixelRatio: 2,
    );
    final source = image.Image(width: 4, height: 4);
    image.fill(source, color: image.ColorRgb8(30, 180, 60));
    final provider = MemoryImage(Uint8List.fromList(image.encodePng(source)));
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.runAsync(() => precacheImage(provider, context));

    final bytes = (await tester.runAsync(
      () => renderer
          .renderPng(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Image(image: provider, fit: BoxFit.cover),
            ),
          )
          .timeout(const Duration(seconds: 10)),
    ))!;
    final decoded = image.decodePng(bytes)!;

    expect(decoded.getPixel(24, 30).g, greaterThan(150));
  });

  testWidgets('renderer reports a missing Flutter view clearly', (
    tester,
  ) async {
    final renderer = WidgetImageRenderer(
      logicalSize: const Size(10, 10),
      pixelRatio: 1,
      viewProvider: () => null,
    );

    await expectLater(
      renderer.renderPng(const SizedBox.expand()),
      throwsA(
        isA<WidgetImageRenderException>().having(
          (error) => error.message,
          'message',
          contains('No Flutter view'),
        ),
      ),
    );
  });

  test('renderer rejects invalid dimensions', () {
    expect(
      () => WidgetImageRenderer(logicalSize: Size.zero, pixelRatio: 3),
      throwsArgumentError,
    );
  });
}
