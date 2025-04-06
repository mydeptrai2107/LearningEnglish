import 'dart:convert'; // Thư viện giúp mã hóa và giải mã dữ liệu JSON
import 'package:application_learning_english/forgot_password.dart'; // Import trang quên mật khẩu
import 'registration.dart'; // Import trang đăng ký
import 'package:application_learning_english/toastify/account.dart'; // Import thư viện hiển thị toast thông báo
import 'package:flutter/foundation.dart'; // Thư viện hỗ trợ xác định nền tảng đang chạy (Web, Android, iOS)
import 'package:flutter/material.dart'; // Thư viện chính của Flutter cho giao diện người dùng
import 'package:http/http.dart' as http; // Thư viện hỗ trợ gửi yêu cầu HTTP
import 'config.dart'; // Thư viện chứa các cấu hình URL cho Web và Android
import 'home_page.dart'; // Import trang chính sau khi đăng nhập
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện dùng để lưu trữ dữ liệu cục bộ (local storage)
import 'loading_overlay.dart'; // Thư viện hiển thị overlay loading khi xử lý
import 'user.dart'; // Lớp người dùng, chứa thông tin của người dùng


class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() =>
      _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final urlRoot = kIsWeb
      ? webURL
      : androidURL;

  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false; // Biến kiểm tra trạng thái loading
  late SharedPreferences
      prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref(); // Khởi tạo SharedPreferences
  }


  void initSharedPref() async {
    prefs = await SharedPreferences
        .getInstance(); // Lấy đối tượng SharedPreferences
    String? userJson =
        prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      User user = User.fromJson(userMap);
      setState(() {
        emailController.text =
            user.email;
      });
    }
  }

  // Hàm đăng nhập người dùng
  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // Kiểm tra xem email và mật khẩu có trống không
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqBody = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      // Gửi yêu cầu đăng nhập đến server
      var res = await http.post(
        Uri.parse('$urlRoot/accounts/login'), // URL đăng nhập
        headers: {'Content-Type': 'application/json'}, // Đặt header là JSON
        body: jsonEncode(reqBody), // Mã hóa body request
      );

      var jsonResponse = jsonDecode(res.body); // Giải mã phản hồi từ server
      setState(() {
        _isLoading = false; // Tắt trạng thái loading sau khi có phản hồi
      });

      // Kiểm tra nếu đăng nhập thành công
      if (jsonResponse['code'] == 0) {
        var myToken = jsonResponse['data']['token']; // Lấy token từ phản hồi
        prefs.setString('token', myToken); // Lưu token vào SharedPreferences

        // Tạo đối tượng User từ dữ liệu phản hồi
        User user = User(
          uid: jsonResponse['data']['_id'],
          username: jsonResponse['data']['fullName'] ?? '',
          fullName: jsonResponse['data']['fullName'],
          email: jsonResponse['data']['email'],
          avatar: jsonResponse['data']['avatar_url'] ??
              'https://firebasestorage.googleapis.com/v0/b/phone-c4bc5.appspot.com/o/default_avatar.jpg?alt=media&token=0ff85744-9209-457b-aaf8-66d1f6893155', // URL avatar mặc định nếu không có
        );

        // Lưu thông tin người dùng vào SharedPreferences
        String userJson = jsonEncode(user.toJson());
        await prefs.setString('user', userJson);

        // Chuyển đến màn hình chính (HomeScreen)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        // Nếu đăng nhập thất bại, hiển thị thông báo lỗi
        showErrorToast(
          context: context,
          title: 'Login fail',
          description: 'Password is not correct!',
        );
      }
    } else {
      setState(() {
        _isNotValidate =
            true; // Đánh dấu form không hợp lệ nếu trường nhập trống
        _isLoading = false;
      });
    }
  }

  // Giao diện của màn hình đăng nhập
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/login.png'),
            fit: BoxFit.cover), // Đặt hình nền cho màn hình đăng nhập
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Màu nền trong suốt
        body: LoadingOverlay(
          isLoading: _isLoading, // Trạng thái hiển thị overlay loading
          child: Stack(
            children: [
              Container(), // Khung trống
              Container(
                padding: EdgeInsets.only(
                    left: 35, top: 130), // Khoảng cách từ cạnh trái và trên
                child: Text(
                  'Welcome\nBack', // Tiêu đề màn hình đăng nhập
                  style: TextStyle(
                      color: Colors.white, fontSize: 33), // Cỡ chữ và màu sắc
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height *
                          0.5), // Căn chỉnh lại phần nhập liệu
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: 35, right: 35), // Đặt lề cho khung nhập liệu
                        child: Column(
                          children: [
                            // Trường nhập email
                            TextField(
                              controller: emailController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  errorStyle: TextStyle(color: Colors.black),
                                  errorText: _isNotValidate
                                      ? "Enter your email" // Hiển thị lỗi nếu email trống
                                      : null,
                                  hintText: "Email", // Gợi ý cho trường nhập
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                                height:
                                    30), // Khoảng cách giữa các trường nhập liệu
                            // Trường nhập mật khẩu
                            TextField(
                              controller: passwordController,
                              style: TextStyle(),
                              obscureText: true, // Ẩn mật khẩu
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  errorStyle: TextStyle(color: Colors.black),
                                  errorText: _isNotValidate
                                      ? "Enter your password" // Hiển thị lỗi nếu mật khẩu trống
                                      : null,
                                  hintText: "Password", // Gợi ý cho trường nhập
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                                height: 40), // Khoảng cách dưới trường mật khẩu
                            // Nút đăng nhập
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700),
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xff4c505b),
                                  child: IconButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        loginUser(); // Gọi hàm loginUser khi nhấn nút đăng nhập
                                      },
                                      icon: Icon(Icons.arrow_forward)),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            // Nút đăng ký và quên mật khẩu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Chưa có tài khoản',
                                  style: TextStyle(
                                    color: Color(0xff4c505b),
                                    fontSize: 18,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyRegister(),
                                      ),
                                    ); // Chuyển đến màn hình đăng ký
                                  },
                                  style: ButtonStyle(),
                                  child: Text(
                                    'Sign Up',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xff4c505b),
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
