import 'package:application_learning_english/screens/Vocab_learning/card_learning/card_setting.dart';
import 'package:application_learning_english/screens/Vocab_learning/quiz_learning/quiz_setting.dart';
import 'package:application_learning_english/screens/Vocab_learning/typing_learning/typing_practice_screen.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  final List<Word> words;

  const MainMenu({super.key, required this.words});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late List<String> vietnameseWords;
  late List<String> englishWords;

  @override
  void initState() {
    super.initState();
    getDataWord();
  }

  void getDataWord() {
    vietnameseWords = widget.words.map((word) => word.vietnamese).toList();
    englishWords = widget.words.map((word) => word.english).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardSettingsScreen(
                      words: widget.words,
                    ),
                  ),
                );
              },
              child: Text('FlashCard learning'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizSettingsScreen(),
                  ),
                );
              },
              child: Text('Quiz Feature'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TypingPracticeSettingsScreen(),
                  ),
                );
              },
              child: Text('Typing Practice Feature'),
            ),
          ],
        ),
      ),
    );
  }
}
