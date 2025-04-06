import 'dart:convert'; // Thư viện dùng để xử lý dữ liệu JSON (chuyển đổi giữa JSON và đối tượng Dart).

import 'package:application_learning_english/config.dart'; // Cấu hình URL hoặc các biến cấu hình khác của ứng dụng.
import 'package:application_learning_english/models/topic.dart'; // Mô hình dữ liệu cho Topic.
import 'package:application_learning_english/models/folder.dart'; // Mô hình dữ liệu cho Folder.
import 'package:application_learning_english/widgets/topic_item.dart'; // Widget để hiển thị thông tin topic.
import 'package:flutter/foundation.dart'; // Thư viện giúp kiểm tra môi trường (Web hoặc Android).
import 'package:flutter/material.dart'; // Thư viện Flutter cung cấp các widget UI.
import 'package:http/http.dart'
    as http;

class ListTopicsInFolderScreen extends StatefulWidget {
  final Folder folder;
  final String username;
  final List<Topic> allTopics;

  // Constructor của widget, nhận vào các tham số là folder, username và allTopics.
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
  final urlRoot = kIsWeb
      ? webURL
      : androidURL;

  List<Topic> topics = [];

  @override
  void initState() {
    super.initState();
    fetachTopicsInFolder();
  }

  void deleteTopic(
      String topicId) {}
  // Phương thức để lấy các topic trong thư mục từ server.
  Future<void> fetachTopicsInFolder() async {
    try {
      var response = await http.get(Uri.parse(
          '$urlRoot/folders/${widget.folder.id}/topics')); // Gửi yêu cầu GET đến server.

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);
        setState(() {
          topics.clear();
          topics = (data['topics']
                  as List)
              .map((json) => Topic.fromJson(
                  json))
              .toList();
        });
      } else {
        throw Exception(
            'Failed to load topics'); // Nếu không thành công, ném ngoại lệ.
      }
    } catch (err) {
      print(err); // In lỗi ra nếu có vấn đề trong quá trình tải dữ liệu.
    }
  }

  // Phương thức để thêm một topic vào folder.
  Future<void> _addTopicToFolder(topicId) async {
    try {
      var response = await http.post(Uri.parse(
          '$urlRoot/folders/${widget.folder.id}/add-topic/$topicId'));

      if (response.statusCode == 200) {
        // Nếu yêu cầu thành công.
        final data =
            jsonDecode(response.body);
        if (data['code'] == 0) {
          // Kiểm tra mã trả về từ server.
          fetachTopicsInFolder(); // Lấy lại danh sách topic sau khi thêm.
        }
      } else {
        throw Exception(
            'Failed to add topic to folder');
      }
    } catch (err) {
      print(err); // In lỗi nếu có sự cố trong quá trình gửi yêu cầu.
    }
  }

  // Phương thức để xóa một topic khỏi folder.
  Future<void> _removeTopicFromFolder(topicId) async {
    try {
      var response = await http.delete(
        Uri.parse(
          '$urlRoot/folders/${widget.folder.id}/remove-topic/$topicId',
        ),
      );

      if (response.statusCode == 200) {
        // Nếu yêu cầu thành công.
        final data =
            jsonDecode(response.body); // Giải mã dữ liệu trả về từ server.
        if (data['code'] == 0) {
          // Kiểm tra mã trả về từ server.
          fetachTopicsInFolder(); // Lấy lại danh sách topic sau khi xóa.
        }
      } else {
        throw Exception(
            'Failed to remove topic from folder');
      }
    } catch (err) {
      print(err);
    }
  }


  bool _topicIdsInList(List<Topic> topics, String topicId) {
    for (var topic in topics) {
      // Duyệt qua danh sách topic hiện tại.
      if (topic.id == topicId) {
        // Nếu tìm thấy topic có ID trùng.
        return true; // Trả về true.
      }
    }
    return false; // Nếu không tìm thấy, trả về false.
  }

  // Phương thức để hiển thị danh sách các topic có thể thêm vào folder.
  void _showAllTopicsDialog() {
    List<Topic> showTopics = widget.allTopics
        .where((topic) => !_topicIdsInList(
            topics, topic.id)) // Lọc các topic chưa có trong folder.
        .toList();

    if (showTopics.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No topic to add'),
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
                Topic topic = showTopics[index]; // Lấy topic từ danh sách.
                return ListTile(
                  title: Text(topic.topicName), // Hiển thị tên topic.
                  onTap: () {
                    Navigator.pop(
                        context);
                    _addTopicToFolder(
                        topic.id);
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
                Topic topic =
                    topics[index];
                return ListTile(
                  title: Text(topic.topicName), // Hiển thị tên topic.
                  onTap: () {
                    Navigator.pop(
                        context);
                    _removeTopicFromFolder(
                        topic.id);
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
          // Nút quay lại khi người dùng nhấn vào.
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước.
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
                      content: Text('Empty folder'), // Thông báo folder rỗng.
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Remove topic')) // Nút xóa topic.
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: topics.isNotEmpty // Kiểm tra nếu có topic trong folder.
                  ? ListView.builder(
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        Topic topic =
                            topics[index]; // Lấy topic trong danh sách.
                        return TopicItem(
                          isLibrary:
                              true,
                          topic: topic,
                          username: widget.username,
                          onDelete:
                              deleteTopic, // Phương thức xóa topic (chưa triển khai).
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
