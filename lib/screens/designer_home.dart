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
      body: ListView(
        children: [
          _designerHomeHeader()
        ],
      )
    );
  }

  Widget _designerHomeHeader(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60,horizontal: 16,),
      child: Row(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.user.profileImageUrl)
          ),
          SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.name,style: TextStyle(fontSize: 22),),
              Text(widget.user.email)
            ],
          )
        ],
      ),
    );
  }
}