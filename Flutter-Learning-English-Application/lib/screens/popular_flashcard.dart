import 'dart:convert';
import 'package:application_learning_english/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:application_learning_english/widgets/topic_achi.dart';

import '../models/topic.dart';

class PopularFlashcard extends StatefulWidget {
  const PopularFlashcard({super.key});

  @override
  State<PopularFlashcard> createState() => _PopularFlashcardState();
}

class _PopularFlashcardState extends State<PopularFlashcard> {
  final urlRoot = kIsWeb ? webURL : androidURL;

  List<Topic> topics = [];
  List<Topic> searchTopics = [];
  String selectedFilter = 'This Month';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    try {
      var response = await http.get(Uri.parse('$urlRoot/topics/public'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          topics = (data['listTopic'] as List)
              .map((json) => Topic.fromJson(json))
              .toList();
        });
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Popular topic'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle adding new items
            },
          ),
        ],
      ),
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
                      child: buildTopicSections(topics, selectedFilter)),
                  Opacity(
                    opacity: isSearching ? 1.0 : 0.0,
                    child: buildSearchTopics(searchTopics),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget để hiển thị kết quả tìm kiếm cho các chủ đề
Widget buildSearchTopics(topics) {
  // Kiểm tra xem có chủ đề nào trong danh sách không
  return topics.length > 0
      ? buildSection(
          'Result search', topics) // Nếu có chủ đề, tạo phần hiển thị chủ đề
      : Center(
          child: Text(
              'No topic'), // Nếu không có chủ đề, hiển thị thông báo "Không có chủ đề"
        );
}

// Widget để phân loại và hiển thị các chủ đề theo bộ lọc (như Hôm nay, Hôm qua, v.v.)
Widget buildTopicSections(topics, selectedFilter) {
  // Tạo một map để phân loại các chủ đề theo các khoảng thời gian khác nhau
  Map<String, List<Topic>> categorizedTopics = {
    'Today': [],
    'Yesterday': [],
    'During 7 days': [],
    'This Month': [],
    'This Year': [],
    'More This Year': [],
  };

  // Phân loại các chủ đề theo ngày tạo của chúng
  for (var topic in topics) {
    String section = getSectionsFromCreateAt(
        topic.createAt); // Lấy phần loại (Hôm nay, Hôm qua, v.v.)
    categorizedTopics[section]?.add(topic); // Thêm chủ đề vào phần tương ứng
  }

  // Cờ để theo dõi các phần nào cần hiển thị dựa trên bộ lọc đã chọn
  bool isEmptyFilter = true;

  bool hasToday = false;
  bool hasYesterday = false;
  bool hasDuring7days = false;
  bool hasThisMonth = false;
  bool hasThisYear = false;
  bool hasAll = false;

  // Kiểm tra xem các phần có chứa chủ đề và nếu chúng phù hợp với bộ lọc đã chọn
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

  // Nếu không có phần nào khớp với bộ lọc, hiển thị thông báo
  if (isEmptyFilter) {
    return Center(
      child: Text(
          'No topic'), // Nếu không có chủ đề nào khớp bộ lọc, hiển thị "Không có chủ đề"
    );
  }

  // Trả về ListView chứa các phần được lọc
  return ListView(
    shrinkWrap: true, // Để tránh cuộn khi nằm trong widget có thể cuộn được
    physics:
        NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn cho ListView này
    children: [
      // Thêm các phần vào ListView nếu cờ tương ứng là true
      if (hasToday) buildSection('Today', categorizedTopics['Today']!),
      if (hasYesterday)
        buildSection('Yesterday', categorizedTopics['Yesterday']!),
      if (hasDuring7days)
        buildSection('During 7 days', categorizedTopics['During 7 days']!),
      if (hasThisMonth)
        buildSection('This Month', categorizedTopics['This Month']!),
      if (hasThisYear)
        buildSection('This Year', categorizedTopics['This Year']!),
      if (hasAll)
        buildSection('More This Year', categorizedTopics['More This Year']!),
    ],
  );
}

// Widget giúp tạo phần với tiêu đề và danh sách chủ đề
Widget buildSection(String title, List<Topic> topics) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title, // Tiêu đề của phần (ví dụ: "Today", "Yesterday")
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
      ),
      // Tạo ListView cho các chủ đề trong phần
      ListView.builder(
        shrinkWrap: true, // Ngăn ListView chiếm không gian quá lớn
        physics:
            NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn cho ListView này
        itemCount: topics.length, // Số lượng chủ đề trong phần
        itemBuilder: (context, index) {
          return TopicItem(
            topic: topics[index], // Hiển thị từng chủ đề bằng widget TopicItem
          );
        },
      ),
    ],
  );
}

// Hàm phân loại chủ đề theo ngày tạo
String getSectionsFromCreateAt(createAt) {
  String yyMmDddd =
      createAt.split('T')[0]; // Lấy phần ngày (ví dụ: "2022-09-30")
  int year = int.parse(yyMmDddd.split('-')[0]);
  int month = int.parse(yyMmDddd.split('-')[1]);
  int day = int.parse(yyMmDddd.split('-')[2]);

  DateTime now = DateTime.now();

  // Trả về phần loại tương ứng dựa trên việc so sánh với ngày hiện tại
  if (year == now.year && month == now.month && day == now.day) {
    return 'Today'; // Chủ đề được tạo hôm nay
  } else if (year == now.year && month == now.month && day == now.day - 1) {
    return 'Yesterday'; // Chủ đề được tạo hôm qua
  } else if (year == now.year && month == now.month && day > now.day - 7) {
    return 'During 7 days'; // Chủ đề được tạo trong 7 ngày qua
  } else if (year == now.year && month == now.month) {
    return 'This Month'; // Chủ đề được tạo trong tháng này
  } else if (year == now.year) {
    return 'This Year'; // Chủ đề được tạo trong năm nay
  } else {
    return 'More This Year'; // Chủ đề được tạo trước năm nay
  }
}
