import 'dart:io';
import 'package:design_hub/cloudinary/cloudinary_service.dart';
import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/helpers/image_picker.dart';
import 'package:design_hub/helpers/validators.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/screens/customer_home_screen.dart';
import 'package:design_hub/widgets/form_text_field.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final validators = Validators();
  final imagepicker = ImagePickerService();
  final cloudinaryService = CloudinaryService();
  final authentication = Authentication();
  final userService = UserService();

  File? selectedImage;
  bool isLoading = false;

  void signupCustomer() async {
    if (selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      final url = await cloudinaryService.uploadImageToCloudinary(
          imageFile: selectedImage!, folderName: 'profileImages');

      if (url == null) {
        setState(() => isLoading = false);
        mySnackBar(context, 'Image upload failed');
        return;
      }

      final name = nameController.text;
      final email = emailController.text;
      final phone = phoneController.text;
      final password = passwordController.text;

      final uid = await authentication.signUp(email, password);

      if (uid.length < 28) {
        mySnackBar(context, 'Error : $uid');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final user = UserModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          userType: UserType.customer,
          profileImageUrl: url);

      await userService.saveUser(user);

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CustomerHomeScreen(user: user)),
        (route) => false,
      );
    } else {
      mySnackBar(context, 'Please choose an image');
    }
  }

  void pickImage() async {
    final image = await imagepicker.pickImageFromGallery();
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
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
                    'Create Account',
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
                    controller: nameController,
                    label: 'Full Name',
                    textInputType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
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
                    controller: phoneController,
                    label: 'Phone Number',
                    textInputType: TextInputType.phone,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!validators.isValidPhoneNumber(value)) {
                        return 'Phone number must be 10 digits and numbers only';
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
                        isLoading
                            ? null
                            : [
                                if (_formKey.currentState?.validate() ?? false)
                                  {
                                    // Only call signupCustomer if the form is valid
                                    signupCustomer()
                                  }
                              ];
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
                          Navigator.pop(context);
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
