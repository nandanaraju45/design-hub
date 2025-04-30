import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<File?> pickImageFromGallery() async {
  try {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected.');
      return null;
    }
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}
}
