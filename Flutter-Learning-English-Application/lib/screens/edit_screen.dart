import 'dart:convert'; // Thư viện để chuyển đổi đối tượng JSON thành các đối tượng Dart và ngược lại
import 'package:flutter/material.dart'; // Thư viện Flutter cho giao diện người dùng
import 'package:ionicons/ionicons.dart'; // Thư viện để sử dụng các biểu tượng Ionicons
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện để lưu trữ dữ liệu nhỏ gọn trên thiết bị người dùng

import '../user.dart'; // Import lớp User từ tệp khác để sử dụng thông tin người dùng
import '../widgets/edit_item.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen(
      {super.key});

  @override
  State<EditAccountScreen> createState() =>
      _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender =
      "man";
  late TextEditingController _nameController;
  late TextEditingController
      _usernameController;
  late TextEditingController _emailController;

  late SharedPreferences prefs;
  User? user;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    getUserData();
  }


  void getUserData() async {
    prefs = await SharedPreferences
        .getInstance();
    String? userJson = prefs
        .getString('user');
    if (userJson != null) {

      Map<String, dynamic> userMap =
          jsonDecode(userJson);
      setState(() {
        user = User.fromJson(userMap);
        _nameController.text =
            user!.fullName;
        _usernameController.text =
            user!.username;
        _emailController.text = user!.email;

      });
    }
  }


  void saveUserData() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold tạo cấu trúc cơ bản của màn hình
      appBar: AppBar(
        // AppBar tạo thanh tiêu đề cho màn hình
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
                context); // Quay lại màn hình trước đó khi nhấn nút quay lại
          },
          icon:
              const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 10),
            child: IconButton(
              onPressed:
                  saveUserData,
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent, // Màu nền cho nút
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Đặt góc bo tròn cho nút
                ),
                fixedSize: Size(60, 50), // Kích thước cố định cho nút
                elevation: 3, // Đặt độ dày bóng cho nút
              ),
              icon: const Icon(Ionicons.checkmark,
                  color: Colors.white), // Biểu tượng xác nhận
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Cho phép cuộn màn hình nếu nội dung dài
        child: Padding(
          padding: const EdgeInsets.all(
              30), // Khoảng cách giữa các phần tử và viền màn hình
          child: Column(
            // Sắp xếp các phần tử theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment
                .start, // Căn trái cho các phần tử trong Column
            children: [
              const Text(
                "Account", // Tiêu đề "Account"
                style: TextStyle(
                  fontSize: 36, // Cỡ chữ lớn
                  fontWeight: FontWeight.bold, // Đậm
                ),
              ),
              const SizedBox(height: 40), // Khoảng cách giữa các phần tử
              EditItem(
                // Sử dụng widget EditItem để hiển thị trường "Photo"
                title: "Photo",
                widget: Column(
                  children: [
                    Image.asset(
                      "assets/avatar.png", // Hình ảnh mặc định của người dùng
                      height: 100, // Chiều cao của ảnh
                      width: 100, // Chiều rộng của ảnh
                    ),
                    TextButton(
                      // Nút tải lên ảnh
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Colors.lightBlueAccent, // Màu sắc cho chữ của nút
                      ),
                      child: const Text("Upload Image"), // Chữ trên nút
                    ),
                  ],
                ),
              ),
              EditItem(
                // Trường "Name" để nhập tên người dùng
                title: "Name",
                widget: TextField(
                  controller:
                      _nameController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(

                title: "Username",
                widget: TextField(
                  controller: _usernameController,
                  readOnly: true, // Chỉ đọc, không thể chỉnh sửa
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                // Trường "Email", chỉ đọc (không thể chỉnh sửa)
                title: "Email",
                widget: TextField(
                  controller: _emailController,
                  readOnly: true, // Chỉ đọc, không thể chỉnh sửa
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
