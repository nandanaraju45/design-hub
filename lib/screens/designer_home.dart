import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:flutter/material.dart';

class DesignerHome extends StatefulWidget {
  final UserModel user;
  final DesignerDetailesModel designerDetailes;
  const DesignerHome({super.key, required this.user, required this.designerDetailes});

  @override
  State<DesignerHome> createState() => _DesignerHomeState();
}

class _DesignerHomeState extends State<DesignerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Designer Home'),
      ),
    );
  }
}