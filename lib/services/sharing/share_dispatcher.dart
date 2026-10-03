import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

import 'share_artifact.dart';

typedef ShareInvoker = Future<ShareResult> Function(ShareParams parameters);

class ShareDispatcher {
  ShareDispatcher({ShareInvoker? shareInvoker})
    : _shareInvoker = shareInvoker ?? SharePlus.instance.share;

  final ShareInvoker _shareInvoker;

  Future<void> dispatch({
    required List<ShareArtifact> artifacts,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    if (artifacts.isEmpty) {
      throw ArgumentError('At least one share artifact is required.');
    }

    final result = await _shareInvoker(
      ShareParams(
        subject: subject,
        text: text,
        files: [
          for (final artifact in artifacts)
            XFile(
              artifact.path,
              name: artifact.fileName,
              mimeType: artifact.mimeType,
            ),
        ],
        sharePositionOrigin:
            sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('Sharing is not available on this device.');
    }
  }
}
