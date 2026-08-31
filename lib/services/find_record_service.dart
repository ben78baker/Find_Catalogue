import '../data/find_repository.dart';
import '../domain/find_record.dart';
import 'media_store.dart';
import 'photo_capture_service.dart';

class PhotoDraft {
  PhotoDraft({
    this.id,
    required this.path,
    required this.role,
    required this.source,
    required this.createdAt,
    required this.isOriginalEvidence,
    required this.sortOrder,
    this.needsPreserving = true,
  });

  factory PhotoDraft.fromStored(FindPhoto photo) => PhotoDraft(
    id: photo.id,
    path: photo.path,
    role: photo.role,
    source: photo.source,
    createdAt: photo.createdAt,
    isOriginalEvidence: photo.isOriginalEvidence,
    sortOrder: photo.sortOrder,
    needsPreserving: false,
  );

  factory PhotoDraft.fromPicked(
    PickedFindPhoto photo, {
    required FindPhotoRole role,
    required bool isOriginalEvidence,
    required int sortOrder,
  }) => PhotoDraft(
    path: photo.temporaryPath,
    role: role,
    source: photo.source,
    createdAt: photo.createdAt,
    isOriginalEvidence: isOriginalEvidence,
    sortOrder: sortOrder,
  );

  final int? id;
  final String path;
  FindPhotoRole role;
  final FindPhotoSource source;
  final DateTime createdAt;
  final bool isOriginalEvidence;
  final int sortOrder;
  final bool needsPreserving;
}

class FindRecordService {
  FindRecordService({required this.repository, required this.mediaStore});

  final FindRepository repository;
  final MediaStore mediaStore;

  Future<FindRecord> create(
    FindDraft draft,
    List<PhotoDraft> photoDrafts,
  ) async {
    final photos = await _preserveNewPhotos(photoDrafts);
    return repository.create(draft, photos);
  }

  Future<void> update(
    int id,
    FindDraft draft,
    List<PhotoDraft> photoDrafts,
  ) async {
    await repository.update(id, draft);

    for (final photo in photoDrafts.where((photo) => photo.id != null)) {
      await repository.updatePhotoRole(photo.id!, photo.role);
    }

    final newPhotos = await _preserveNewPhotos(
      photoDrafts.where((photo) => photo.id == null).toList(),
    );
    await repository.addPhotos(id, newPhotos);
  }

  Future<List<NewFindPhoto>> _preserveNewPhotos(List<PhotoDraft> drafts) async {
    final result = <NewFindPhoto>[];
    for (final draft in drafts) {
      final storedPath = draft.needsPreserving
          ? await mediaStore.preserveOriginal(draft.path)
          : draft.path;
      result.add(
        NewFindPhoto(
          path: storedPath,
          role: draft.role,
          source: draft.source,
          createdAt: draft.createdAt,
          isOriginalEvidence: draft.isOriginalEvidence,
          sortOrder: draft.sortOrder,
        ),
      );
    }
    return result;
  }
}
