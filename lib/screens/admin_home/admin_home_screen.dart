import 'package:design_hub/screens/admin_home/complaints_page.dart';
import 'package:design_hub/screens/admin_home/designs_page.dart';
import 'package:design_hub/screens/admin_home/requests_page.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  final pages = [
    RequestsPage(),
    DesignsPage(),
    ComplaintsPage()
  ];

  static int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          selectedIndex == 0
          ? 'Designer Requests'
          : selectedIndex == 1
          ? 'Design Hub'
          : 'Complaints',
          style: TextStyle(
            fontWeight: selectedIndex == 1
            ? FontWeight.bold
            :null
          ),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) => setState(() {
          selectedIndex = value;
        }),
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_add_alt_1_rounded
            ),
            label: 'Requests'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.brush_outlined
            ),
            label: 'Designs'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.report_problem_rounded,
            ),
            label: 'Complaints'
          )
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}