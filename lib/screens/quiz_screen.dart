import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_hub/firebase/firestore/designer_service.dart';
import 'package:design_hub/firebase/firestore/quiz_service.dart';
import 'package:design_hub/models/designer_detailes_model.dart';
import 'package:design_hub/models/quiz_model.dart';
import 'package:design_hub/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:async';

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

  int _remainingSeconds = 180;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel(); // ⏰ cancel timer when screen disposed
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        if (!_quizCompleted) {
          _submitQuiz(); // ⏰ auto-submit when time ends
        }
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
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
    _startTimer();
  }

  void _submitQuiz() async {
    _timer?.cancel();

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
    });

    if (passed) {
      widget.designerDetailes.isQuizPassed = true;
      widget.designerDetailes.quizPassedAt = Timestamp.now();
      await designerService.saveDesignerDetails(widget.designerDetailes);
    } else {
      setState(() {
        widget.designerDetailes.failedAttempts += 1;
      });

      await designerService.saveDesignerDetails(widget.designerDetailes);
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
    final hasReachedLimit = widget.designerDetailes.failedAttempts >= 3;

    if (hasReachedLimit) {
      return const Text(
        "You have reached the maximum number of attempts (3).",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      );
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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
                    !widget.designerDetailes.isDeclined) {
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
                } else if (widget.designerDetailes.isQuizPassed &&
                    widget.designerDetailes.isDeclined) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.error, color: Colors.red, size: 80),
                        SizedBox(height: 20),
                        Text(
                          "Your request has been declined",
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
                              Text(
                                _formatTime(_remainingSeconds), // ⏰ show timer
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
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
