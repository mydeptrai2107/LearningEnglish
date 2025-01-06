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
      id: json['_id'],
      topicName: json['topicName'],
      isPublic: json['isPublic'],
      owner: json['owner'],
      total: json['total'],
      createAt: json['createAt'],
    );
  }
}
