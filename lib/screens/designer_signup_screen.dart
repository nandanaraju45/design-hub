import 'dart:io';
import 'package:design_hub/cloudinary/cloudinary_service.dart';
import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/helpers/image_picker.dart';
import 'package:design_hub/helpers/validators.dart';
import 'package:design_hub/models/design_model.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/screens/quiz_screen.dart';
import 'package:design_hub/widgets/form_text_field.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class DesignerSignupScreen extends StatefulWidget {
  const DesignerSignupScreen({super.key});

  @override
  State<DesignerSignupScreen> createState() => _DesignerSignupScreenState();
}

class _DesignerSignupScreenState extends State<DesignerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final validators = Validators();
  final cloudinaryService = CloudinaryService();
  final authentication = Authentication();
  final userService = UserService();
  final imagepicker = ImagePickerService();
  final designerService = DesignerService();

  DesignCategory? _selectedCategory; // 🔹 New dropdown value holder
  File? selectedImage;
  bool isLoading = false;

  void signupDesigner() async {
    print('Sign up performed');
    if (_selectedCategory == null) {
      mySnackBar(context, 'Please select a category');
      return;
    }

    if (selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      final url = await cloudinaryService.uploadImageToCloudinary(
          imageFile: selectedImage!, folderName: 'profileImages');

      print(url);

      if (url == null) {
        print('url is null');
        setState(() => isLoading = false);
        mySnackBar(context, 'Image upload failed');
        return;
      }

      final name = nameController.text;
      final email = emailController.text;
      final phone = phoneController.text;
      final password = passwordController.text;
      final qualification = qualificationController.text;

      final uid = await authentication.signUp(email, password);
      print(uid);

      final user = UserModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          userType: UserType.designer,
          profileImageUrl: url);

      final designerDetails = DesignerDetailesModel(
          uid: uid,
          qualification: qualification,
          category: _selectedCategory!,
          quizPassedAt: null,
          isApproved: false,
          isQuizPassed: false,
          isDeclined: false);

      await userService.saveUser(user);
      await designerService.saveDesignerDetails(designerDetails);

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                QuizScreen(designerDetailes: designerDetails, user: user)),
        (route) => false,
      );
    } else {
      mySnackBar(context, 'Please choose an image');
    }
  }

  void pickImage() async {
    final image = await imagepicker.pickImages(useGallery: true);
    if (image != null) {
      setState(() {
        selectedImage = image[0];
      });
    }
  }

  String _categoryToLabel(DesignCategory category) {
    switch (category) {
      case DesignCategory.jwellery:
        return 'Jewellery';
      case DesignCategory.furnitureDesign:
        return 'Furniture';
      case DesignCategory.interiorDesign:
        return 'Interior Design';
      case DesignCategory.dressDesign:
        return 'Dress Design';
      case DesignCategory.homeDecor:
        return 'Home Decor';
      case DesignCategory.pottery:
        return 'Pottery';
      case DesignCategory.handCraft:
        return 'Hand Craft';
      case DesignCategory.mehendi:
        return 'Mehendi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Join as Designer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 50,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : null,
                        child: selectedImage == null ? Icon(Icons.add) : null),
                  ),
                  SizedBox(
                    height: 16,
                  ),

                  // Full Name
                  FormTextField(
                    textInputType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    controller: nameController,
                    label: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Email
                  FormTextField(
                    controller: emailController,
                    label: 'Email',
                    textInputType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!validators.isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Phone Number
                  FormTextField(
                    textCapitalization: TextCapitalization.none,
                    controller: phoneController,
                    label: 'Phone Number',
                    textInputType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (validators.isValidPhoneNumber(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Qualification
                  FormTextField(
                    textCapitalization: TextCapitalization.words,
                    textInputType: TextInputType.name,
                    controller: qualificationController,
                    label: 'Qualification',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your qualification';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // 🔽 Design Category Dropdown
                  DropdownButtonFormField<DesignCategory>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                        labelText: 'Design Category',
                        floatingLabelStyle: TextStyle(color: Colors.blue),
                        labelStyle:
                            TextStyle(fontSize: 14, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(10))),
                    items: DesignCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_categoryToLabel(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // Password
                  FormTextField(
                    controller: passwordController,
                    label: 'Password',
                    textInputType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.none,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!validators.isStrongPassword(value)) {
                        return 'Password must be strong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Confirm Password
                  FormTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    textInputType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.none,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signupDesigner();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Sign Up', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Already have an account?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to login
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
