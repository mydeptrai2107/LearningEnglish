import 'dart:convert';
import 'dart:io';

import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/models/word.dart';
import 'package:application_learning_english/screens/Vocab_learning/main_menu.dart';
import 'package:application_learning_english/widgets/word_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class ListVocabularyScreen extends StatefulWidget {
  final List<Word> words;
  final Topic topic;
  final bool isEnableEdit;
  final String username;

  const ListVocabularyScreen({
    super.key,
    required this.words,
    required this.topic,
    required this.isEnableEdit,
    required this.username,
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

  void deleteWord(String wordId) {
    setState(() {

      widget.words.removeWhere(
          (word) => word.id == wordId);
      isUpdateAmount = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      // Hiển thị thông báo thành công
      const SnackBar(
        content: Text('Remove word successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }


  void updateWord(Word word) {
    setState(() {
      int index = widget.words.indexWhere(
          (w) => w.id == word.id);
      if (index != -1) {

        widget.words[index] = word;
      }
    });
  }


  void _addVocabularyDialog() {
    var key = GlobalKey<FormState>();
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
          title: Text("Add Vocabulary"), // Tiêu đề của hộp thoại
          content: Form(
            // Form nhập liệu cho từ vựng
            key: key,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Dễ dàng thay đổi chiều cao của form
              children: [
                TextFormField(
                  // Trường nhập từ tiếng Anh
                  controller: englishController,
                  decoration: InputDecoration(
                      labelText: 'English meaning', // Nhãn trường
                      border: OutlineInputBorder()),
                  validator: (value) {
                    // Kiểm tra dữ liệu nhập vào
                    if (value == null || value.isEmpty) {
                      return 'Please enter English meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    english = value ?? ''; // Lưu giá trị khi form được lưu
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  // Trường nhập từ tiếng Việt
                  controller: vietnameseController,
                  decoration: InputDecoration(
                      labelText: 'Vietnamese meaning',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vietnamese meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    vietnamese = value ?? ''; // Lưu giá trị tiếng Việt
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  // Trường nhập mô tả (có thể để trống)
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description (Can be empty)',
                      border: OutlineInputBorder()),
                  onSaved: (value) {
                    description = value ?? ''; // Lưu mô tả
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState?.validate() ?? false) {
                  // Kiểm tra form hợp lệ
                  key.currentState?.save(); // Lưu dữ liệu form

                  var listWord = [
                    {
                      'english': english,
                      'vietnamese': vietnamese,
                      'description': description,
                    }
                  ];

                  addWords(listWord); // Thêm từ vựng vào hệ thống
                  Navigator.of(context).pop(); // Đóng hộp thoại
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

// Hàm gọi API để thêm từ vựng
  Future<void> addWords(listWord) async {
    try {
      var response = await http.post(
          Uri.parse(
              '$urlRoot/topics/${widget.topic.id}/add-words/${widget.username}'), // Gọi API thêm từ vựng
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'listWord': listWord, // Gửi danh sách từ vựng
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Giải mã dữ liệu trả về từ API
        if (data['code'] == 0) {
          // Kiểm tra nếu thêm từ thành công
          setState(() {
            var newWords = data['newWords'];
            for (var newWord in newWords) {
              widget.words
                  .add(Word.fromJson(newWord)); // Thêm từ mới vào danh sách
            }
            isUpdateAmount = true; // Đánh dấu đã cập nhật số lượng từ vựng
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // Hiển thị thông báo lỗi
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // Hiển thị thông báo lỗi nếu API thất bại
          const SnackBar(
            content: Text('Failed to add word'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add word');
      }
    } catch (err) {
      print(err); // In lỗi nếu có
    }
  }

// Hàm để nhập từ file CSV
  void _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // Chọn file CSV
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        String fileContent = utf8
            .decode(result.files.single.bytes!); // Giải mã nội dung file CSV

        List<List<dynamic>> csvData = CsvToListConverter()
            .convert(fileContent); // Chuyển đổi CSV thành danh sách

        List<Map<String, String>> listWord = [];
        for (var i = 1; i < csvData.length; i++) {
          // Duyệt qua từng dòng dữ liệu
          listWord.add({
            'english': csvData[i][0], // Lấy từ tiếng Anh
            'vietnamese': csvData[i][1], // Lấy từ tiếng Việt
          });
        }

        _showConfirmationDialog(listWord); // Hiển thị hộp thoại xác nhận
      } else {
        print("No file selected or file is empty.");
      }
    } catch (e) {
      print("Error picking or reading file: $e"); // In lỗi nếu có
    }
  }

// Hàm xuất từ vựng ra file CSV
  void _exportFile() async {
    List<Map<String, String>> listWord = [];

    for (var word in widget.words) {
      listWord.add({
        'english': word.english,
        'vietnamese': word.vietnamese,
      });
    }

    try {
      var csvContent = StringBuffer(); // Tạo nội dung CSV
      csvContent.writeln('English,Vietnamese'); // Tiêu đề các cột

      for (var word in listWord) {
        // Duyệt qua danh sách từ vựng và thêm vào CSV
        csvContent.writeln('${word['english']},${word['vietnamese']}');
      }

      Directory? directory =
          await getExternalStorageDirectory(); // Lấy thư mục lưu trữ ngoài
      if (directory != null) {
        String folderPath =
            '${directory.path}/YourFolderName'; // Đường dẫn thư mục xuất file

        print(folderPath); // In ra đường dẫn

        // Bạn có thể tạo thư mục và xuất file tại đây nếu cần
      } else {
        print('Could not access storage directory.');
      }
    } catch (e) {
      print('Error exporting file: $e'); // In lỗi nếu có
    }
  }

// Hàm hiển thị hộp thoại xác nhận việc nhập từ
  void _showConfirmationDialog(List<Map<String, String>> listWord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("Confirm Add Words To Topic"), // Tiêu đề hộp thoại xác nhận
          content: SingleChildScrollView(
            // Hiển thị danh sách các từ
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: listWord.map((word) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  elevation: 3.0,
                  child: ListTile(
                    leading: Icon(Icons.g_translate,
                        color: Colors.blue), // Icon gtranslate
                    title: Text(word['english']!,
                        style: TextStyle(
                            fontWeight:
                                FontWeight.bold)), // Tiêu đề là từ tiếng Anh
                    subtitle:
                        Text(word['vietnamese']!), // Mô tả là từ tiếng Việt
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Cancel",
                  style: TextStyle(color: Colors.red)), // Nút hủy
            ),
            TextButton(
              onPressed: () {
                addWords(listWord); // Gọi hàm thêm từ vào hệ thống
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Confirm",
                  style: TextStyle(color: Colors.green)), // Nút xác nhận
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
            TextButton(onPressed: _importFile, child: Text('Import')),
          TextButton(onPressed: _exportFile, child: Text('Export')),
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
        ],
      ),
      body: Container(
        color: Colors.blueGrey[100],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              (widget.words.isNotEmpty)
                  ? Expanded(
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
                    )
                  : Center(
                      child: Text('No vocabulary'),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenu(
                words: widget.words,
              ),
            ),
          );
        },
        child: Icon(Icons.school),
      ),
    );
  }
}
