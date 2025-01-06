import 'package:application_learning_english/screens/Vocab_learning/card_learning/flash_card/flash_card.dart';
import 'package:flutter/material.dart';
import 'package:application_learning_english/models/word.dart';

class CardSettingsScreen extends StatefulWidget {
  final List<Word> words;

  const CardSettingsScreen({super.key, required this.words});
  @override
  State<CardSettingsScreen> createState() => _CardSettingsScreenState();
}

class _CardSettingsScreenState extends State<CardSettingsScreen> {
  bool englishToVietnamese = true;
  bool autoPronounce = false;
  bool shuffleQuestions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                title: Text('Automatic pronunciation'),
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
                      builder: (context) => FlashCard(
                        words: widget.words,
                        isShuffle: shuffleQuestions,
                        isEnglish: englishToVietnamese,
                        autoPronounce: autoPronounce,
                      ),
                    ),
                  );
                },
                child: Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
