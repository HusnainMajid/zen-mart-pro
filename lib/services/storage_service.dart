import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<String> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Firebase Storage Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Deletes a file from Firebase Storage using its URL.
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw 'Firebase Storage Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'Failed to delete file: $e';
    }
  }
}
