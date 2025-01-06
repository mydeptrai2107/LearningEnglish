import 'dart:convert'; // Thư viện dùng để xử lý dữ liệu JSON (chuyển đổi giữa JSON và đối tượng Dart).

import 'package:application_learning_english/config.dart'; // Cấu hình URL hoặc các biến cấu hình khác của ứng dụng.
import 'package:application_learning_english/models/topic.dart'; // Mô hình dữ liệu cho Topic.
import 'package:application_learning_english/models/folder.dart'; // Mô hình dữ liệu cho Folder.
import 'package:application_learning_english/widgets/topic_item.dart'; // Widget để hiển thị thông tin topic.
import 'package:flutter/foundation.dart'; // Thư viện giúp kiểm tra môi trường (Web hoặc Android).
import 'package:flutter/material.dart'; // Thư viện Flutter cung cấp các widget UI.
import 'package:http/http.dart'
    as http; // Thư viện HTTP để gửi các yêu cầu HTTP tới server.

class ListTopicsInFolderScreen extends StatefulWidget {
  final Folder folder; // Đối tượng folder chứa các topic.
  final String username; // Tên người dùng đang đăng nhập.
  final List<Topic> allTopics; // Danh sách tất cả các topic từ hệ thống.

  // Constructor của widget, nhận vào các tham số là folder, username và allTopics.
  const ListTopicsInFolderScreen({
    super.key,
    required this.folder, // Yêu cầu truyền vào folder.
    required this.username, // Yêu cầu truyền vào username.
    required this.allTopics, // Yêu cầu truyền vào danh sách allTopics.
  });

  @override
  State<ListTopicsInFolderScreen> createState() =>
      _ListTopicsInFolderScreenState();
}

class _ListTopicsInFolderScreenState extends State<ListTopicsInFolderScreen> {
  final urlRoot = kIsWeb
      ? webURL
      : androidURL; // URL gốc, chọn URL phù hợp với môi trường (Web hoặc Android).

  List<Topic> topics = []; // Danh sách topic trong thư mục hiện tại.

  @override
  void initState() {
    super.initState();
    fetachTopicsInFolder(); // Gọi phương thức để tải các topic trong folder.
  }

  void deleteTopic(
      String topicId) {} // Phương thức để xóa topic (hiện tại chưa triển khai).

  // Phương thức để lấy các topic trong thư mục từ server.
  Future<void> fetachTopicsInFolder() async {
    try {
      var response = await http.get(Uri.parse(
          '$urlRoot/folders/${widget.folder.id}/topics')); // Gửi yêu cầu GET đến server.

      if (response.statusCode == 200) {
        // Kiểm tra nếu trạng thái HTTP là 200 (thành công).
        final data =
            jsonDecode(response.body); // Giải mã JSON từ response body.
        setState(() {
          topics.clear(); // Xóa danh sách topic cũ.
          topics = (data['topics']
                  as List) // Lấy danh sách topics từ response và chuyển thành List<Topic>.
              .map((json) => Topic.fromJson(
                  json)) // Chuyển đổi mỗi đối tượng JSON thành đối tượng Topic.
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
          '$urlRoot/folders/${widget.folder.id}/add-topic/$topicId')); // Gửi yêu cầu POST để thêm topic vào folder.

      if (response.statusCode == 200) {
        // Nếu yêu cầu thành công.
        final data =
            jsonDecode(response.body); // Giải mã dữ liệu trả về từ server.
        if (data['code'] == 0) {
          // Kiểm tra mã trả về từ server.
          fetachTopicsInFolder(); // Lấy lại danh sách topic sau khi thêm.
        }
      } else {
        throw Exception(
            'Failed to add topic to folder'); // Nếu có lỗi, ném ngoại lệ.
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
          '$urlRoot/folders/${widget.folder.id}/remove-topic/$topicId', // Gửi yêu cầu DELETE để xóa topic khỏi folder.
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
            'Failed to remove topic from folder'); // Nếu có lỗi, ném ngoại lệ.
      }
    } catch (err) {
      print(err); // In lỗi nếu có sự cố trong quá trình gửi yêu cầu.
    }
  }

  // Phương thức kiểm tra xem topic đã có trong danh sách chưa.
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
      // Nếu không còn topic nào để thêm.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No topic to add'), // Hiển thị thông báo không có topic để thêm.
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add topic to folder'), // Tiêu đề của hộp thoại.
          content: SizedBox(
            width: double.maxFinite, // Đảm bảo nội dung hộp thoại không bị cắt.
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: showTopics.length, // Số lượng topic cần hiển thị.
              itemBuilder: (context, index) {
                Topic topic = showTopics[index]; // Lấy topic từ danh sách.
                return ListTile(
                  title: Text(topic.topicName), // Hiển thị tên topic.
                  onTap: () {
                    Navigator.pop(
                        context); // Đóng hộp thoại khi người dùng chọn topic.
                    _addTopicToFolder(
                        topic.id); // Gọi phương thức thêm topic vào folder.
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Phương thức để hiển thị danh sách các topic có thể xóa khỏi folder.
  void _showTopicsInFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove topic from folder'), // Tiêu đề của hộp thoại.
          content: SizedBox(
            width: double.maxFinite, // Đảm bảo nội dung hộp thoại không bị cắt.
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: topics.length, // Số lượng topic hiện tại trong folder.
              itemBuilder: (context, index) {
                Topic topic =
                    topics[index]; // Lấy topic từ danh sách trong folder.
                return ListTile(
                  title: Text(topic.topicName), // Hiển thị tên topic.
                  onTap: () {
                    Navigator.pop(
                        context); // Đóng hộp thoại khi người dùng chọn topic.
                    _removeTopicFromFolder(
                        topic.id); // Gọi phương thức xóa topic khỏi folder.
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
        title: Center(child: Text('Topic List')), // Tiêu đề của app bar.
        actions: [
          TextButton(
              onPressed: () {
                if (topics.isNotEmpty) {
                  // Kiểm tra xem folder có topic nào không.
                  _showTopicsInFolderDialog(); // Hiển thị hộp thoại xóa topic khỏi folder.
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
                      itemCount: topics.length, // Số lượng topic trong folder.
                      itemBuilder: (context, index) {
                        Topic topic =
                            topics[index]; // Lấy topic trong danh sách.
                        return TopicItem(
                          isLibrary:
                              true, // Dùng widget TopicItem để hiển thị thông tin topic.
                          topic: topic,
                          username: widget.username, // Truyền tên người dùng.
                          onDelete:
                              deleteTopic, // Phương thức xóa topic (chưa triển khai).
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Empty folder', // Nếu folder không có topic, hiển thị thông báo này.
                      ),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAllTopicsDialog(); // Hiển thị hộp thoại chọn topic để thêm vào folder.
        },
        child: Icon(Icons.add), // Biểu tượng nút thêm topic.
      ),
    );
  }
}
