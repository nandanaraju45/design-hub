import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/helpers/validators.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/screens/admin_home/admin_home_screen.dart';
import 'package:design_hub/screens/customer_home_screen.dart';
import 'package:design_hub/screens/designer_home.dart';
import 'package:design_hub/screens/quiz_screen.dart';
import 'package:design_hub/widgets/customer_or_designer_popup.dart';
import 'package:design_hub/widgets/form_text_field.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final validators = Validators();
  final authentication = Authentication();
  final userService = UserService();
  final designerService = DesignerService();

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    final uid = await authentication.signIn(
        emailController.text, passwordController.text);

    if (uid.length < 28) {
      mySnackBar(context, uid);
      setState(() {
        isLoading = false;
      });
      return;
    }

    final user = await userService.getUserById(uid);

    if (user == null) {
      mySnackBar(context, 'An error occured');
      await authentication.signOut();
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (user.userType == UserType.designer) {
      final designerDetailes = await designerService.getDesignerDetails(uid);
      if (designerDetailes!.isApproved) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => DesignerHome(
                    designerDetails: designerDetailes,
                    user: user,
                  )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              designerDetailes: designerDetailes,
              user: user,
            ),
          ),
        );
      }
    } else if (user.userType == UserType.customer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerHomeScreen(
            user: user,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomeScreen(),
        ),
      );
    }
  }

  void resetPassword() async {
    final email = emailController.text.trim();
    if (email.isNotEmpty) {
      try {
        await authentication.sendPasswordResetEmail(email);
        mySnackBar(context, 'Password reset email sent to $email');
      } catch (e) {
        mySnackBar(context, 'Error : ${e.toString()}');
      }
    } else {
      mySnackBar(context, 'Please fill email field');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 32.0),

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

                // Password
                FormTextField(
                  controller: passwordController,
                  label: 'Password',
                  textInputType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  isPassword: true, // <-- HERE!
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
                const SizedBox(height: 12.0),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => resetPassword(),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        loginUser();
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
                        : Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        CustomerOrDesignerPopup.showPopup(context);
                      },
                      child: const Text(
                        'Sign up',
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
    );
  }
}
