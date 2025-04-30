import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/quiz_service.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/quiz_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:design_hub/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class QuizScreen extends StatefulWidget {
  final DesignerDetailesModel designerDetailes;
  final UserModel user;
  const QuizScreen(
      {super.key, required this.designerDetailes, required this.user});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final quizService = QuizService();
  final designerService = DesignerService();

  List<QuizModel> _questions = [];
  Map<int, String> _selectedAnswers = {};
  bool _isLoading = true;
  bool _quizCompleted = false;
  bool _passed = false;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _selectedAnswers.clear();
      _quizCompleted = false;
    });

    final questions = await quizService
        .fetchRandomQuizByCategory(widget.designerDetailes.category.name);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _submitQuiz() async {
    if (_selectedAnswers.length < _questions.length) {
      mySnackBar(context, 'Please answer all questions');
      return;
    }

    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].answer) {
        correct++;
      }
    }

    bool passed = correct >= 15;

    setState(() {
      _quizCompleted = true;
      _passed = passed;
      _correct = correct;

      if (_passed) {
        widget.designerDetailes.isQuizPassed = true; // ✅ update local value
      }
    });

    if (_passed) {
      DesignerDetailesModel updatedDesignDetail = widget.designerDetailes;
      updatedDesignDetail.isQuizPassed = true;
      await designerService.saveDesignerDetails(updatedDesignDetail);
    }
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    final selected = _selectedAnswers[index];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeletonizer(
              enabled: _isLoading,
              child: Text(
                '${index + 1}. ${question.question}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ...question.options.map((option) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        selected == option ? Colors.blue : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selected,
                  onChanged: _quizCompleted
                      ? null
                      : (value) {
                          setState(() {
                            _selectedAnswers[index] = value!;
                          });
                        },
                  activeColor: Colors.blue,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton() {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: ElevatedButton(
      key: ValueKey(_quizCompleted && _passed),
      onPressed: (_isLoading || (_quizCompleted && _passed))
          ? null
          : _quizCompleted
              ? _loadQuestions
              : _submitQuiz,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _quizCompleted && _passed
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "✔ Passed",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            )
          : Text(
              _quizCompleted ? "Retry" : "Submit",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
    ),
  );
}

  Widget _buildQuizSummary() {
    if (!_quizCompleted) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _passed
            ? "You passed! 🎉 ($_correct/20 correct)"
            : "You got $_correct/20 correct. Try again!",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _passed ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              width: double.infinity,
              height: 140,
              color: Colors.blue,
              padding: const EdgeInsets.only(top: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    'Quiz Section',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (widget.designerDetailes.isQuizPassed &&
                    !widget.designerDetailes.isApproved) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.hourglass_bottom,
                            color: Colors.orange, size: 80),
                        SizedBox(height: 20),
                        Text(
                          "You have passed the quiz,\nwaiting for the approval of admin.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return Skeletonizer(
                  enabled: _isLoading,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _questions.isEmpty
                        ? const Center(child: Text("No questions found."))
                        : Column(
                            children: [
                              const Text(
                                "Complete the quiz to proceed",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _questions.length,
                                  itemBuilder: (context, index) =>
                                      _buildQuestionCard(index),
                                ),
                              ),
                              _buildQuizSummary(),
                              const SizedBox(height: 10),
                              _buildFooterButton(),
                              const SizedBox(height: 20),
                            ],
                          ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// Custom clipper for curved AppBar
class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 2, size.height + 30, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
