import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/models/quiz_model.dart';

class QuizService {
  Future<List<QuizModel>> fetchRandomQuizByCategory(String category) async {
    try {
      // Fetch all quiz questions of the given category
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('design_quiz_questions')
          .where('category', isEqualTo: category)
          .get();

      List<QueryDocumentSnapshot> docs = snapshot.docs;

      // Shuffle the list randomly
      docs.shuffle(Random());

      // Take up to 20 questions
      final selectedDocs = docs.take(20).toList();

      // Map to QuizModel
      return selectedDocs
          .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching quiz questions: $e');
      return [];
    }
  }
}
