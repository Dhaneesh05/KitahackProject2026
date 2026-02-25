import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  /// Uploads a photo to Firebase Cloud Storage and returns the public Download URL
  Future<String> uploadDrainPhoto(XFile imageFile, String userId) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String ext = imageFile.name.split('.').last.toLowerCase();
      final String safeExt = (ext == 'jpg' || ext == 'png' || ext == 'jpeg') ? ext : 'jpg';
      
      final String path = 'reports/$userId/$timestamp.$safeExt';
      final Reference ref = _storage.ref().child(path);

      if (kIsWeb) {
        // Web requires reading bytes first
        final Uint8List bytes = await imageFile.readAsBytes();
        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/$safeExt',
        );
        final UploadTask uploadTask = ref.putData(bytes, metadata);
        // Add a 10s timeout to prevent infinite hangs on Web if CORS is misconfigured
        final TaskSnapshot snapshot = await uploadTask.timeout(const Duration(seconds: 10));
        return await snapshot.ref.getDownloadURL();
      } else {
        // Mobile can upload File directly
        final File file = File(imageFile.path);
        final UploadTask uploadTask = ref.putFile(file);
        final TaskSnapshot snapshot = await uploadTask.timeout(const Duration(seconds: 15));
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Storage Error: $e');
      if (kIsWeb) {
        // If it hangs or fails on Web (typically due to strict Storage CORS),
        // fallback to base64 encoding the image directly into Firestore.
        // The image is already compressed via ImagePicker.
        try {
          final Uint8List fallbackBytes = await imageFile.readAsBytes();
          final String base64String = base64Encode(fallbackBytes);
          return 'data:image/jpeg;base64,$base64String';
        } catch (innerErr) {
          debugPrint('Base64 Fallback Error: $innerErr');
          return '';
        }
      }
      rethrow;
    }
  }
}
