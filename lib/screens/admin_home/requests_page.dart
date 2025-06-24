import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final userService = UserService();
  final designerService = DesignerService();

  void acceptRequest(DesignerDetailesModel designerDetails) async {
    designerDetails.isApproved = true;
    await designerService.saveDesignerDetails(designerDetails);
  }

  void declineRequest(DesignerDetailesModel designerDetails) async {
    designerDetails.isDeclined = true;
    await designerService.saveDesignerDetails(designerDetails);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DesignerDetailesModel>>(
      stream: designerService.getPendingApprovedDesigners(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => ListTile(
                leading: CircleAvatar(),
                title: Text('Loading...'),
                subtitle: Text('Loading...'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(onPressed: null, child: Text('Accept')),
                    IconButton(onPressed: null, icon: Icon(Icons.close)),
                  ],
                ),
              ),
            ),
          );
        }

        final designers = snapshot.data!;

        if (designers.isEmpty) {
          return const Center(child: Text('No pending requests.'));
        }

        return ListView.builder(
          itemCount: designers.length,
          itemBuilder: (context, index) {
            final designer = designers[index];
            return FutureBuilder<UserModel?>(
              future: userService.getUserById(designer.uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Skeletonizer(
                    enabled: true,
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text('Loading...'),
                      subtitle: Text('Loading...'),
                    ),
                  );
                }

                final user = userSnapshot.data!;
                final quizTime = designer.quizPassedAt != null
                    ? timeago.format(designer.quizPassedAt!.toDate())
                    : 'N/A';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                  title: Text(user.name),
                  subtitle: Text('${user.email}\nQuiz Passed: $quizTime'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => acceptRequest(designer),
                        child: const Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () => declineRequest(designer),
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
