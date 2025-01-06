// Các thư viện cần thiết được import vào, bao gồm các widget, màn hình và tiện ích để quản lý tài khoản người dùng.
import 'package:application_learning_english/login_page.dart';
import 'package:application_learning_english/screens/change_password_screen.dart';
import 'package:application_learning_english/screens/edit_screen.dart';
import 'package:application_learning_english/screens/leaderboards.dart';
import 'package:application_learning_english/user.dart';
import 'package:application_learning_english/widgets/forward_button.dart';
import 'package:application_learning_english/widgets/setting_item.dart';
import 'package:application_learning_english/widgets/setting_logout.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/session_user.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late SharedPreferences
      prefs; // Khai báo biến để lưu trữ thông tin trong SharedPreferences
  User?
      user; // Biến chứa thông tin người dùng (User) sau khi tải từ session hoặc API

  @override
  void initState() {
    super.initState();
    loadUser(); // Gọi hàm loadUser để tải thông tin người dùng khi màn hình được khởi tạo
  }

  // Hàm tải thông tin người dùng từ session hoặc nguồn dữ liệu
  loadUser() async {
    user =
        await getUserData(); // Lấy dữ liệu người dùng (có thể từ SharedPreferences hoặc API)
    setState(() {}); // Cập nhật lại giao diện khi có dữ liệu người dùng
  }

  // Hàm đăng xuất người dùng
  void logOutUser() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Lấy instance của SharedPreferences
    await prefs
        .remove('token'); // Xóa token đăng nhập (để đăng xuất người dùng)
    Navigator.pushReplacement(
      // Chuyển hướng người dùng về màn hình đăng nhập
      context,
      MaterialPageRoute(
        builder: (context) => MyLogin(), // Màn hình đăng nhập
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold tạo cấu trúc cơ bản của màn hình
      appBar: AppBar(
        // AppBar để hiển thị thanh tiêu đề
        automaticallyImplyLeading: false, // Tắt hành động quay lại mặc định
        leadingWidth: 80, // Đặt chiều rộng cho nút điều hướng quay lại
      ),
      body: SingleChildScrollView(
        // Cho phép cuộn màn hình nếu nội dung dài
        child: Padding(
          padding: const EdgeInsets.all(
              30), // Thêm khoảng cách xung quanh các phần tử
          child: Column(
            // Sử dụng Column để sắp xếp các phần tử theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment
                .start, // Căn trái cho các phần tử trong Column
            children: [
              const Text(
                // Tiêu đề "Profile"
                "Profile",
                style: TextStyle(
                  fontSize: 36, // Cỡ chữ lớn
                  fontWeight: FontWeight.bold, // Đậm
                ),
              ),
              const SizedBox(height: 40), // Khoảng cách giữa các phần tử
              const Text(
                // Tiêu đề "Account"
                "Account",
                style: TextStyle(
                  fontSize: 24, // Cỡ chữ vừa
                  fontWeight: FontWeight.w500, // Độ đậm vừa phải
                ),
              ),
              const SizedBox(height: 20), // Khoảng cách giữa các phần tử
              SizedBox(
                // Phần này để hiển thị ảnh đại diện và thông tin người dùng
                width: double.infinity, // Chiếm toàn bộ chiều rộng
                child: Row(
                  // Dùng Row để sắp xếp các phần tử theo chiều ngang
                  children: [
                    Image.asset("assets/avatar.png",
                        width: 70, height: 70), // Ảnh đại diện
                    const SizedBox(
                        width:
                            20), // Khoảng cách giữa ảnh và thông tin người dùng
                    if (user !=
                        null) // Kiểm tra xem dữ liệu người dùng đã có chưa
                      Column(
                        // Hiển thị thông tin người dùng (Tên và tên đăng nhập)
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ??
                                'Username', // Hiển thị tên đầy đủ hoặc 'Username' nếu không có dữ liệu
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user?.username ??
                                "Email not available", // Hiển thị tên đăng nhập hoặc 'Email not available'
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    else
                      const CircularProgressIndicator(), // Hiển thị vòng xoay chờ khi dữ liệu người dùng chưa được tải
                    const Spacer(), // Dùng Spacer để tạo khoảng trống giữa thông tin người dùng và nút chỉnh sửa
                    ForwardButton(
                      // Nút chuyển đến màn hình chỉnh sửa thông tin tài khoản
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                // Tiêu đề "Settings"
                "Settings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SettingItem(
                // Mục "Achievement" để chuyển đến màn hình thành tích
                title: "Achievement",
                icon: Ionicons.medal,
                bgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaderBoards(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                // Mục "Change Password" để chuyển đến màn hình thay đổi mật khẩu
                title: "Change Password",
                icon: Ionicons.key,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                // Mục "About", hiện tại không làm gì
                title: "About",
                icon: Ionicons.earth,
                bgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingLogout(
                // Mục "Log out" để đăng xuất người dùng
                title: "Log out",
                icon: Ionicons.log_out,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: logOutUser, // Gọi hàm đăng xuất
              ),
            ],
          ),
        ),
      ),
    );
  }
}
