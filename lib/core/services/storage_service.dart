import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  StorageService(this._storage);

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Compress image before upload
  Future<File> compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return imageFile;

    // Resize if too large
    img.Image resized = image;
    if (image.width > 1024 || image.height > 1024) {
      resized = img.copyResize(image, width: 1024, height: 1024);
    }

    // Encode as JPEG with quality
    final compressedBytes = img.encodeJpg(resized, quality: 85);

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final compressedFile = File('${tempDir.path}/${const Uuid().v4()}.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  /// Upload receipt to Firebase Storage
  Future<String?> uploadReceipt(File imageFile, String userId) async {
    try {
      // Compress first
      final compressedFile = await compressImage(imageFile);

      // Generate unique filename
      final fileName = '${const Uuid().v4()}.jpg';
      final ref = _storage.ref('users/$userId/receipts/$fileName');

      // Upload with timeout
      final uploadTask = ref.putFile(compressedFile);
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          'Upload timed out. Please check your internet connection.',
        ),
      );

      // Get download URL with timeout
      return await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
          'Failed to get download URL. Please check your internet connection.',
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Save receipt locally for offline access
  Future<String?> saveLocally(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = '${const Uuid().v4()}.jpg';
      final localFile = File('${receiptsDir.path}/$fileName');

      await imageFile.copy(localFile.path);
      return localFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Delete receipt from Firebase Storage
  Future<void> deleteFromStorage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if delete fails
    }
  }

  /// Delete receipt from local storage
  Future<void> deleteFromLocal(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore if delete fails
    }
  }

  /// Delete from both storages
  Future<void> deleteReceipt(String? url, String? localPath) async {
    if (url != null) await deleteFromStorage(url);
    if (localPath != null) await deleteFromLocal(localPath);
  }

  /// Get local file if exists
  Future<File?> getLocalFile(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) return file;
    return null;
  }
}

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});
