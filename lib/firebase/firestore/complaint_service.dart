import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/complaint_model.dart';

class ComplaintService {
  final CollectionReference _complaintsRef =
      FirebaseFirestore.instance.collection('complaints');

  // Post a new complaint
  Future<void> postComplaint(ComplaintModel complaint) async {
    try {
      await _complaintsRef.add({
        'userId': complaint.userId,
        'complaintText': complaint.complaintText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to post complaint: $e');
    }
  }

  // Get all complaints
  Future<List<ComplaintModel>> getAllComplaints() async {
    try {
      QuerySnapshot snapshot =
          await _complaintsRef.orderBy('timestamp', descending: true).get();

      return snapshot.docs.map((doc) {
        return ComplaintModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }
}
