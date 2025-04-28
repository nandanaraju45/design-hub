import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _usersCollection = 'users';

  // Store user to Firestore
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id) // Use user id as document id
        .set(user.toMap());
  }

  // Get user by id from Firestore
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    } else {
      return null;
    }
  }
}
