import 'package:flutter/material.dart';

class TypingPracticeSettingsScreen extends StatefulWidget {
  const TypingPracticeSettingsScreen({super.key});

  @override
  State<TypingPracticeSettingsScreen> createState() =>
      _TypingPracticeSettingsScreenState();
}

class _TypingPracticeSettingsScreenState
    extends State<TypingPracticeSettingsScreen> {
  int numberOfQuestions = 10;
  bool englishToVietnamese = true;
  bool autoPronounce = false;
  bool shuffleQuestions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Typing Practice Settings'),
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TypingPracticeSettingsScreen(
                //       numberOfQuestions: numberOfQuestions,
                //       englishToVietnamese: englishToVietnamese,
                //       autoPronounce: autoPronounce,
                //       shuffleQuestions: shuffleQuestions,
                //     ),
                //   ),
                // );
              },
              child: Text('Start Typing Practice'),
            ),
          ],
        ),
      ),
    );
  }
}
