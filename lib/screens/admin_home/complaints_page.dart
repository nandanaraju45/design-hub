import 'package:design_hub/firebase/firestore/complaint_service.dart';
import 'package:design_hub/firebase/firestore/user_service.dart';
import 'package:design_hub/models/complaint_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  final complaintService = ComplaintService();
  final userService = UserService();
  bool isLoading = false;

  List<ComplaintModel> _complaints = [];

  Future<void> _loadComplaints() async {
    setState(() {
      isLoading = true;
    });
    _complaints = await complaintService.getAllComplaints();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : _buildComplaintsList(),
    );
  }

  Widget _buildComplaintsList() {
    return ListView.builder(
      itemCount: _complaints.length,
      itemBuilder: (context, index) {
        final complaint = _complaints[index];
        return _buildComplaintTile(complaint);
      },
    );
  }

  Widget _buildComplaintTile(ComplaintModel complaint) {
    String formattedDate =
        DateFormat('MMM dd, yyyy – hh:mm a').format(complaint.timestamp);

    return FutureBuilder(
      future: userService.getUserById(complaint.userId),
      builder: (context, snapshot) {
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.connectionState != ConnectionState.waiting
                            ? snapshot.data!.profileImageUrl
                            : '',
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        snapshot.connectionState == ConnectionState.waiting
                            ? Text('Loading...')
                            : Text(snapshot.data!.name),
                        snapshot.connectionState == ConnectionState.waiting
                            ? Text('Loading...')
                            : Text(
                                snapshot.data!.email,
                                style: TextStyle(fontSize: 12),
                              )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    complaint.complaintText,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
