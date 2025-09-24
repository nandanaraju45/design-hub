import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/screens/admin_home/complaints_page.dart';
import 'package:design_hub/screens/admin_home/designs_page.dart';
import 'package:design_hub/screens/admin_home/requests_page.dart';
import 'package:design_hub/screens/login_screen.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  final UserModel user;
  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static int selectedIndex = 1;

  List<Widget> pages = [];

  final authService = Authentication();

  void logOut() async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pages = [
      RequestsPage(),
      DesignsPage(user: widget.user),
      ComplaintsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          actions: [
            IconButton(
              onPressed: logOut,
              icon: Icon(Icons.logout_rounded),
            ),
          ],
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text(
            selectedIndex == 0
                ? 'Designer Requests'
                : selectedIndex == 1
                    ? 'Design Hub'
                    : 'Complaints',
            style: TextStyle(
                fontWeight: selectedIndex == 1 ? FontWeight.bold : null),
          )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) => setState(() {
          selectedIndex = value;
        }),
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_rounded),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush_outlined),
            label: 'Designs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_rounded),
            label: 'Complaints',
          )
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
