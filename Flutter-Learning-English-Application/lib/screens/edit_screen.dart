import 'dart:convert'; // Thư viện để chuyển đổi đối tượng JSON thành các đối tượng Dart và ngược lại
import 'package:flutter/material.dart'; // Thư viện Flutter cho giao diện người dùng
import 'package:ionicons/ionicons.dart'; // Thư viện để sử dụng các biểu tượng Ionicons
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện để lưu trữ dữ liệu nhỏ gọn trên thiết bị người dùng

import '../user.dart'; // Import lớp User từ tệp khác để sử dụng thông tin người dùng
import '../widgets/edit_item.dart'; // Import widget EditItem để tái sử dụng các mục chỉnh sửa trong giao diện

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen(
      {super.key}); // Khai báo widget chính của màn hình chỉnh sửa tài khoản

  @override
  State<EditAccountScreen> createState() =>
      _EditAccountScreenState(); // Tạo trạng thái cho màn hình chỉnh sửa tài khoản
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender =
      "man"; // Biến để lưu giới tính của người dùng (mặc định là "man")
  late TextEditingController _nameController; // Controller cho trường "Tên"
  late TextEditingController
      _usernameController; // Controller cho trường "Tên đăng nhập"
  late TextEditingController _emailController; // Controller cho trường "Email"

  late SharedPreferences prefs; // Khai báo biến để sử dụng SharedPreferences
  User? user; // Biến lưu thông tin người dùng (dạng đối tượng User)

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller cho các trường nhập liệu
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    getUserData(); // Gọi hàm lấy thông tin người dùng khi màn hình được khởi tạo
  }

  // Hàm lấy thông tin người dùng từ SharedPreferences (hoặc nguồn lưu trữ)
  void getUserData() async {
    prefs = await SharedPreferences
        .getInstance(); // Lấy instance của SharedPreferences
    String? userJson = prefs
        .getString('user'); // Lấy chuỗi JSON đã lưu trong SharedPreferences
    if (userJson != null) {
      // Kiểm tra nếu có thông tin người dùng
      Map<String, dynamic> userMap =
          jsonDecode(userJson); // Chuyển chuỗi JSON thành Map
      setState(() {
        user = User.fromJson(userMap); // Chuyển Map thành đối tượng User
        _nameController.text =
            user!.fullName; // Đặt giá trị trường "Tên" từ đối tượng người dùng
        _usernameController.text =
            user!.username; // Đặt giá trị trường "Tên đăng nhập"
        _emailController.text = user!.email; // Đặt giá trị trường "Email"
        // gender = user!.gender; // Có thể thêm chức năng lưu giới tính người dùng (được bỏ qua ở đây)
      });
    }
  }

  // Hàm lưu thông tin người dùng đã chỉnh sửa (hiện tại chưa được triển khai đầy đủ)
  void saveUserData() async {
    // if (user != null) {
    //   user.fullName = _nameController.text; // Cập nhật lại tên người dùng từ trường nhập liệu
    //   // user!.age = int.tryParse(_ageController.text) ?? user!.age; // Cập nhật tuổi (chưa triển khai)
    //   user!.email = _emailController.text; // Cập nhật email người dùng
    //   // user!.gender = gender; // Cập nhật giới tính (có thể triển khai thêm)
    //
    //   String userJson = jsonEncode(user!.toJson()); // Chuyển đối tượng người dùng thành chuỗi JSON
    //   await prefs.setString('user', userJson); // Lưu chuỗi JSON vào SharedPreferences
    //   Navigator.pop(context); // Trở lại màn hình trước đó
    // }
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
              const Icon(Ionicons.chevron_back_outline), // Biểu tượng quay lại
        ),
        leadingWidth: 80, // Đặt chiều rộng cho nút quay lại
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 10), // Khoảng cách phải cho biểu tượng xác nhận
            child: IconButton(
              onPressed:
                  saveUserData, // Gọi hàm lưu thông tin người dùng khi nhấn nút lưu
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
                      _nameController, // Controller để quản lý trường "Name"
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                // Trường "Username", chỉ đọc (không thể chỉnh sửa)
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
