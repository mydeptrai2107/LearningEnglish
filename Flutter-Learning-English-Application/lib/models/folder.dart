class Folder {
  final String id;
  final String folderName;
  final String accountId;
  final String createAt;

  Folder({
    required this.id,
    required this.folderName,
    required this.accountId,
    required this.createAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['_id'] as String,
      folderName: json['folderName'] as String,
      accountId: json['accountId'] as String,
      createAt: json['createAt'] as String
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'folderName': folderName,
      'accountId': accountId,
      'createAt': createAt
    };
  }
}
