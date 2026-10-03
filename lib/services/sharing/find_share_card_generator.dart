import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/find_record.dart';
import '../../ui/sharing/find_share_card.dart';
import 'find_share_card_factory.dart';
import 'share_artifact.dart';
import 'share_file_store.dart';
import 'widget_image_renderer.dart';

class FindShareCardGenerator {
  FindShareCardGenerator({
    FindShareCardFactory? factory,
    WidgetImageRenderer? renderer,
    ShareFileStore? fileStore,
    ShareCardImageDecoder? imageDecoder,
  }) : _factory = factory ?? const FindShareCardFactory(),
       _renderer =
           renderer ??
           WidgetImageRenderer(
             logicalSize: FindShareCard.logicalSize,
             pixelRatio: FindShareCard.outputPixelRatio,
           ),
       _fileStore = fileStore ?? ShareFileStore(),
       _imageDecoder = imageDecoder ?? const ShareCardImageDecoder();

  final FindShareCardFactory _factory;
  final WidgetImageRenderer _renderer;
  final ShareFileStore _fileStore;
  final ShareCardImageDecoder _imageDecoder;

  Future<ShareArtifact> generateOne(FindRecord record) async =>
      (await generateMany([record])).single;

  Future<List<ShareArtifact>> generateMany(List<FindRecord> records) async {
    if (records.isEmpty) {
      throw ArgumentError('At least one find record is required.');
    }
    await _fileStore.deleteStaleSessions();
    final session = await _fileStore.createSession(prefix: 'find_share_cards_');
    final brandingImage = await _imageDecoder.decodeAsset(
      FindShareCard.appIconAsset,
      targetWidth: 84,
    );

    final artifacts = <ShareArtifact>[];
    try {
      for (final entry in records.indexed) {
        var data = _factory.create(entry.$2);
        ui.Image? heroImage;
        if (data.heroPhotoPath != null) {
          final file = File(data.heroPhotoPath!);
          if (await file.exists()) {
            try {
              heroImage = await _imageDecoder.decodeFile(
                file.path,
                targetWidth: FindShareCard.outputWidth,
              );
            } catch (_) {
              data = data.withUnavailablePhoto();
            }
          } else {
            data = data.withUnavailablePhoto();
          }
        }

        try {
          final pngBytes = await _renderer.renderPng(
            Directionality(
              textDirection: TextDirection.ltr,
              child: FindShareCard(
                data: data,
                heroImage: heroImage,
                brandingImage: brandingImage,
              ),
            ),
          );
          final sequence = (entry.$1 + 1).toString().padLeft(2, '0');
          final logNumber = _safeFileComponent(data.logNumber);
          artifacts.add(
            await session.writeArtifact(
              fileName: '${sequence}_${logNumber}_share_card.png',
              mimeType: 'image/png',
              bytes: pngBytes,
            ),
          );
        } finally {
          heroImage?.dispose();
        }
      }
    } finally {
      brandingImage.dispose();
    }
    return artifacts;
  }

  String _safeFileComponent(String value) {
    final safe = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return safe.isEmpty ? 'find' : safe;
  }
}

class ShareCardImageDecoder {
  const ShareCardImageDecoder();

  Future<ui.Image> decodeAsset(
    String assetKey, {
    required int targetWidth,
  }) async {
    final bytes = await rootBundle.load(assetKey);
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    return _decode(buffer, targetWidth: targetWidth);
  }

  Future<ui.Image> decodeFile(
    String filePath, {
    required int targetWidth,
  }) async {
    final buffer = await ui.ImmutableBuffer.fromFilePath(filePath);
    return _decode(buffer, targetWidth: targetWidth);
  }

  Future<ui.Image> _decode(
    ui.ImmutableBuffer buffer, {
    required int targetWidth,
  }) async {
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      codec = await descriptor.instantiateCodec(
        targetWidth: math.min(descriptor.width, targetWidth),
      );
      return (await codec.getNextFrame()).image;
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }
}
