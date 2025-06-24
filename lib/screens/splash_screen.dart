import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/screens/admin_home/admin_home_screen.dart';
import 'package:design_hub/screens/customer_home_screen.dart';
import 'package:design_hub/screens/designer_home.dart';
import 'package:design_hub/screens/login_screen.dart';
import 'package:design_hub/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final authentication = Authentication();
  final userService = UserService();
  final designerService = DesignerService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _controller.forward();
    checkLoginStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));

    final isLoggedIn = authentication.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    final uid = authentication.getCurrentUserUid();
    if (uid == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
      return;
    }

    final user = await userService.getUserById(uid);
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 49, 63),
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
      ),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Design Hub',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    // letterSpacing: 2,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
