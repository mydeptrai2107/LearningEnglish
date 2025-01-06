import 'dart:convert';
import 'package:application_learning_english/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:application_learning_english/widgets/topic_achi.dart';

import '../models/topic.dart';

class PopularFlashcard extends StatefulWidget {
  const PopularFlashcard({super.key});

  @override
  State<PopularFlashcard> createState() => _PopularFlashcardState();
}

class _PopularFlashcardState extends State<PopularFlashcard> {
  final urlRoot = kIsWeb ? webURL : androidURL;

  List<Topic> topics = [];
  List<Topic> searchTopics = [];
  String selectedFilter = 'This Month';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    try {
      var response = await http.get(Uri.parse('$urlRoot/topics/public'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          topics = (data['listTopic'] as List)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Popular topic'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle adding new items
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search topic name',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    isSearching = value.isNotEmpty;
                    searchTopics = topics
                        .where((topic) => topic.topicName
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedFilter,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
                items: <String>[
                  'Today',
                  'Yesterday',
                  'During 7 days',
                  'This Month',
                  'This Year',
                  'All'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Stack(
                children: [
                  Opacity(
                      opacity: isSearching ? 0.0 : 1.0,
                      child: buildTopicSections(topics, selectedFilter)),
                  Opacity(
                    opacity: isSearching ? 1.0 : 0.0,
                    child: buildSearchTopics(searchTopics),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSearchTopics(topics) {
  return topics.length > 0
      ? buildSection('Result search', topics)
      : Center(
          child: Text('No topic'),
        );
}

Widget buildTopicSections(topics, selectedFilter) {
  Map<String, List<Topic>> categorizedTopics = {
    'Today': [],
    'Yesterday': [],
    'During 7 days': [],
    'This Month': [],
    'This Year': [],
    'More This Year': [],
  };

  for (var topic in topics) {
    String section = getSectionsFromCreateAt(topic.createAt);
    categorizedTopics[section]?.add(topic);
  }

  bool isEmptyFilter = true;

  bool hasToday = false;
  bool hasYesterday = false;
  bool hasDuring7days = false;
  bool hasThisMonth = false;
  bool hasThisYear = false;
  bool hasAll = false;

  if (categorizedTopics['Today']!.isNotEmpty &&
      (selectedFilter == 'Today' ||
          selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasToday = true;
    isEmptyFilter = false;
  }

  if (categorizedTopics['Yesterday']!.isNotEmpty &&
      (selectedFilter == 'Yesterday' ||
          selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasYesterday = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['During 7 days']!.isNotEmpty &&
      (selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasDuring7days = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['This Month']!.isNotEmpty &&
      (selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasThisMonth = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['This Year']!.isNotEmpty &&
      (selectedFilter == 'This Year' || selectedFilter == 'All')) {
    hasThisYear = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['More This Year']!.isNotEmpty &&
      selectedFilter == 'All') {
    hasAll = true;
    isEmptyFilter = false;
  }

  if (isEmptyFilter) {
    return Center(
      child: Text('No topic'),
    );
  }

  return ListView(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: [
      if (hasToday) buildSection('Today', categorizedTopics['Today']!),
      if (hasYesterday)
        buildSection('Yesterday', categorizedTopics['Yesterday']!),
      if (hasDuring7days)
        buildSection('During 7 days', categorizedTopics['During 7 days']!),
      if (hasThisMonth)
        buildSection('This Month', categorizedTopics['This Month']!),
      if (hasThisYear)
        buildSection('This Year', categorizedTopics['This Year']!),
      if (hasAll)
        buildSection('More This Year', categorizedTopics['More This Year']!),
    ],
  );
}

Widget buildSection(String title, List<Topic> topics) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return TopicItem(
            topic: topics[index],
          );
        },
      ),
    ],
  );
}

String getSectionsFromCreateAt(createAt) {
  String yyMmDddd = createAt.split('T')[0];
  int year = int.parse(yyMmDddd.split('-')[0]);
  int month = int.parse(yyMmDddd.split('-')[1]);
  int day = int.parse(yyMmDddd.split('-')[2]);

  DateTime now = DateTime.now();

  if (year == now.year && month == now.month && day == now.day) {
    return 'Today';
  } else if (year == now.year && month == now.month && day == now.day - 1) {
    return 'Yesterday';
  } else if (year == now.year && month == now.month && day > now.day - 7) {
    return 'During 7 days';
  } else if (year == now.year && month == now.month) {
    return 'This Month';
  } else if (year == now.year) {
    return 'This Year';
  } else {
    return 'More This Year';
  }
}
