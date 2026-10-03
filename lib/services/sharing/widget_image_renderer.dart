import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef FlutterViewProvider = ui.FlutterView? Function();

class WidgetImageRenderException implements Exception {
  const WidgetImageRenderException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'WidgetImageRenderException: $message'
      : 'WidgetImageRenderException: $message ($cause)';
}

class WidgetImageRenderer {
  WidgetImageRenderer({
    required this.logicalSize,
    required this.pixelRatio,
    FlutterViewProvider? viewProvider,
  }) : _viewProvider =
           viewProvider ??
           (() => WidgetsBinding.instance.platformDispatcher.implicitView) {
    if (logicalSize.isEmpty || pixelRatio <= 0) {
      throw ArgumentError('Logical size and pixel ratio must be positive.');
    }
  }

  final Size logicalSize;
  final double pixelRatio;
  final FlutterViewProvider _viewProvider;

  int get outputWidth => (logicalSize.width * pixelRatio).round();
  int get outputHeight => (logicalSize.height * pixelRatio).round();

  Future<Uint8List> renderPng(Widget widget) async {
    final view = _viewProvider();
    if (view == null) {
      throw const WidgetImageRenderException(
        'No Flutter view is available for off-screen rendering.',
      );
    }

    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: view,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        physicalConstraints: BoxConstraints.tight(logicalSize),
        devicePixelRatio: 1,
      ),
      child: repaintBoundary,
    );
    final pipelineOwner = PipelineOwner();
    final focusManager = FocusManager();
    final buildOwner = BuildOwner(focusManager: focusManager);
    RenderObjectToWidgetElement<RenderBox>? root;

    try {
      renderView.attach(pipelineOwner);
      renderView.prepareInitialFrame();
      root = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        debugShortDescription: '[share image root]',
        child: SizedBox.fromSize(size: logicalSize, child: widget),
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(root);
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();
      buildOwner.finalizeTree();

      final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
      try {
        if (image.width != outputWidth || image.height != outputHeight) {
          throw WidgetImageRenderException(
            'Rendered ${image.width}x${image.height}; expected '
            '${outputWidth}x$outputHeight.',
          );
        }
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          throw const WidgetImageRenderException(
            'Flutter could not encode the rendered widget as PNG.',
          );
        }
        return byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
      } finally {
        image.dispose();
      }
    } on WidgetImageRenderException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WidgetImageRenderException('Widget rendering failed.', error),
        stackTrace,
      );
    } finally {
      if (root != null) {
        root = RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          debugShortDescription: '[share image root]',
        ).attachToRenderTree(buildOwner, root);
        buildOwner.buildScope(root);
        buildOwner.finalizeTree();
      }
      if (renderView.attached) renderView.detach();
      focusManager.dispose();
    }
  }
}
