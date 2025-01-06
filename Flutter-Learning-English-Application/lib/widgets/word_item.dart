import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class WordItem extends StatefulWidget {
  Word word;
  final Function(String) onDelete;
  final Function(Word) onUpdate;
  final bool isEnableEdit;

  WordItem({
    super.key,
    required this.word,
    required this.onDelete,
    required this.onUpdate,
    required this.isEnableEdit,
  });

  @override
  State<WordItem> createState() => _WordItemState();
}

class _WordItemState extends State<WordItem> {
  final urlRoot = kIsWeb ? webURL : androidURL;
  final FlutterTts flutterTts = FlutterTts();
  Color cardColor = Colors.white;

  Future<void> toggleMarkWord() async {
    try {
      var response = await http.patch(
          Uri.parse('$urlRoot/topics/toggle-mark-word/${widget.word.id}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          widget.word = Word.fromJson(data['newWord']);
          widget.onUpdate(Word.fromJson(data['newWord']));
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> adjustWord(english, vietnamese, description) async {
    try {
      var response = await http.patch(
        Uri.parse('$urlRoot/topics/adjust-word/${widget.word.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'english': english,
          'vietnamese': vietnamese,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          widget.word = Word.fromJson(data['word']);
          widget.onUpdate(Word.fromJson(data['word']));
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> removeWord() async {
    try {
      var response = await http.delete(
        Uri.parse('$urlRoot/topics/remove-word/${widget.word.id}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          widget.onDelete(widget.word.id);
        }
      } else {
        throw Exception('Failed to remove word');
      }
    } catch (err) {
      print(err);
    }
  }

  void _adjustVocabularyDialog() {
    var key = GlobalKey<FormState>();
    var englishController = TextEditingController();
    var vietnameseController = TextEditingController();
    var descriptionController = TextEditingController();
    String english = '';
    String vietnamese = '';
    String description = '';

    englishController.text = widget.word.english;
    vietnameseController.text = widget.word.vietnamese;
    descriptionController.text = widget.word.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adjust Vocabulary"),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: englishController,
                  decoration: InputDecoration(
                      labelText: 'English meaning',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter English meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    english = value ?? '';
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: vietnameseController,
                  decoration: InputDecoration(
                      labelText: 'Vietname meaning',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vietname meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    vietnamese = value ?? '';
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  onSaved: (value) {
                    description = value ?? '';
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState?.validate() ?? false) {
                  key.currentState?.save();

                  adjustWord(english, vietnamese, description);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void confirmRemove() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this word?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeWord();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pronounceWord() async {
    String text = widget.word.english;
    try {
      await flutterTts.speak(text);
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          cardColor = Color.fromARGB(255, 211, 226, 227);
        });
      },
      onExit: (_) {
        setState(() {
          cardColor = Colors.white;
        });
      },
      child: InkWell(
        onTap: _pronounceWord,
        child: Card(
          color: cardColor,
          elevation: 4.0,
          margin: EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            title: Row(
              children: [
                Text(
                  widget.word.english,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 38, 166, 199),
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                if (widget.word.status == 'mastered')
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
              ],
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.word.vietnamese,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (widget.word.description.isNotEmpty)
                  Text(
                    '(${widget.word.description})',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
            trailing: SizedBox(
              width: 90,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isEnableEdit)
                    InkWell(
                      child: Icon(
                        size: 20,
                        Icons.edit,
                        color: Colors.blueGrey,
                      ),
                      onTap: () {
                        _adjustVocabularyDialog();
                      },
                    ),
                  SizedBox(
                    width: 10.0,
                  ),
                  InkWell(
                    child: Icon(
                      size: 20,
                      widget.word.isStarred ? Icons.star : Icons.star_border,
                      color: widget.word.isStarred
                          ? Colors.yellow[700]
                          : Colors.grey,
                    ),
                    onTap: () {
                      toggleMarkWord();
                    },
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  if (widget.isEnableEdit)
                    InkWell(
                      child: Icon(
                        size: 20,
                        Icons.delete,
                        color: Colors.black,
                      ),
                      onTap: () {
                        confirmRemove();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
