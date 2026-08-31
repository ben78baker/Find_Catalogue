import 'dart:io';
import 'dart:math';

import 'package:find_catalogue/services/media_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves originals using a portable stored path', () async {
    final root = await Directory.systemTemp.createTemp(
      'find_catalogue_media_store_',
    );
    try {
      final documents = Directory('${root.path}/current/Documents');
      await documents.create(recursive: true);
      final source = File('${root.path}/picked.jpg');
      await source.writeAsBytes([1, 2, 3, 4]);
      final store = LocalMediaStore(
        documentsDirectory: documents,
        random: Random(1),
      );

      final storedPath = await store.preserveOriginal(source.path);
      final resolvedPath = store.resolvePath(storedPath);

      expect(storedPath, startsWith('find_catalogue_media/originals/'));
      expect(storedPath, isNot(startsWith('/')));
      expect(await File(resolvedPath).readAsBytes(), [1, 2, 3, 4]);
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('repairs a legacy absolute iOS container path', () async {
    final root = await Directory.systemTemp.createTemp(
      'find_catalogue_media_store_',
    );
    try {
      final documents = Directory('${root.path}/NEW/Documents');
      final currentPhoto = File(
        '${documents.path}/find_catalogue_media/originals/discovery.jpg',
      );
      await currentPhoto.parent.create(recursive: true);
      await currentPhoto.writeAsBytes([1, 2, 3]);
      final store = LocalMediaStore(
        documentsDirectory: documents,
        random: Random(1),
      );

      final resolved = store.resolvePath(
        '/private/var/mobile/Containers/Data/Application/OLD/Documents/'
        'find_catalogue_media/originals/discovery.jpg',
      );

      expect(resolved, currentPhoto.path);
      expect(File(resolved).existsSync(), isTrue);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
