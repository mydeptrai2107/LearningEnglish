
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
      prefs;
  User?
      user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }


  loadUser() async {
    user =
        await getUserData();
    setState(() {});
  }

  // Hàm đăng xuất người dùng
  void logOutUser() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Lấy instance của SharedPreferences
    await prefs
        .remove('token');
    Navigator.pushReplacement(

      context,
      MaterialPageRoute(
        builder: (context) => MyLogin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        // AppBar để hiển thị thanh tiêu đề
        automaticallyImplyLeading: false,
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        // Cho phép cuộn màn hình nếu nội dung dài
        child: Padding(
          padding: const EdgeInsets.all(
              30),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment
                .start,
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

                  children: [
                    Image.asset("assets/avatar.png",
                        width: 70, height: 70), // Ảnh đại diện
                    const SizedBox(
                        width:
                            20),
                    if (user !=
                        null) // Kiểm tra xem dữ liệu người dùng đã có chưa
                      Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ??
                                'Username',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user?.username ??
                                "Email not available",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    else
                      const CircularProgressIndicator(),
                    const Spacer(),
                    ForwardButton(

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
