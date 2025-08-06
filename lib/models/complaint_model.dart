import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String userId;
  final String complaintText;
  final DateTime timestamp;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.complaintText,
    required this.timestamp,
  });

  // Convert Firestore document to model
  factory ComplaintModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ComplaintModel(
      id: documentId,
      userId: map['userId'] ?? '',
      complaintText: map['complaintText'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert model to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'complaintText': complaintText,
      'timestamp': timestamp,
    };
  }
}
