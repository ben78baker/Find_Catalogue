import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;

import 'findspot_export_precision.dart';

enum SharePhotoProcessingFailure { unavailable, sanitisationFailed }

class SharePhotoProcessingException implements Exception {
  const SharePhotoProcessingException(this.failure, this.message);

  final SharePhotoProcessingFailure failure;
  final String message;

  @override
  String toString() => message;
}

class ProcessedSharePhoto {
  const ProcessedSharePhoto({
    required this.bytes,
    required this.extension,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String extension;
  final String mimeType;
}

class SharePhotoProcessor {
  const SharePhotoProcessor();

  Future<ProcessedSharePhoto> process(
    String filePath, {
    required FindspotExportPrecision findspotPrecision,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const SharePhotoProcessingException(
        SharePhotoProcessingFailure.unavailable,
        'The photograph file is unavailable.',
      );
    }

    late final Uint8List originalBytes;
    try {
      originalBytes = await file.readAsBytes();
    } catch (_) {
      throw const SharePhotoProcessingException(
        SharePhotoProcessingFailure.unavailable,
        'The photograph file could not be read.',
      );
    }
    final originalExtension = path.extension(file.path).toLowerCase();
    if (findspotPrecision == FindspotExportPrecision.exact) {
      final extension = originalExtension.isEmpty ? '.jpg' : originalExtension;
      return ProcessedSharePhoto(
        bytes: originalBytes,
        extension: extension,
        mimeType: _mimeType(extension),
      );
    }

    image.Image? decoded;
    try {
      decoded = image.decodeImage(originalBytes);
    } catch (_) {
      throw const SharePhotoProcessingException(
        SharePhotoProcessingFailure.sanitisationFailed,
        'Image metadata could not be removed safely.',
      );
    }
    if (decoded == null) {
      throw const SharePhotoProcessingException(
        SharePhotoProcessingFailure.sanitisationFailed,
        'Image metadata could not be removed safely.',
      );
    }
    final sanitised = image.bakeOrientation(decoded)
      ..exif.clear()
      ..textData = null
      ..iccProfile = null;
    if (originalExtension == '.png') {
      return ProcessedSharePhoto(
        bytes: Uint8List.fromList(image.encodePng(sanitised)),
        extension: '.png',
        mimeType: 'image/png',
      );
    }
    return ProcessedSharePhoto(
      bytes: Uint8List.fromList(image.encodeJpg(sanitised, quality: 95)),
      extension: '.jpg',
      mimeType: 'image/jpeg',
    );
  }

  String _mimeType(String extension) => switch (extension) {
    '.png' => 'image/png',
    '.heic' || '.heif' => 'image/heic',
    '.webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
