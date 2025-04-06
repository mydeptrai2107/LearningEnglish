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
      isUpdate = true; // Đánh dấu trạng thái đang cập nhật
    });


    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isUpdate = false; // Kết thúc trạng thái cập nhật
      });
    });
  }


  void deleteTopic(String topicId) {
    fetchTopics();
    updatingLibrary();


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remove topic successfully'),
        duration: Duration(seconds: 2)
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this);
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
      print('$urlRoot/topics/library/${widget.username}'); // Log URL để debug
      var response = await http
          .get(Uri.parse('$urlRoot/topics/library/${widget.username}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          Iterable it = data['topics'];
          topics = it
              .map((json) => Topic.fromJson(json))
              .toList();
          selectedFilter = 'This Month';
        });
      } else {
        throw Exception(
            'Failed to load topics');
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
      print(err); // Log lỗi
    }
  }

// Hàm thêm chủ đề mới
  Future<void> addTopic(topicName, isPublic) async {
    try {
      var response = await http.post(Uri.parse('$urlRoot/topics/add'),
          headers: <String, String>{
            'Content-Type':
                'application/json; charset=UTF-8',
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

// Hàm đổi tên thư mục
  Future<void> renameFolder(Folder folder, folderName) async {
    if (folderName == folder.folderName) {
      return;// Không thực hiện nếu tên không thay đổi
    }
    try {
      var response = await http.patch(
          Uri.parse('$urlRoot/folders/rename/${folder.id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'folderName': folderName
          })); // Gửi dữ liệu tên mới

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 0) {
          fetchFolders(); // Tải lại danh sách thư mục
        } else {
          // Hiển thị lỗi từ server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'].toString()),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to rename folder'),
            duration: Duration(seconds: 2),
          ),
        );
        throw Exception('Failed to rename folder');
      }
    } catch (err) {
      print(err); // Log lỗi
    }
  }


  Future<void> deleteFolder(Folder folder) async {
    try {
      var response = await http.delete(Uri.parse(
          '$urlRoot/folders/delete/${folder.id}'));

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

// Hàm thêm thư mục mới
  Future<void> addFolder(folderName) async {
    try {
      var response = await http.post(
          Uri.parse('$urlRoot/folders/${widget.accountId}/add'),
          headers: <String, String>{
            'Content-Type':
                'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'folderName': folderName
          }));

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
      print(err); // Log lỗi
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
                mainAxisSize:
                    MainAxisSize.min,
                children: [

                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Topic Name',
                      border: OutlineInputBorder(), // Định dạng đường viền
                    ),
                    validator: (value) {
                      // Xác thực: Tên chủ đề không được để trống
                      if (value == null || value.isEmpty) {
                        return 'Please enter topic name';
                      }
                      return null; // Hợp lệ nếu không có lỗi
                    },
                    onSaved: (value) {
                      // Lưu giá trị của trường nhập vào biến topicName
                      topicName = value ?? '';
                    },
                  ),
                  Row(
                    children: [
                      Text("Public"), // Nhãn cho trạng thái công khai
                      Checkbox(
                        value: isPublic, // Trạng thái của checkbox
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
              // Nút Cancel để đóng hộp thoại mà không lưu
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                },
                child: Text("Cancel"),
              ),
              // Nút Save để lưu thông tin nếu form hợp lệ
              TextButton(
                onPressed: () {
                  if (key.currentState?.validate() ?? false) {
                    key.currentState?.save(); // Lưu dữ liệu từ form
                    addTopic(topicName, isPublic); // Gọi hàm để thêm chủ đề
                    Navigator.of(context).pop(); // Đóng hộp thoại sau khi lưu
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
      context: context, // Ngữ cảnh ứng dụng
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content:
              Text("Are you sure you want to delete this folder?"), // Nội dung
          actions: [

            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Cancel"),
            ),
            // Nút xóa để xóa thư mục
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                deleteFolder(folder); // Gọi hàm xóa thư mục
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _renameFolderDialog(folder) {
    // Hiển thị hộp thoại đổi tên thư mục
    var key = GlobalKey<FormState>();
    var folderNameController =
        TextEditingController();
    String folderName = '';


    folderNameController.text = folder.folderName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Sử dụng StatefulBuilder để cập nhật trạng thái trong hộp thoại
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Rename Folder"), // Tiêu đề
            content: Form(
              key: key,
              child: TextFormField(
                controller: folderNameController, // Điều khiển text input
                decoration: InputDecoration(
                  labelText: 'Folder Name', // Nhãn
                  border: OutlineInputBorder(), // Đường viền
                ),
                validator: (value) {
                  // Xác thực: tên không được để trống
                  if (value == null || value.isEmpty) {
                    return 'Please enter folder name';
                  }
                  return null; // Hợp lệ nếu không có lỗi
                },
                onSaved: (value) {
                  folderName = value ?? ''; // Lưu giá trị
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
              // Nút Save để lưu thay đổi
              TextButton(
                onPressed: () {
                  if (key.currentState?.validate() ?? false) {
                    key.currentState?.save(); // Lưu dữ liệu từ form
                    renameFolder(folder, folderName); // Gọi hàm đổi tên
                    Navigator.of(context).pop(); // Đóng hộp thoại
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
    // Hiển thị hộp thoại thêm thư mục mới
    var key = GlobalKey<FormState>(); // Khóa trạng thái của form
    String folderName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text("Add New Folder"), // Tiêu đề
            content: Form(
              key: key,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Giới hạn chiều cao theo nội dung
                children: [
                  // Trường nhập liệu tên thư mục
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Folder Name', // Nhãn
                      border: OutlineInputBorder(), // Đường viền
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
              // Nút Cancel để đóng hộp thoại
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
                    Navigator.of(context).pop(); // Đóng hộp thoại
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
                folder(),
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
          padding: const EdgeInsets.all(
              30),
          child: Column(
            // Column sắp xếp các phần tử con theo chiều dọc.
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              TextField(
                // TextField dùng để nhập liệu tìm kiếm.
                decoration: InputDecoration(
                  // Thiết lập giao diện của TextField.
                  hintText:
                      'Search topic name', // Văn bản gợi ý cho người dùng.
                  prefixIcon: Icon(Icons
                      .search), // Thêm biểu tượng tìm kiếm vào bên trái ô nhập liệu.
                ),
                onChanged: (value) {
                  setState(() {
                    isSearching = value
                        .isNotEmpty;
                    searchTopics =
                        topics
                            .where((topic) => topic.topicName
                                .toLowerCase()
                                .contains(value
                                    .toLowerCase())) // So sánh không phân biệt hoa/thường.
                            .toList(); // Chuyển đổi kết quả thành danh sách.
                  });
                },
              ),
              SizedBox(height: 20), // Tạo khoảng cách giữa các widget.
              DropdownButton<String>(
                // DropdownButton để chọn bộ lọc.
                value: selectedFilter, // Giá trị của dropdown hiện tại.
                onChanged: (String? newValue) {
                  // Khi giá trị dropdown thay đổi, hàm onChanged sẽ được gọi.
                  setState(() {
                    // Cập nhật trạng thái của widget.
                    selectedFilter =
                        newValue!; // Cập nhật giá trị bộ lọc được chọn.
                  });
                },
                items: <String>[
                  // Danh sách các tùy chọn trong dropdown.
                  'Today',
                  'Yesterday',
                  'During 7 days',
                  'This Month',
                  'This Year',
                  'All'
                ].map<DropdownMenuItem<String>>((String value) {

                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Hiển thị mỗi giá trị trong dropdown.
                  );
                }).toList(),
              ),
              SizedBox(height: 20), // Khoảng cách giữa các widget.
              Stack(
                // Stack cho phép chồng các widget lên nhau.
                children: [
                  Opacity(

                    opacity: isSearching
                        ? 0.0
                        : 1.0,
                    child: buildTopicSections(
                        topics,
                        selectedFilter,
                        widget.username,
                        deleteTopic), // Truyền vào các tham số cần thiết.
                  ),
                  Opacity(
                    // Opacity giúp thay đổi độ mờ của widget khác.
                    opacity: isSearching
                        ? 1.0
                        : 0.0, // Nếu đang tìm kiếm thì hiển thị phần tìm kiếm.
                    child: buildSearchTopics(
                        // Xây dựng phần hiển thị các chủ đề tìm kiếm.
                        searchTopics,
                        widget.username,
                        deleteTopic),
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

  Widget folder() {
    return Scaffold(
      // Scaffold giúp tạo ra cấu trúc cơ bản cho màn hình.
      body: SingleChildScrollView(
        // SingleChildScrollView cho phép cuộn nội dung.
        child: Padding(
          // Padding giúp tạo khoảng cách giữa các phần tử.
          padding: const EdgeInsets.all(30),
          child: Column(
            // Column giúp sắp xếp các phần tử theo chiều dọc.
            crossAxisAlignment: CrossAxisAlignment
                .start, // Căn chỉnh các phần tử theo phía trái.
            children: [
              TextField(

                decoration: InputDecoration(
                  hintText:
                      'Search folder name', //
                  prefixIcon: Icon(
                      Icons.search),
                ),
                onChanged: (value) {

                  updateDisplayedFolders(
                      value);
                },
              ),
              SizedBox(height: 20),
              buildListFolder(

                displayedFolders,
                _renameFolderDialog,
                _confirmDeleteFolder,
                _addTopicDialog,
                widget.username,
                topics,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Nút để thêm thư mục mới.
        onPressed: _addFolderDialog, // Khi nhấn vào, mở hộp thoại thêm thư mục.
        child: Icon(Icons.add), // Biểu tượng dấu cộng trên nút.
      ),
    );
  }
}


Widget buildSearchTopics(topics, username, deleteTopic) {
  return topics.length > 0
      ? buildSection(
          'Result search',
          topics,
          username,
          deleteTopic,
        )
      : Center(
          child: Text(
              'No topic'));
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
    String section = getSectionsFromCreateAt(
        topic.createAt);
    categorizedTopics[section]?.add(topic);
  }


  bool isEmptyFilter = true;


  bool hasToday = false;
  bool hasYesterday = false;
  bool hasDuring7days = false;
  bool hasThisMonth = false;
  bool hasThisYear = false;
  bool hasAll = false;

  // Kiểm tra các điều kiện bộ lọc và đánh dấu các mục có topic
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

  // Nếu bộ lọc không có kết quả, hiển thị thông báo "No topic"
  if (isEmptyFilter) {
    return Center(
      child: Text('No topic'),
    );
  }


  return ListView(
    shrinkWrap: true,
    physics:
        NeverScrollableScrollPhysics(),
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
          title, // Tiêu đề của phần
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple, // Màu chữ
          ),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics:
            NeverScrollableScrollPhysics(), // Không thể cuộn ngoài danh sách này
        itemCount: topics.length, // Số lượng các topic trong phần
        itemBuilder: (context, index) {
          return TopicItem(
            isLibrary: true, // Cờ cho biết đây là thư viện topic
            topic: topics[index], // Topic cụ thể
            username: username, // Tên người dùng
            onDelete: deleteTopic, // Hàm xóa topic
          );
        },
      ),
    ],
  );
}

// Hàm này phân loại topic theo ngày tạo của nó: hôm nay, hôm qua, trong 7 ngày, tháng này, năm nay, hoặc những năm trước
String getSectionsFromCreateAt(createAt) {
  String yyMmDddd = createAt.split('T')[0]; // Lấy ngày từ timestamp
  int year = int.parse(yyMmDddd.split('-')[0]);
  int month = int.parse(yyMmDddd.split('-')[1]);
  int day = int.parse(yyMmDddd.split('-')[2]);

  DateTime now = DateTime.now(); // Lấy ngày giờ hiện tại

  if (year == now.year && month == now.month && day == now.day) {
    return 'Today'; // Nếu topic được tạo hôm nay
  } else if (year == now.year && month == now.month && day == now.day - 1) {
    return 'Yesterday'; // Nếu topic được tạo hôm qua
  } else if (year == now.year && month == now.month && day > now.day - 7) {
    return 'During 7 days'; // Nếu topic được tạo trong 7 ngày qua
  } else if (year == now.year && month == now.month) {
    return 'This Month'; // Nếu topic được tạo trong tháng này
  } else if (year == now.year) {
    return 'This Year'; // Nếu topic được tạo trong năm nay
  } else {
    return 'More This Year'; // Nếu topic được tạo trước năm nay
  }
}

// Widget để xây dựng danh sách các thư mục. Hiển thị thông báo nếu không có thư mục nào
Widget buildListFolder(List<Folder> folders, Function renameFolderDialog,
    Function confirmDeleteFolder, Function addTopicDialog, username, topics) {
  return (folders.isNotEmpty)
      ? ListView.builder(
          shrinkWrap: true,
          physics:
              NeverScrollableScrollPhysics(), // Không thể cuộn ngoài danh sách này
          itemCount: folders.length, // Số lượng thư mục
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
                    color: Colors.yellow, // Màu icon thư mục
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          renameFolderDialog(
                              folder); // Mở hộp thoại đổi tên thư mục
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          confirmDeleteFolder(
                              folder); // Mở hộp thoại xác nhận xóa thư mục
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                  title: Text(
                    folder.folderName, // Tên thư mục
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
          child: Center(
            child: Text(
                'No folder'), // Nếu không có thư mục, hiển thị thông báo "No folder"
          ),
        );
}
