import '../model/topics.dart';

class Achievement{
  final String id;
  final String category;
  final int rank;
  final String topicId;
  final String achievement;
  final String createAt;
  final String username;
  final Topic topic;

  Achievement({
    required this.id,
    required this.category,
    required this.rank,
    required this.topicId,
    required this.achievement,
    required this.createAt,
    required this.username,
    required this.topic,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] as String,
      category: json['category'] as String,
      rank: json['rank'] as int,
      topicId: json['topicId'] as String,
      achievement: json['achievement'] as String,
      createAt: json['createAt'] as String,
      username: json['username'] as String,
      topic: Topic.fromJson(json['topic']),
    );
  }
}