import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../domain/find_record.dart';

class PickedFindPhoto {
  const PickedFindPhoto({
    required this.temporaryPath,
    required this.source,
    required this.createdAt,
  });

  final String temporaryPath;
  final FindPhotoSource source;
  final DateTime createdAt;
}

abstract interface class PhotoCaptureService {
  bool get supportsCamera;
  Future<PickedFindPhoto?> takePhoto();
  Future<PickedFindPhoto?> choosePhoto();
}

class ImagePickerPhotoCaptureService implements PhotoCaptureService {
  ImagePickerPhotoCaptureService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool get supportsCamera => Platform.isAndroid || Platform.isIOS;

  @override
  Future<PickedFindPhoto?> takePhoto() async {
    if (!supportsCamera) return choosePhoto();
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
    );
    return _toPicked(file, FindPhotoSource.camera);
  }

  @override
  Future<PickedFindPhoto?> choosePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: true,
    );
    return _toPicked(file, FindPhotoSource.library);
  }

  PickedFindPhoto? _toPicked(XFile? file, FindPhotoSource source) {
    if (file == null) return null;
    return PickedFindPhoto(
      temporaryPath: file.path,
      source: source,
      createdAt: DateTime.now(),
    );
  }
}
