import 'dart:convert';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/widgets/achievement.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:application_learning_english/widgets/word_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:shared_preferences/shared_preferences.dart";
import '../utils/session_user.dart';

import '../user.dart';

class ListVocabularyScreen extends StatefulWidget {
  final List<Word> words;
  final Topic topic;
  final bool isEnableEdit;

  const ListVocabularyScreen({
    super.key,
    required this.words,
    required this.topic,
    required this.isEnableEdit,
  });

  @override
  State<ListVocabularyScreen> createState() => _ListVocabularyScreenState();
}

class _ListVocabularyScreenState extends State<ListVocabularyScreen> {
  final urlRoot = kIsWeb
      ? webURL
      : androidURL;
  bool isUpdateAmount =
      false;

  late SharedPreferences
      prefs;
  User? user;

  @override
  void initState() {
    super.initState();
    loadUser();

  }

  loadUser() async {
    user =
        await getUserData();
    setState(() {});
  }

// Hàm xóa từ vựng khỏi danh sách
  void deleteWord(String wordId) {
    setState(() {
      widget.words.removeWhere(
          (word) => word.id == wordId); // Xóa từ vựng khỏi danh sách
      isUpdateAmount = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      // Hiển thị snackbar thông báo đã xóa thành công
      const SnackBar(
        content: Text('Remove word successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

// Hàm hiển thị dialog để thêm từ vựng mới
  void _addVocabularyDialog() {
    var key = GlobalKey<FormState>(); // Khởi tạo key cho form
    var englishController =
        TextEditingController();
    var vietnameseController =
        TextEditingController();
    var descriptionController =
        TextEditingController();
    String english = '';
    String vietnamese = '';
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Vocabulary"), // Tiêu đề của dialog
          content: Form(
            key: key, // Gán key cho form
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Duy trì kích thước nhỏ nhất cho dialog
              children: [
                TextFormField(
                  controller:
                      englishController,
                  decoration: InputDecoration(
                      labelText: 'English meaning', // Ghi chú cho ô nhập
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter English meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    english = value ?? ''; // Lưu giá trị khi form được lưu
                  },
                ),
                SizedBox(height: 16), // Khoảng cách giữa các trường
                TextFormField(
                  controller:
                      vietnameseController, // Controller cho ô nhập từ vựng tiếng Việt
                  decoration: InputDecoration(
                    labelText: 'Vietname meaning',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vietname meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    vietnamese = value ?? ''; // Lưu giá trị khi form được lưu
                  },
                ),
                SizedBox(height: 16), // Khoảng cách giữa các trường
                TextFormField(
                  controller:
                      descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Can be empty)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    description = value ?? ''; // Lưu mô tả nếu có
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState?.validate() ?? false) {
                  // Kiểm tra tính hợp lệ của form
                  key.currentState?.save(); // Lưu các giá trị của form

                  var listWord = [
                    {
                      'english': english,
                      'vietnamese': vietnamese,
                      'description': description,
                    }
                  ];

                  addWords(listWord); // Thêm từ vựng vào hệ thống
                  Navigator.of(context)
                      .pop(); // Đóng dialog sau khi lưu thành công
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

// Hàm cập nhật từ vựng
  void updateWord(Word word) {
    setState(() {
      int index = widget.words.indexWhere(
          (w) => w.id == word.id);
      if (index != -1) {
        widget.words[index] = word; // Cập nhật từ vựng trong danh sách
      }
    });
  }

// Hàm thêm chủ đề vào người dùng
  Future<void> addTopicToUser() async {
    try {
      var response = await http.post(
          Uri.parse(
              '$urlRoot/topics/${widget.topic.id}/borrow-topic/${user!.username}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            // Hiển thị thông báo sau khi thêm chủ đề thành công
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // Thông báo nếu không thành công
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // Thông báo nếu có lỗi trong việc gửi request
          const SnackBar(
            content: Text('Failed to add topic to user'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add topic to user');
      }
    } catch (err) {
      print(err); // In lỗi nếu có ngoại lệ xảy ra
    }
  }

// Hàm thêm từ vào hệ thống
  Future<void> addWords(listWord) async {
    try {
      var response = await http.post(
          Uri.parse('$urlRoot/topics/${widget.topic.id}/add-words/thanhtuan'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'listWord': listWord, // Gửi danh sách từ vựng lên server
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            var newWords = data['newWords'];
            for (var newWord in newWords) {
              widget.words.add(
                  Word.fromJson(newWord));
            }
            isUpdateAmount =
                true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // Hiển thị thông báo nếu không thành công
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // Thông báo nếu không thể thêm từ
          const SnackBar(
            content: Text('Failed to add word'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add word');
      }
    } catch (err) {
      print(err); // In lỗi nếu có ngoại lệ xảy ra
    }
  }

// Hàm hiển thị dialog xác nhận
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text(
              "Are you sure you want to add this topic?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog nếu bấm "Cancel"
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                addTopicToUser();
              },
              child: Text("Confirm"),
            ),
          ],
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
            Navigator.pop(context, isUpdateAmount);
          },
        ),
        title: Center(child: Text('Vocabulary List')),
        actions: [
          if (widget.isEnableEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () {
                    _addVocabularyDialog();
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 30,
                    color: Color.fromARGB(255, 33, 44, 204),
                  ),
                ),
              ),
            ),
          if (!widget.isEnableEdit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  icon: Icon(
                    Icons.my_library_add,
                    size: 30,
                    color: Color.fromARGB(255, 33, 44, 204),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey[100],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView.builder(
            itemCount: widget.words.length,
            itemBuilder: (context, index) {
              return WordItem(
                  word: widget.words[index],
                  onDelete: deleteWord,
                  onUpdate: updateWord,
                  isEnableEdit: widget.isEnableEdit);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeaderBoards(topicId: widget.topic.id)),
          );
        },
        child: Icon(Icons.emoji_events),
      ),
    );
  }
}
