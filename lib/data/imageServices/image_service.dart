import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
}
