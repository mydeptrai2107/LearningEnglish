import 'dart:convert';

// Import các thư viện cần thiết, bao gồm các thư viện cho giao diện người dùng, lưu trữ dữ liệu, HTTP và các tiện ích khác.
import 'package:application_learning_english/loading_overlay.dart';
import 'package:application_learning_english/toastify/account.dart';
import 'package:application_learning_english/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:application_learning_english/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// StatefulWidget để thay đổi mật khẩu, vì giao diện sẽ có sự thay đổi trạng thái trong quá trình người dùng tương tác.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Cấu hình URL cho Web và Android, sử dụng kIsWeb để xác định nền tảng.
  final urlRoot = kIsWeb ? webURL : androidURL;

  // Controllers để điều khiển các trường nhập liệu cho mật khẩu hiện tại, mật khẩu mới và xác nhận mật khẩu mới.
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // SharedPreferences để lưu trữ thông tin người dùng.
  late SharedPreferences prefs;
  bool _isNotValidate =
      false; // Cờ để xác định nếu có lỗi trong việc nhập mật khẩu.
  late User user; // Lưu trữ thông tin người dùng.
  bool isLoading = false; // Cờ để xác định trạng thái loading (đang tải).

  // Khởi tạo dữ liệu người dùng khi màn hình được tạo.
  @override
  void initState() {
    super.initState();
    initGetDataUser();
  }

  // Hàm để lấy dữ liệu người dùng từ SharedPreferences và giải mã nó.
  void initGetDataUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap =
          jsonDecode(userJson); // Giải mã chuỗi JSON thành bản đồ.
      user = User.fromJson(userMap); // Chuyển bản đồ thành đối tượng User.
    }
  }

  // Hàm thay đổi mật khẩu, gọi API để thực hiện thay đổi mật khẩu.
  void changePassword() async {
    // Kiểm tra nếu các trường nhập liệu không rỗng.
    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      // Kiểm tra xem mật khẩu mới và xác nhận mật khẩu mới có khớp không.
      if (_newPasswordController.text == _confirmPasswordController.text) {
        setState(() {
          isLoading = true; // Bật trạng thái loading khi bắt đầu gửi yêu cầu.
        });

        // Tạo thân yêu cầu với các thông tin cần thiết (ID người dùng và mật khẩu).
        var reqBody = {
          '_id': user.uid,
          'oldPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text
        };

        // Gửi yêu cầu POST đến API để thay đổi mật khẩu.
        var res = await http.post(Uri.parse('$urlRoot/accounts/changePassword'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reqBody)); // Chuyển dữ liệu thành chuỗi JSON.

        var jsonResponse = jsonDecode(res.body); // Giải mã phản hồi từ server.

        setState(() {
          isLoading = false; // Tắt trạng thái loading khi hoàn tất yêu cầu.
        });

        // Kiểm tra mã phản hồi từ server.
        if (jsonResponse['code'] == 0) {
          showSuccessToast(
              context: context,
              title: 'Success',
              description: 'Change password successfully!');
          Navigator.pop(context); // Quay lại màn hình trước đó.
        } else {
          showErrorToast(
              context: context,
              title: 'Error',
              description: jsonResponse['message']);
        }
      } else {
        // Nếu mật khẩu mới và mật khẩu xác nhận không khớp.
        showErrorToast(
            context: context,
            title: 'Error',
            description: 'Password and confirm password not match!');
      }
    } else {
      setState(() {
        _isNotValidate =
            true; // Đánh dấu có lỗi khi các trường nhập liệu còn trống.
        isLoading = false; // Tắt trạng thái loading nếu có lỗi.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
                context); // Quay lại màn hình trước đó khi nhấn vào nút quay lại.
          },
          icon:
              const Icon(Ionicons.chevron_back_outline), // Biểu tượng quay lại.
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                changePassword(); // Gọi hàm thay đổi mật khẩu khi nhấn nút "Check".
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent, // Màu nền của nút.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Định dạng góc nút.
                ),
                fixedSize: Size(60, 50), // Kích thước nút.
                elevation: 3, // Độ cao bóng đổ.
              ),
              icon: Icon(Ionicons.checkmark,
                  color: Colors.white), // Biểu tượng "Check" màu trắng.
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading, // Hiển thị overlay khi đang tải.
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Các trường nhập liệu cho mật khẩu hiện tại, mật khẩu mới và xác nhận mật khẩu.
                EditItem(
                  title: "Current Password",
                  widget: TextField(
                    controller: _currentPasswordController,
                    obscureText: true, // Ẩn mật khẩu khi nhập.
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Current Password',
                      errorStyle: TextStyle(color: Colors.red),
                      errorText:
                          _isNotValidate ? "Enter current password" : null,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                EditItem(
                  title: "New Password",
                  widget: TextField(
                    controller: _newPasswordController,
                    obscureText: true, // Ẩn mật khẩu khi nhập.
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Password',
                      errorStyle: TextStyle(color: Colors.red),
                      errorText: _isNotValidate ? "Enter new password" : null,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                EditItem(
                  title: "Confirm New Password",
                  widget: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true, // Ẩn mật khẩu khi nhập.
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm New Password',
                      errorStyle: TextStyle(color: Colors.red),
                      errorText:
                          _isNotValidate ? "Enter confirm new password" : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng bộ điều khiển khi không còn sử dụng.
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Widget con EditItem dùng để hiển thị mỗi trường nhập liệu.
class EditItem extends StatelessWidget {
  final String title; // Tiêu đề của trường nhập liệu.
  final Widget widget; // Widget nhập liệu (ví dụ: TextField).

  const EditItem({
    required this.title,
    required this.widget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        widget, // Hiển thị widget nhập liệu.
      ],
    );
  }
}
