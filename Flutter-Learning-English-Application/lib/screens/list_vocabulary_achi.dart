import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/widgets/achievement.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:application_learning_english/widgets/word_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import '../utils/session_user.dart';

import '../user.dart';

class ListVocabularyScreen extends StatefulWidget {
  final List<Word> words;
  final Topic topic;
  final bool isEnableEdit;

  const ListVocabularyScreen({
    super.key,
    required this.words,
    required this.topic,
    required this.isEnableEdit,
  });

  @override
  State<ListVocabularyScreen> createState() => _ListVocabularyScreenState();
}

class _ListVocabularyScreenState extends State<ListVocabularyScreen> {
  final urlRoot = kIsWeb ? webURL : androidURL;
  bool isUpdateAmount = false;

  late SharedPreferences prefs;
  User? user;

  @override
  void initState() {
    super.initState();
    loadUser();
    // futureAchievement = fetchAchievement();
  }

  loadUser() async {
    user = await getUserData();
    setState(() {});
  }

  void deleteWord(String wordId) {
    setState(() {
      widget.words.removeWhere((word) => word.id == wordId);
      isUpdateAmount = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove word successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addVocabularyDialog() {
    var key = GlobalKey<FormState>();
    var englishController = TextEditingController();
    var vietnameseController = TextEditingController();
    var descriptionController = TextEditingController();
    String english = '';
    String vietnamese = '';
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Vocabulary"),
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
                    border: OutlineInputBorder(),
                  ),
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
                    labelText: 'Description (Can be empty)',
                    border: OutlineInputBorder(),
                  ),
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

                  var listWord = [
                    {
                      'english': english,
                      'vietnamese': vietnamese,
                      'description': description,
                    }
                  ];

                  addWords(listWord);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void updateWord(Word word) {
    setState(() {
      int index = widget.words.indexWhere((w) => w.id == word.id);
      if (index != -1) {
        widget.words[index] = word;
      }
    });
  }

  Future<void> addTopicToUser() async {
    try {
      var response = await http.post(
          Uri.parse(
              '$urlRoot/topics/${widget.topic.id}/borrow-topic/${user!.username}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add topic to user'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add topic to user');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> addWords(listWord) async {
    try {
      var response = await http.post(
          Uri.parse('$urlRoot/topics/${widget.topic.id}/add-words/thanhtuan'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'listWord': listWord,
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            var newWords = data['newWords'];
            for (var newWord in newWords) {
              widget.words.add(Word.fromJson(newWord));
            }
            isUpdateAmount = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add word'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add word');
      }
    } catch (err) {
      print(err);
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure you want to add this topic?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng Dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng Dialog
                addTopicToUser(); // Gọi hàm addTopicToUser()
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, isUpdateAmount);
          },
        ),
        title: Center(child: Text('Vocabulary List')),
        actions: [
          if (widget.isEnableEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () {
                    _addVocabularyDialog();
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Color.fromARGB(255, 33, 44, 204),
                  ),
                ),
              ),
            ),
          if (!widget.isEnableEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  icon: Icon(
                    Icons.my_library_add,
                    size: 30,
                    color: Color.fromARGB(255, 33, 44, 204),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey[100],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: widget.words.length,
            itemBuilder: (context, index) {
              return WordItem(
                  word: widget.words[index],
                  onDelete: deleteWord,
                  onUpdate: updateWord,
                  isEnableEdit: widget.isEnableEdit);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeaderBoards(topicId: widget.topic.id)),
          );
        },
        child: Icon(Icons.emoji_events),
      ),
    );
  }
}
