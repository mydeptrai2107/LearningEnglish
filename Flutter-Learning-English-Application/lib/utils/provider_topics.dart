import 'package:application_learning_english/models/topic.dart';
import 'package:flutter/material.dart';

class TopicsProvider extends ChangeNotifier {
  List<Topic> _topics = [];

  List<Topic> get topics => _topics;

  void setTopics(List<Topic> newTopics) {
    _topics = newTopics;

    notifyListeners();
  }
}
