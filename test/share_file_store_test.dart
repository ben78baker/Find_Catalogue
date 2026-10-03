import 'dart:io';

import 'package:find_catalogue/services/sharing/share_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'session stores multiple artifacts in one operation directory',
    () async {
      final root = await Directory.systemTemp.createTemp('share_file_store_');
      try {
        final store = ShareFileStore(
          temporaryDirectoryProvider: () async => root,
        );
        final session = await store.createSession(prefix: 'cards/unsafe ');
        final first = await session.writeArtifact(
          fileName: 'first.png',
          mimeType: 'image/png',
          bytes: [1, 2, 3],
        );
        final second = await session.writeArtifact(
          fileName: 'second.png',
          mimeType: 'image/png',
          bytes: [4, 5, 6],
        );

        expect(first.path, startsWith(session.directory.path));
        expect(second.path, startsWith(session.directory.path));
        expect(session.directory.path, contains('cards_unsafe_'));
        expect(await File(first.path).readAsBytes(), [1, 2, 3]);
        expect(await File(second.path).readAsBytes(), [4, 5, 6]);
      } finally {
        await root.delete(recursive: true);
      }
    },
  );

  test('stale-session cleanup leaves recent sessions available', () async {
    final root = await Directory.systemTemp.createTemp('share_file_cleanup_');
    try {
      final modifiedByPath = <String, DateTime>{};
      final store = ShareFileStore(
        temporaryDirectoryProvider: () async => root,
        entityModifiedProvider: (entity) async => modifiedByPath[entity.path]!,
      );
      final oldSession = await store.createSession(prefix: 'old_');
      final recentSession = await store.createSession(prefix: 'recent_');
      final now = DateTime(2026, 9, 1, 12);
      modifiedByPath[oldSession.directory.path] = now.subtract(
        const Duration(days: 3),
      );
      modifiedByPath[recentSession.directory.path] = now.subtract(
        const Duration(hours: 2),
      );

      await store.deleteStaleSessions(
        maximumAge: const Duration(days: 1),
        now: now,
      );

      expect(await oldSession.directory.exists(), isFalse);
      expect(await recentSession.directory.exists(), isTrue);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
