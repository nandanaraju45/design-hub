import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<File>?> pickImages({
    required bool useGallery,
    bool allowMultiple = false,
  }) async {
    try {
      if (allowMultiple && useGallery) {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage();

        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          return pickedFiles.map((file) => File(file.path)).toList();
        } else {
          debugPrint('No images selected.');
          return null;
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: useGallery ? ImageSource.gallery : ImageSource.camera,
        );

        if (pickedFile != null) {
          return [File(pickedFile.path)];
        } else {
          debugPrint('No image selected.');
          return null;
        }
      }
    } catch (e) {
      debugPrint('Error picking image(s): $e');
      return null;
    }
  }
}
