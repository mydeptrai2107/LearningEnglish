import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final int numberOfQuestions;
  final bool englishToVietnamese;
  final bool autoPronounce;
  final bool shuffleQuestions;

  const QuizScreen({
    super.key,
    required this.numberOfQuestions,
    required this.englishToVietnamese,
    required this.autoPronounce,
    required this.shuffleQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: Center(
        child: Text('Quiz Feature with $numberOfQuestions questions'),
      ),
    );
  }
}
