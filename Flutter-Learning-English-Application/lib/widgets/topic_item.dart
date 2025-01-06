import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:application_learning_english/screens/list_vocabulary_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TopicItem extends StatefulWidget {
  Topic topic;
  String username;
  final Function(String) onDelete;
  bool isLibrary;

  TopicItem({
    super.key,
    required this.topic,
    required this.username,
    required this.onDelete,
    required this.isLibrary,
  });

  @override
  State<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  final urlRoot = kIsWeb ? webURL : androidURL;
  List<Word> words = [];
  List<Word> masteredWords = [];
  bool isEnableEdit = false;

  @override
  void initState() {
    super.initState();
    fetchVocabulary();
    reloadTopic();

    if (widget.topic.owner == widget.username) {
      setState(() {
        isEnableEdit = true;
      });
    } else {
      setState(() {
        isEnableEdit = false;
      });
    }
  }

  Future<void> fetchVocabulary() async {
    try {
      var response = await http.get(Uri.parse(
          '$urlRoot/topics/${widget.topic.id}/words/${widget.username}'));

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
      if (widget.topic.owner == widget.username) {
        setState(() {
          isEnableEdit = true;
        });
      } else {
        setState(() {
          isEnableEdit = false;
        });
      }
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

  Future<void> deleteTopic() async {
    try {
      var response = await http.delete(
        Uri.parse('$urlRoot/topics/delete/${widget.topic.id}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          widget.onDelete(widget.topic.id);
        }
      } else {
        throw Exception('Failed to remove word');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> renameTopic(topicName) async {
    try {
      var response = await http.patch(
        Uri.parse('$urlRoot/topics/rename/${widget.topic.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'topicName': topicName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            widget.topic = Topic.fromJson(data['updatedTopic']);
          });
        }
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  void _renameTopicDialog() {
    var key = GlobalKey<FormState>();
    var topicNameController = TextEditingController();

    String topicName = '';
    topicNameController.text = widget.topic.topicName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Rename Topic"),
            content: Form(
              key: key,
              child: TextFormField(
                controller: topicNameController,
                decoration: InputDecoration(
                    labelText: 'Topic Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter topic name';
                  }
                  return null;
                },
                onSaved: (value) {
                  topicName = value ?? '';
                },
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

                    renameTopic(topicName);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this topic?"),
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
                deleteTopic();
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await fetchVocabulary();
        await reloadTopic();
        var isUpdateAmount = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListVocabularyScreen(
              topic: widget.topic,
              words: words,
              isEnableEdit: isEnableEdit,
              username: widget.username,
            ),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.topic.topicName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        (widget.topic.isPublic)
                            ? Icon(
                                Icons.public,
                                color: Colors.blueGrey,
                              )
                            : Icon(
                                Icons.lock,
                                color: Colors.grey,
                                size: 18.0,
                              )
                      ],
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
                    SizedBox(height: 5),
                    if (widget.isLibrary)
                      Row(
                        children: [
                          Icon(Icons.timeline, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'Progress: ${masteredWords.length}/${widget.topic.total}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 5),
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
              if (isEnableEdit)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueGrey),
                      onPressed: _renameTopicDialog,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.black),
                      onPressed: confirmDelete,
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
