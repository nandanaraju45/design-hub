class QuizModel {
  final String question;
  final List<String> options;
  final String answer;
  final String category;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
    required this.category,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'category': category,
    };
  }
}
