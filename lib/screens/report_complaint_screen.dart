import 'package:design_hub/firebase/firestore/complaint_service.dart';
import 'package:design_hub/models/complaint_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:flutter/material.dart';

class ReportComplaintScreen extends StatefulWidget {
  final UserModel user;
  const ReportComplaintScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ReportComplaintScreen> createState() => _ReportComplaintScreenState();
}

class _ReportComplaintScreenState extends State<ReportComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();
  bool isLoading = false;

  final complaintService = ComplaintService();

  void _submitComplaint() async {
    if (_complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your complaint')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final complaint = ComplaintModel(
        id: '',
        userId: widget.user.id,
        complaintText: _complaintController.text.trim(),
        timestamp: DateTime.now());

    await complaintService.postComplaint(complaint);

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully!')),
    );

    _complaintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an issue'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _complaintController,
              maxLines: 8,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Enter your issue here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
