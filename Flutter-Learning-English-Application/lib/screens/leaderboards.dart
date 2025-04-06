import 'package:application_learning_english/models/achievement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:application_learning_english/config.dart';
import "package:shared_preferences/shared_preferences.dart";
import '../utils/session_user.dart';

import '../user.dart';

// Widget chính hiển thị bảng xếp hạng
class LeaderBoards extends StatefulWidget {
  const LeaderBoards({super.key});

  @override
  State<LeaderBoards> createState() => _LeaderBoardsState();
}

// State của widget LeaderBoards
class _LeaderBoardsState extends State<LeaderBoards> {
  final urlRoot = kIsWeb ? webURL : androidURL; // Chọn URL phù hợp dựa trên nền tảng (web hoặc Android)
  Future<List<Achievement>>? futureAchievement; // Biến lưu trữ danh sách thành tích dưới dạng Future
  late SharedPreferences prefs; // Biến lưu trữ SharedPreferences để quản lý dữ liệu cục bộ
  User? user; // Biến lưu thông tin người dùng hiện tại

  @override
  void initState() {
    super.initState();
    loadUser(); // Gọi hàm loadUser để tải thông tin người dùng
  }

  // Hàm tải thông tin người dùng từ dữ liệu phiên
  loadUser() async {
    user = await getUserData(); // Lấy dữ liệu người dùng từ session
    if (user != null) {
      futureAchievement = fetchAchievement(); // Gọi hàm fetchAchievement nếu người dùng đã đăng nhập
    }
    setState(() {}); // Cập nhật giao diện
  }

  // Hàm gọi API để lấy danh sách thành tích
  Future<List<Achievement>> fetchAchievement() async {
    final response = await http.get(Uri.parse(
        '$urlRoot/achievements/personal-achivements/${user!.username}')); // API lấy thành tích cá nhân
    if (response.statusCode == 200) {
      // Nếu API trả về thành công
      final Map<String, dynamic> responseBody = jsonDecode(response.body); // Giải mã JSON
      final List<dynamic> achievementJson = responseBody['data']; // Trích xuất dữ liệu từ trường 'data'
      return achievementJson.map((json) => Achievement.fromJson(json)).toList(); // Chuyển dữ liệu JSON thành danh sách đối tượng Achievement
    } else {
      throw Exception('Failed to load topics'); // Ném ngoại lệ nếu API thất bại
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white, // Màu nền AppBar
        centerTitle: true,
        title: Text(
          'Achievement',
          style: TextStyle(color: Colors.black, fontSize: 17), // Tiêu đề AppBar
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Achievement>>(
          future: futureAchievement, // Chờ dữ liệu Future từ fetchAchievement
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Nếu có dữ liệu
              List<Achievement> achievements = snapshot.data!; // Lấy danh sách thành tích
              return ListView.builder(
                scrollDirection: Axis.vertical, // Cuộn theo chiều dọc
                itemCount: achievements.length, // Số lượng thành tích
                itemBuilder: (context, index) {
                  Achievement achievement = achievements[index]; // Thành tích tại vị trí index
                  return GestureDetector(
                    onTap: () async {
                      // Hiển thị chi tiết thành tích khi nhấn vào item
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min, // Giới hạn kích thước cột
                            children: [
                              Text(
                                achievement.topic.topicName, // Tên chủ đề
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Rank: ${achievement.rank}', // Hạng của thành tích
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Category: ${achievement.category}', // Loại thành tích
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                              SizedBox(height: 10),
                              _buildCategoryText(
                                  achievement.category, achievement.achievement), // Hiển thị giá trị thành tích
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), // Đóng dialog
                              child: Text(
                                'Close',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10, left: 10, top: 5), // Khoảng cách giữa các item
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}', // Số thứ tự
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ),
                          SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100), // Bo góc hình ảnh
                            child: Image.asset(
                              'assets/cup.png', // Ảnh minh họa
                              height: 60,
                              width: 60,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.topic.topicName, // Tên chủ đề
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 17),
                                ),
                                Text(
                                  'Rank: ${achievement.rank}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  'Category: ${achievement.category}', // Loại thành tích
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 7),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildCategoryText(
                              achievement.category,
                              achievement.achievement,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              // Nếu có lỗi
              return Center(
                child: Text("${snapshot.error}"), // Hiển thị lỗi
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

// Hàm hiển thị giá trị thành tích theo loại
Widget _buildCategoryText(String category, String achievement) {
  if (category == 'duration') {
    return Text(
      '$achievement seconds', // Nếu loại là 'duration', hiển thị số giây
      style: TextStyle(color: Colors.black, fontSize: 17),
    );
  } else if (category == 'corrects') {
    return Text(
      '$achievement/5', // Nếu loại là 'corrects', hiển thị số đúng trên tổng số
      style: TextStyle(color: Colors.black, fontSize: 17),
    );
  } else {
    return Text(
      '$achievement ', // Loại khác, hiển thị trực tiếp giá trị
      style: TextStyle(color: Colors.black, fontSize: 17),
    );
  }
}
