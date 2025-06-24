import 'dart:io';
import 'package:design_hub/helpers/image_picker.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class PostDesignScreen extends StatefulWidget {
  const PostDesignScreen({super.key});

  @override
  State<PostDesignScreen> createState() => _PostDesignScreenState();
}

class _PostDesignScreenState extends State<PostDesignScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();

  List<File> _selectedImages = [];

  void _selectImages(bool fromGallery) async {
    final images = await _imagePickerService.pickImages(
      useGallery: fromGallery,
      allowMultiple: fromGallery,
    );
    if (images != null) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  void _postDesign() {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();

    if (title.isEmpty || _selectedImages.isEmpty) {
      mySnackBar(context, 'Please choose an image and add a title');
      return;
    }

    // TODO: Implement upload logic here

    mySnackBar(context, 'Design posted successfully');

    _titleController.clear();
    _captionController.clear();
    setState(() => _selectedImages.clear());
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
                labelText: 'Caption (optional)',
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
                icon: const Icon(Icons.upload_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text("Post Design", style: TextStyle(fontSize: 16)),
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
