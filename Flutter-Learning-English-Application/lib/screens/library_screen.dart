import 'dart:convert';
import 'package:application_learning_english/config.dart';
import 'package:application_learning_english/models/folder.dart';
import 'package:application_learning_english/models/topic.dart';
import 'package:application_learning_english/screens/list_topics_in_folder_screen.dart';
import 'package:application_learning_english/widgets/topic_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LibraryScreen extends StatefulWidget {
  final String username;
  final String accountId;
  const LibraryScreen({
    super.key,
    required this.username,
    required this.accountId,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final urlRoot = kIsWeb ? webURL : androidURL;
  List<Topic> topics = [];
  List<Topic> searchTopics = [];
  String selectedFilter = 'This Month';
  late TabController _tabController;
  bool isSearching = false;

  bool isUpdate = false;

  List<Folder> folders = [];
  List<Folder> displayedFolders = [];

  void updatingLibrary() {
    setState(() {
      isUpdate = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isUpdate = false;
      });
    });
  }

  void deleteTopic(String topicId) {
    fetchTopics();
    updatingLibrary();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove topic successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
    fetchTopics();
    fetchFolders();
  }

  Future<void> fetchTopics() async {
    try {
      print('$urlRoot/topics/library/${widget.username}');
      var response = await http
          .get(Uri.parse('$urlRoot/topics/library/${widget.username}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          Iterable it = data['topics'];

          topics = it.map((json) => Topic.fromJson(json)).toList();
          selectedFilter = 'This Month';
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> fetchFolders() async {
    try {
      var response =
          await http.get(Uri.parse('$urlRoot/folders/${widget.accountId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          setState(() {
            folders = (data['listFolder'] as List)
                .map((json) => Folder.fromJson(json))
                .toList();
          });
          displayedFolders = folders;
        }
      } else {
        throw Exception('Failed to load folders');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> addTopic(topicName, isPublic) async {
    try {
      var response = await http.post(Uri.parse('$urlRoot/topics/add'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'topicName': topicName,
            'isPublic': isPublic,
            'owner': widget.username
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          await fetchTopics();
          updatingLibrary();
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
            content: Text('Failed to add topic'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add topic');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> renameFolder(Folder folder, folderName) async {
    if (folderName == folder.folderName) {
      return;
    }
    try {
      var response =
          await http.patch(Uri.parse('$urlRoot/folders/rename/${folder.id}'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, dynamic>{'folderName': folderName}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          fetchFolders();
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
            content: Text('Failed to rename folder'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to rename folder');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> deleteFolder(Folder folder) async {
    try {
      var response =
          await http.delete(Uri.parse('$urlRoot/folders/delete/${folder.id}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete folder successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          fetchFolders();
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
            content: Text('Failed to delete folder'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to delete folder');
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> addFolder(folderName) async {
    try {
      var response =
          await http.post(Uri.parse('$urlRoot/folders/${widget.accountId}/add'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, dynamic>{'folderName': folderName}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          fetchFolders();
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
            content: Text('Failed to add folder'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to add folder');
      }
    } catch (err) {
      print(err);
    }
  }

  void _addTopicDialog() {
    var key = GlobalKey<FormState>();

    String topicName = '';
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Add New Topic"),
            content: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Topic Name', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter topic name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      topicName = value ?? '';
                    },
                  ),
                  Row(
                    children: [
                      Text("Public"),
                      Checkbox(
                        value: isPublic,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            isPublic = value ?? false;
                          });
                        },
                      ),
                    ],
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

                    addTopic(topicName, isPublic);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateDisplayedFolders(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedFolders = folders;
      } else {
        displayedFolders = folders
            .where((folder) =>
                folder.folderName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onTabChanged(int index) {
    if (index == 0) {
      setState(() {
        isSearching = false;
      });
    } else if (index == 1) {
      setState(() {
        displayedFolders = folders;
      });
    }
  }

  void _confirmDeleteFolder(folder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this folder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteFolder(folder);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _renameFolderDialog(folder) {
    var key = GlobalKey<FormState>();
    var folderNameController = TextEditingController();

    String folderName = '';
    folderNameController.text = folder.folderName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Rename Folder"),
            content: Form(
              key: key,
              child: TextFormField(
                controller: folderNameController,
                decoration: InputDecoration(
                    labelText: 'Folder Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter folder name';
                  }
                  return null;
                },
                onSaved: (value) {
                  folderName = value ?? '';
                },
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

                    renameFolder(folder, folderName);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addFolderDialog() {
    var key = GlobalKey<FormState>();

    String folderName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Add New Folder"),
            content: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Folder Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter folder name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      folderName = value ?? '';
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

                    addFolder(folderName);
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Library')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Sets'),
            Tab(text: 'Folders'),
          ],
        ),
      ),
      body: (!isUpdate)
          ? TabBarView(
              controller: _tabController,
              children: [
                mySets(),
                Folders(),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget mySets() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search topic name',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    isSearching = value.isNotEmpty;
                    searchTopics = topics
                        .where((topic) => topic.topicName
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedFilter,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
                items: <String>[
                  'Today',
                  'Yesterday',
                  'During 7 days',
                  'This Month',
                  'This Year',
                  'All'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Stack(
                children: [
                  Opacity(
                      opacity: isSearching ? 0.0 : 1.0,
                      child: buildTopicSections(topics, selectedFilter,
                          widget.username, deleteTopic)),
                  Opacity(
                    opacity: isSearching ? 1.0 : 0.0,
                    child: buildSearchTopics(
                        searchTopics, widget.username, deleteTopic),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTopicDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget Folders() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search folder name',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  updateDisplayedFolders(value);
                },
              ),
              SizedBox(height: 20),
              buildListFolder(
                  displayedFolders,
                  _renameFolderDialog,
                  _confirmDeleteFolder,
                  _addTopicDialog,
                  widget.username,
                  topics),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolderDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget buildSearchTopics(topics, username, deleteTopic) {
  return topics.length > 0
      ? buildSection('Result search', topics, username, deleteTopic)
      : Center(
          child: Text('No topic'),
        );
}

Widget buildTopicSections(topics, selectedFilter, username, deleteTopic) {
  Map<String, List<Topic>> categorizedTopics = {
    'Today': [],
    'Yesterday': [],
    'During 7 days': [],
    'This Month': [],
    'This Year': [],
    'More This Year': [],
  };

  for (var topic in topics) {
    String section = getSectionsFromCreateAt(topic.createAt);
    categorizedTopics[section]?.add(topic);
  }

  bool isEmptyFilter = true;

  bool hasToday = false;
  bool hasYesterday = false;
  bool hasDuring7days = false;
  bool hasThisMonth = false;
  bool hasThisYear = false;
  bool hasAll = false;

  if (categorizedTopics['Today']!.isNotEmpty &&
      (selectedFilter == 'Today' ||
          selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasToday = true;
    isEmptyFilter = false;
  }

  if (categorizedTopics['Yesterday']!.isNotEmpty &&
      (selectedFilter == 'Yesterday' ||
          selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasYesterday = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['During 7 days']!.isNotEmpty &&
      (selectedFilter == 'During 7 days' ||
          selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasDuring7days = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['This Month']!.isNotEmpty &&
      (selectedFilter == 'This Month' ||
          selectedFilter == 'This Year' ||
          selectedFilter == 'All')) {
    hasThisMonth = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['This Year']!.isNotEmpty &&
      (selectedFilter == 'This Year' || selectedFilter == 'All')) {
    hasThisYear = true;
    isEmptyFilter = false;
  }
  if (categorizedTopics['More This Year']!.isNotEmpty &&
      selectedFilter == 'All') {
    hasAll = true;
    isEmptyFilter = false;
  }

  if (isEmptyFilter) {
    return Center(
      child: Text('No topic'),
    );
  }

  return ListView(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: [
      if (hasToday)
        buildSection(
            'Today', categorizedTopics['Today']!, username, deleteTopic),
      if (hasYesterday)
        buildSection('Yesterday', categorizedTopics['Yesterday']!, username,
            deleteTopic),
      if (hasDuring7days)
        buildSection('During 7 days', categorizedTopics['During 7 days']!,
            username, deleteTopic),
      if (hasThisMonth)
        buildSection('This Month', categorizedTopics['This Month']!, username,
            deleteTopic),
      if (hasThisYear)
        buildSection('This Year', categorizedTopics['This Year']!, username,
            deleteTopic),
      if (hasAll)
        buildSection('More This Year', categorizedTopics['More This Year']!,
            username, deleteTopic),
    ],
  );
}

Widget buildSection(
    String title, List<Topic> topics, String username, deleteTopic) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return TopicItem(
              isLibrary: true,
              topic: topics[index],
              username: username,
              onDelete: deleteTopic);
        },
      ),
    ],
  );
}

String getSectionsFromCreateAt(createAt) {
  String yyMmDddd = createAt.split('T')[0];
  int year = int.parse(yyMmDddd.split('-')[0]);
  int month = int.parse(yyMmDddd.split('-')[1]);
  int day = int.parse(yyMmDddd.split('-')[2]);

  DateTime now = DateTime.now();

  if (year == now.year && month == now.month && day == now.day) {
    return 'Today';
  } else if (year == now.year && month == now.month && day == now.day - 1) {
    return 'Yesterday';
  } else if (year == now.year && month == now.month && day > now.day - 7) {
    return 'During 7 days';
  } else if (year == now.year && month == now.month) {
    return 'This Month';
  } else if (year == now.year) {
    return 'This Year';
  } else {
    return 'More This Year';
  }
}

Widget buildListFolder(List<Folder> folders, Function renameFolderDialog,
    Function confirmDeleteFolder, Function addTopicDialog, username, topics) {
  return (folders.isNotEmpty)
      ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            Folder folder = folders[index];
            return InkWell(
              child: Card(
                color: Color.fromARGB(255, 71, 158, 230),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: Colors.yellow,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          renameFolderDialog(folder);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          confirmDeleteFolder(folder);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                  title: Text(
                    folder.folderName,
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListTopicsInFolderScreen(
                          folder: folder,
                          username: username,
                          allTopics: topics,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        )
      : Container(
          alignment: Alignment.center,
          child: Center(child: Text('No folder')),
        );
}
