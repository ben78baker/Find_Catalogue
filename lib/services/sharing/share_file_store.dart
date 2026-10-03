import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'share_artifact.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();
typedef EntityModifiedProvider =
    Future<DateTime> Function(FileSystemEntity entity);

class ShareFileStore {
  ShareFileStore({
    TemporaryDirectoryProvider? temporaryDirectoryProvider,
    EntityModifiedProvider? entityModifiedProvider,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory,
       _entityModifiedProvider =
           entityModifiedProvider ??
           ((entity) async => (await entity.stat()).modified);

  final TemporaryDirectoryProvider _temporaryDirectoryProvider;
  final EntityModifiedProvider _entityModifiedProvider;

  static const _sessionsDirectoryName = 'share_artifact_sessions';

  Future<ShareArtifact> writeArtifact({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final directory = await _temporaryDirectoryProvider();
    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(bytes);
    return ShareArtifact(
      path: file.path,
      fileName: fileName,
      mimeType: mimeType,
    );
  }

  Future<ShareFileSession> createSession({String prefix = 'share_'}) async {
    final root = await _temporaryDirectoryProvider();
    final sessionsDirectory = Directory(
      path.join(root.path, _sessionsDirectoryName),
    );
    await sessionsDirectory.create(recursive: true);
    final safePrefix = prefix.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final directory = await sessionsDirectory.createTemp(safePrefix);
    return ShareFileSession(directory);
  }

  Future<void> deleteStaleSessions({
    Duration maximumAge = const Duration(days: 1),
    DateTime? now,
  }) async {
    final root = await _temporaryDirectoryProvider();
    final sessionsDirectory = Directory(
      path.join(root.path, _sessionsDirectoryName),
    );
    if (!await sessionsDirectory.exists()) return;

    final cutoff = (now ?? DateTime.now()).subtract(maximumAge);
    await for (final entity in sessionsDirectory.list()) {
      if (entity is! Directory) continue;
      final modified = await _entityModifiedProvider(entity);
      if (modified.isBefore(cutoff)) {
        await entity.delete(recursive: true);
      }
    }
  }
}

class ShareFileSession {
  const ShareFileSession(this.directory);

  final Directory directory;

  Future<ShareArtifact> writeArtifact({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(bytes);
    return ShareArtifact(
      path: file.path,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
