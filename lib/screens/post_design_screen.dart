import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/cloudinary/cloudinary_service.dart';
import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/helpers/image_picker.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PostDesignScreen extends StatefulWidget {
  final UserModel user;
  final DesignerDetailesModel designerDetails;
  const PostDesignScreen({
    super.key,
    required this.user,
    required this.designerDetails,
  });

  @override
  State<PostDesignScreen> createState() => _PostDesignScreenState();
}

class _PostDesignScreenState extends State<PostDesignScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();

  List<File> _selectedImages = [];
  bool isLoading = false;

  void _selectImages(bool fromGallery) async {
    final images = await _imagePickerService.pickImages(
      useGallery: fromGallery,
      allowMultiple: fromGallery,
    );
    if (images != null) {
      final appDir = await getApplicationDocumentsDirectory();

      // Persist files
      final List<File> persistentFiles = [];

      for (final file in images) {
        final fileName = path.basename(file.path);
        final newPath = path.join(appDir.path, fileName);
        final newFile = await file.copy(newPath);
        persistentFiles.add(newFile);
      }

      setState(() {
        _selectedImages = persistentFiles;
      });
    }
  }

  void _postDesign() async {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();

    if (title.isEmpty || _selectedImages.isEmpty || caption.isEmpty) {
      mySnackBar(context, 'Please add title, caption, and at least one image.');
      return;
    }

    final cloudinaryService = CloudinaryService();
    final List<String> images = [];

    setState(() {
      isLoading = true;
    });
    try {
      for (final image in _selectedImages) {
        final url = await cloudinaryService.uploadImageToCloudinary(
          imageFile: image,
          folderName: 'posts',
        );
        if (url == null) throw Exception('Image upload failed');
        images.add(url);
      }

      final design = DesignModel(
        name: title,
        caption: caption,
        images: images,
        designerId: widget.user.id,
        postedAt: Timestamp.now(),
        likedBy: [],
        reviewsCount: 0,
        category: widget.designerDetails.category,
        isDeleted: false,
      );

      final designService = DesignService();
      await designService.addDesign(design);

      mySnackBar(context, 'Design posted successfully');
      _titleController.clear();
      _captionController.clear();
      setState(() => _selectedImages.clear());
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      mySnackBar(context, 'Error: ${e.toString()}');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Images",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _selectedImages[index],
                              width: 140,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                floatingLabelStyle: TextStyle(color: themeColor),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                    borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.title),
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                floatingLabelStyle: TextStyle(color: themeColor),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                    borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.description),
                labelText: 'Caption',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _postDesign,
                icon: !isLoading ? Icon(Icons.upload_rounded) : null,
                label: isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Post Design',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            foregroundColor: Colors.white,
            heroTag: 'gallery',
            onPressed: () => _selectImages(true),
            label: const Text("Gallery"),
            icon: const Icon(Icons.photo_library),
            backgroundColor: themeColor,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            foregroundColor: Colors.white,
            heroTag: 'camera',
            onPressed: () => _selectImages(false),
            label: const Text("Camera"),
            icon: const Icon(Icons.camera_alt),
            backgroundColor: themeColor,
          ),
        ],
      ),
    );
  }
}
