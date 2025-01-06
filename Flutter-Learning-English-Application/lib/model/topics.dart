class Topic {
  final String id;
  final String topicName;
  final bool isPublic;
  final String owner;
  final int total;
  final String createAt;

  Topic({
    required this.id,
    required this.topicName,
    required this.isPublic,
    required this.owner,
    required this.total,
    required this.createAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['_id'] as String,
      topicName: json['topicName'] as String,
      isPublic: json['isPublic'] as bool,
      owner: json['owner'] as String,
      total: json['total'] as int,
      createAt: json['createAt'] as String,
    );
  }
}