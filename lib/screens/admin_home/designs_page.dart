import 'package:flutter/material.dart';

class DesignsPage extends StatefulWidget {
  const DesignsPage({super.key});

  @override
  State<DesignsPage> createState() => _DesignsPageState();
}

class _DesignsPageState extends State<DesignsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Design page'),
      ),
    );
  }
}