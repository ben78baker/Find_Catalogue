import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract interface class MediaStore {
  Future<String> preserveOriginal(String sourcePath);
  String resolvePath(String storedPath);
}

class LocalMediaStore implements MediaStore {
  LocalMediaStore({required Directory documentsDirectory, Random? random})
    : _documentsDirectory = documentsDirectory,
      _random = random ?? Random.secure();

  static const _relativeOriginalsDirectory = 'find_catalogue_media/originals';

  final Directory _documentsDirectory;
  final Random _random;

  static Future<LocalMediaStore> create() async => LocalMediaStore(
    documentsDirectory: await getApplicationDocumentsDirectory(),
  );

  @override
  Future<String> preserveOriginal(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('The selected photograph is no longer available.');
    }

    final originals = Directory(
      path.join(_documentsDirectory.path, _relativeOriginalsDirectory),
    );
    await originals.create(recursive: true);

    final extension = path.extension(sourcePath).toLowerCase();
    final safeExtension = extension.isEmpty ? '.jpg' : extension;
    final token = _random.nextInt(0x7fffffff).toRadixString(16);
    final filename =
        '${DateTime.now().microsecondsSinceEpoch}_$token$safeExtension';
    final storedPath = path.join(_relativeOriginalsDirectory, filename);
    await source.copy(resolvePath(storedPath));
    return storedPath;
  }

  @override
  String resolvePath(String storedPath) {
    if (!path.isAbsolute(storedPath)) {
      return path.join(_documentsDirectory.path, storedPath);
    }
    if (File(storedPath).existsSync()) return storedPath;

    final normalised = path.normalize(storedPath);
    final mediaIndex = normalised.indexOf('find_catalogue_media/');
    if (mediaIndex >= 0) {
      return path.join(
        _documentsDirectory.path,
        normalised.substring(mediaIndex),
      );
    }
    return storedPath;
  }
}
