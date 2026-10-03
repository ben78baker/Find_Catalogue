import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'share_artifact.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();

class ShareFileStore {
  ShareFileStore({TemporaryDirectoryProvider? temporaryDirectoryProvider})
    : _temporaryDirectoryProvider =
          temporaryDirectoryProvider ?? getTemporaryDirectory;

  final TemporaryDirectoryProvider _temporaryDirectoryProvider;

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
}
