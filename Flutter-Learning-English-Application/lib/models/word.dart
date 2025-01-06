class Word {
  final String id;
  final String username;
  final String topicId;
  final String english;
  final String vietnamese;
  final String description;
  late final bool isStarred;
  final int numberCorrect;
  final String status;

  Word({
    required this.id,
    required this.username,
    required this.topicId,
    required this.english,
    required this.vietnamese,
    required this.description,
    required this.isStarred,
    required this.numberCorrect,
    required this.status,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['_id'],
      username: json['username'],
      topicId: json['topicId'],
      english: json['english'],
      vietnamese: json['vietnamese'],
      description: json['description'] ?? '',
      isStarred: json['isStarred'],
      numberCorrect: json['numberCorrect'],
      status: json['status'],
    );
  }
}
