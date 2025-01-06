import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/folder.dart';
import 'package:application_learning_english/widgets/topic_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListTopicsInFolderScreen extends StatefulWidget {
  final Folder folder;
  final String username;
  final List<Topic> allTopics;

  const ListTopicsInFolderScreen({
    super.key,
    required this.folder,
    required this.username,
    required this.allTopics,
  });

  @override
  State<ListTopicsInFolderScreen> createState() =>
      _ListTopicsInFolderScreenState();
}

class _ListTopicsInFolderScreenState extends State<ListTopicsInFolderScreen> {
  final urlRoot = kIsWeb ? webURL : androidURL;

  List<Topic> topics = [];

  @override
  void initState() {
    super.initState();
    fetachTopicsInFolder();
  }

  void deleteTopic(String topicId) {}

  Future<void> fetachTopicsInFolder() async {
    try {
      var response = await http
          .get(Uri.parse('$urlRoot/folders/${widget.folder.id}/topics'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          topics.clear();

          topics = (data['topics'] as List)
              .map((json) => Topic.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> _addTopicToFolder(topicId) async {
    try {
      var response = await http.post(
          Uri.parse('$urlRoot/folders/${widget.folder.id}/add-topic/$topicId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          fetachTopicsInFolder();
        }
      } else {
        throw Exception('Failed to add topic to folder');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> _removeTopicFromFolder(topicId) async {
    try {
      var response = await http.delete(
        Uri.parse(
          '$urlRoot/folders/${widget.folder.id}/remove-topic/$topicId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          fetachTopicsInFolder();
        }
      } else {
        throw Exception('Failed to remove topic from folder');
      }
    } catch (err) {
      print(err);
    }
  }

  bool _topicIdsInList(List<Topic> topics, String topicId) {
    for (var topic in topics) {
      if (topic.id == topicId) {
        return true;
      }
    }
    return false;
  }

  void _showAllTopicsDialog() {
    List<Topic> showTopics = widget.allTopics
        .where((topic) => !_topicIdsInList(topics, topic.id))
        .toList();

    if (showTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No topic to add'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add topic to folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: showTopics.length,
              itemBuilder: (context, index) {
                Topic topic = showTopics[index];
                return ListTile(
                  title: Text(topic.topicName),
                  onTap: () {
                    Navigator.pop(context);
                    _addTopicToFolder(topic.id);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showTopicsInFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove topic from folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: topics.length,
              itemBuilder: (context, index) {
                Topic topic = topics[index];
                return ListTile(
                  title: Text(topic.topicName),
                  onTap: () {
                    Navigator.pop(context);
                    _removeTopicFromFolder(topic.id);
                  },
                );
              },
            ),
          ),
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
            Navigator.pop(context);
          },
        ),
        title: Center(child: Text('Topic List')),
        actions: [
          TextButton(
              onPressed: () {
                if (topics.isNotEmpty) {
                  _showTopicsInFolderDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Empty folder'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Remove topic'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: topics.isNotEmpty
                  ? ListView.builder(
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        Topic topic = topics[index];
                        return TopicItem(
                          isLibrary: true,
                          topic: topic,
                          username: widget.username,
                          onDelete: deleteTopic,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Empty folder',
                      ),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAllTopicsDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
