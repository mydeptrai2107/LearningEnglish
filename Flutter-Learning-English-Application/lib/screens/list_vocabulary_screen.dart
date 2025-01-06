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
  final urlRoot = kIsWeb ? webURL : androidURL;
  bool isUpdateAmount = false;

  void deleteWord(String wordId) {
    setState(() {
      widget.words.removeWhere((word) => word.id == wordId);
      isUpdateAmount = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove word successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void updateWord(Word word) {
    setState(() {
      int index = widget.words.indexWhere((w) => w.id == word.id);
      if (index != -1) {
        widget.words[index] = word;
      }
    });
  }

  void _addVocabularyDialog() {
    var key = GlobalKey<FormState>();
    var englishController = TextEditingController();
    var vietnameseController = TextEditingController();
    var descriptionController = TextEditingController();
    String english = '';
    String vietnamese = '';
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Vocabulary"),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: englishController,
                  decoration: InputDecoration(
                      labelText: 'English meaning',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter English meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    english = value ?? '';
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: vietnameseController,
                  decoration: InputDecoration(
                      labelText: 'Vietname meaning',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vietname meaning';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    vietnamese = value ?? '';
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Description (Can be empty)',
                      border: OutlineInputBorder()),
                  onSaved: (value) {
                    description = value ?? '';
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
                  key.currentState?.save();

                  var listWord = [
                    {
                      'english': english,
                      'vietnamese': vietnamese,
                      'description': description,
                    }
                  ];

                  addWords(listWord);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> addWords(listWord) async {
    try {
      var response = await http.post(
          Uri.parse(
              '$urlRoot/topics/${widget.topic.id}/add-words/${widget.username}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'listWord': listWord,
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            var newWords = data['newWords'];
            for (var newWord in newWords) {
              widget.words.add(Word.fromJson(newWord));
            }
            isUpdateAmount = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add word'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add word');
      }
    } catch (err) {
      print(err);
    }
  }

  void _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        String fileContent = utf8.decode(result.files.single.bytes!);

        List<List<dynamic>> csvData = CsvToListConverter().convert(fileContent);

        List<Map<String, String>> listWord = [];
        for (var i = 1; i < csvData.length; i++) {
          listWord.add({
            'english': csvData[i][0],
            'vietnamese': csvData[i][1],
          });
        }

        _showConfirmationDialog(listWord);
      } else {
        print("No file selected or file is empty.");
      }
    } catch (e) {
      print("Error picking or reading file: $e");
    }
  }

  void _exportFile() async {
    List<Map<String, String>> listWord = [];

    for (var word in widget.words) {
      listWord.add({
        'english': word.english,
        'vietnamese': word.vietnamese,
      });
    }

    try {
      var csvContent = StringBuffer();
      csvContent.writeln('English,Vietnamese');

      for (var word in listWord) {
        csvContent.writeln('${word['english']},${word['vietnamese']}');
      }

      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String folderPath = '${directory.path}/YourFolderName';

        print(folderPath);

        // Directory(folderPath).createSync(recursive: true);

        // String filePath = '$folderPath/Vocabularies.csv';

        // await File(filePath).writeAsString(csvContent.toString());

        // print('Exported file saved at: $filePath');
      } else {
        print('Could not access storage directory.');
      }
    } catch (e) {
      print('Error exporting file: $e');
    }
  }

  void _showConfirmationDialog(List<Map<String, String>> listWord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Add Words To Topic"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: listWord.map((word) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0),
                  elevation: 3.0,
                  child: ListTile(
                    leading: Icon(Icons.g_translate, color: Colors.blue),
                    title: Text(word['english']!,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(word['vietnamese']!),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                addWords(listWord);
                Navigator.of(context).pop();
              },
              child: Text("Confirm", style: TextStyle(color: Colors.green)),
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
