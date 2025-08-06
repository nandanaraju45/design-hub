import 'package:design_hub/firebase/authentication/authentication.dart';
import 'package:design_hub/firebase/firestore/design_service.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/routes/routes.dart';
import 'package:design_hub/screens/chat_list_screen.dart';
import 'package:design_hub/screens/design_details_screen.dart';
import 'package:design_hub/screens/login_screen.dart';
import 'package:design_hub/screens/post_design_screen.dart';
import 'package:design_hub/screens/report_complaint_screen.dart';
import 'package:design_hub/widgets/design_card.dart';
import 'package:flutter/material.dart';

class DesignerHome extends StatefulWidget {
  final UserModel user;
  final DesignerDetailesModel designerDetails;
  const DesignerHome({
    super.key,
    required this.user,
    required this.designerDetails,
  });

  @override
  State<DesignerHome> createState() => _DesignerHomeState();
}

class _DesignerHomeState extends State<DesignerHome> {
  void logOut() async {
    final authService = Authentication();
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MyRoutes.createSlideFadeRoute(
              PostDesignScreen(
                user: widget.user,
                designerDetails: widget.designerDetails,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildDesignGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.user.profileImageUrl),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      widget.user.name,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () {
                          Navigator.push(
                            context,
                            MyRoutes.createSlideFadeRoute(
                              ReportComplaintScreen(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: Text('Report issue'),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: 180,
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  widget.user.email,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MyRoutes.createSlideFadeRoute(
                          ChatListScreen(
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                    label: Text('Messages'),
                    icon: Icon(Icons.message),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  //SizedBox(width: 30),
                  IconButton(onPressed: logOut, icon: Icon(Icons.logout))
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDesignGrid() {
    final designService = DesignService();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder(
          stream: designService.getDesignsByDesigner(widget.user.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Stream error: ${snapshot.error}');
              return const Center(child: Text('Something went wrong.'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No designs found.'));
            }

            final designs = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: designs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final design = designs[index];
                return DesignCard(
                  user: widget.user,
                  design: design,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MyRoutes.createSlideFadeRoute(
                        DesignDetailsScreen(
                          design: design,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
