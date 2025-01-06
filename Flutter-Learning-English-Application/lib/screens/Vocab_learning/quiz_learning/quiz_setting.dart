import 'package:application_learning_english/screens/Vocab_learning/quiz_learning/quiz_screen.dart';
import 'package:flutter/material.dart';

class QuizSettingsScreen extends StatefulWidget {
  const QuizSettingsScreen({super.key});

  @override
  State<QuizSettingsScreen> createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  int numberOfQuestions = 10;
  bool englishToVietnamese = true;
  bool autoPronounce = false;
  bool shuffleQuestions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Number of Questions'),
                DropdownButton<int>(
                  value: numberOfQuestions,
                  onChanged: (int? newValue) {
                    setState(() {
                      numberOfQuestions = newValue!;
                    });
                  },
                  items: <int>[5, 10, 15, 20]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            SwitchListTile(
              title: Text('English to Vietnamese'),
              value: englishToVietnamese,
              onChanged: (bool value) {
                setState(() {
                  englishToVietnamese = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Auto Pronounce English'),
              value: autoPronounce,
              onChanged: (bool value) {
                setState(() {
                  autoPronounce = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Shuffle Questions'),
              value: shuffleQuestions,
              onChanged: (bool value) {
                setState(() {
                  shuffleQuestions = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      numberOfQuestions: numberOfQuestions,
                      englishToVietnamese: englishToVietnamese,
                      autoPronounce: autoPronounce,
                      shuffleQuestions: shuffleQuestions,
                    ),
                  ),
                );
              },
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
