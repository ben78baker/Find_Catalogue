import 'dart:ui' show Rect;

import 'package:find_catalogue/services/sharing/share_artifact.dart';
import 'package:find_catalogue/services/sharing/share_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test(
    'dispatcher passes multiple prepared artifacts to the share sheet',
    () async {
      ShareParams? captured;
      final dispatcher = ShareDispatcher(
        shareInvoker: (parameters) async {
          captured = parameters;
          return const ShareResult('test', ShareResultStatus.success);
        },
      );
      const origin = Rect.fromLTWH(10, 20, 30, 40);

      await dispatcher.dispatch(
        artifacts: const [
          ShareArtifact(
            path: '/temporary/first.png',
            fileName: 'first.png',
            mimeType: 'image/png',
          ),
          ShareArtifact(
            path: '/temporary/second.jpg',
            fileName: 'second.jpg',
            mimeType: 'image/jpeg',
          ),
        ],
        subject: 'Find Catalogue records',
        text: 'Two shared records.',
        sharePositionOrigin: origin,
      );

      expect(captured, isNotNull);
      expect(captured!.subject, 'Find Catalogue records');
      expect(captured!.text, 'Two shared records.');
      expect(captured!.sharePositionOrigin, origin);
      expect(captured!.files, hasLength(2));
      expect(captured!.files![0].path, '/temporary/first.png');
      expect(captured!.files![0].name, 'first.png');
      expect(captured!.files![0].mimeType, 'image/png');
      expect(captured!.files![1].path, '/temporary/second.jpg');
      expect(captured!.files![1].name, 'second.jpg');
      expect(captured!.files![1].mimeType, 'image/jpeg');
    },
  );

  test('dispatcher rejects an empty artifact list', () {
    final dispatcher = ShareDispatcher(
      shareInvoker: (_) async => ShareResult.unavailable,
    );

    expect(dispatcher.dispatch(artifacts: const []), throwsArgumentError);
  });
}
