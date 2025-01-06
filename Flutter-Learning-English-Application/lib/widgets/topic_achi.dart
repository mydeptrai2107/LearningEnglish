import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:application_learning_english/screens/list_vocabulary_achi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import '../utils/session_user.dart';
import '../user.dart';

class TopicItem extends StatefulWidget {
  Topic topic;

  TopicItem({
    super.key,
    required this.topic,
  });

  @override
  State<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  final urlRoot = kIsWeb ? webURL : androidURL;
  List<Word> words = [];
  List<Word> masteredWords = [];
  bool isEnableEdit = false;
  late SharedPreferences prefs;
  User? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    user = await getUserData();
    if (user != null) {
      fetchVocabulary();
      if (widget.topic.owner == user!.username) {
        isEnableEdit = true;
      }
    }
    setState(() {});
  }

  Future<void> fetchVocabulary() async {
    try {
      var response = await http.get(Uri.parse(
          '$urlRoot/topics/${widget.topic.id}/words/${widget.topic.owner}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          words.clear();
          masteredWords.clear();

          words = (data['listWord'] as List)
              .map((json) => Word.fromJson(json))
              .toList();

          for (var word in words) {
            if (word.status == 'mastered') {
              masteredWords.add(word);
            }
          }
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> reloadTopic() async {
    try {
      var response = await http
          .get(Uri.parse('$urlRoot/topics/getTopic/${widget.topic.id}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            widget.topic = Topic.fromJson(data['topic']);
          });
        }
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var isUpdateAmount = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListVocabularyScreen(
                topic: widget.topic, words: words, isEnableEdit: isEnableEdit),
          ),
        );

        if (isUpdateAmount) {
          reloadTopic();
        }
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.topic.topicName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.library_books, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    '${widget.topic.total} items',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    widget.topic.owner,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
