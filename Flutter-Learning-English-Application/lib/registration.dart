import 'dart:convert';
import 'package:application_learning_english/login_page.dart';
import 'package:application_learning_english/toastify/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'loading_overlay.dart'; // Import the LoadingOverlay widget

class MyRegister extends StatefulWidget {
  const MyRegister({super.key});

  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  // Khởi tạo URL dựa trên nền tảng (Web hay Android)
  final urlRoot = kIsWeb ? webURL : androidURL;

// Khai báo các TextEditingController để quản lý thông tin người dùng nhập vào
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

// Biến để kiểm tra trạng thái hợp lệ của dữ liệu và trạng thái loading
  bool _isNotValite = false; // Kiểm tra xem dữ liệu có hợp lệ không
  bool _isLoading = false; // Kiểm tra trạng thái đang tải (loading)

// Hàm đăng ký người dùng
  void registerUser() async {
    // Bắt đầu quá trình đăng ký, hiển thị loading
    setState(() {
      _isLoading = true;
    });

    // Kiểm tra xem tất cả các trường nhập liệu có trống không
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        nameController.text.isNotEmpty) {
      // Kiểm tra xem mật khẩu và mật khẩu xác nhận có khớp không
      if (confirmPasswordController.text == passwordController.text) {
        // Tạo đối tượng yêu cầu body để gửi lên server
        var reqBody = {
          'fullName': nameController.text,
          'email': emailController.text,
          'password': passwordController.text
        };

        // Gửi yêu cầu HTTP POST đến API đăng ký người dùng
        var res = await http.post(Uri.parse('$urlRoot/accounts/register'),
            headers: {
              'Content-Type': 'application/json'
            }, // Đặt header cho kiểu dữ liệu JSON
            body: jsonEncode(reqBody)); // Gửi dữ liệu dưới dạng JSON

        // Giải mã phản hồi từ server
        var jsonResponse = jsonDecode(res.body);

        // Dừng trạng thái loading sau khi nhận được phản hồi từ server
        setState(() {
          _isLoading = false;
        });

        // Nếu mã phản hồi từ server là 0, đăng ký thành công
        if (jsonResponse['code'] == 0) {
          // Chuyển hướng đến màn hình đăng nhập
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyLogin(),
            ),
          );
        } else {
          // Nếu có lỗi, in thông báo lỗi ra console
          print(jsonResponse['message']);
        }
      } else {
        // Nếu mật khẩu và mật khẩu xác nhận không khớp, dừng loading và hiển thị thông báo lỗi
        setState(() {
          _isLoading = false;
        });
        showErrorToast(
            context: context,
            title: 'Error',
            description: 'Password and confirm password is not same!');
      }
    } else {
      // Nếu có trường nào bị trống, cập nhật trạng thái không hợp lệ và dừng loading
      setState(() {
        _isNotValite = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Container bao bọc toàn bộ giao diện và thêm hình nền
    return Container(
      decoration: BoxDecoration(
        // Thiết lập ảnh nền cho container
        image: DecorationImage(
          image: AssetImage('assets/register.png'), // Đường dẫn ảnh nền
          fit: BoxFit.cover, // Đảm bảo ảnh phủ kín toàn bộ màn hình
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Màu nền của Scaffold là trong suốt
        appBar: AppBar(
          backgroundColor:
              Colors.transparent, // AppBar không có nền, trong suốt
          elevation: 0, // Không có bóng đổ dưới AppBar
        ),
        body: LoadingOverlay(
          // Bọc body với LoadingOverlay để hiển thị trạng thái tải
          isLoading: _isLoading, // Trạng thái loading có hiển thị hay không
          child: Stack(
            children: [
              // Đặt tiêu đề "Create Account" trên cùng
              Container(
                padding:
                    EdgeInsets.only(left: 35, top: 30), // Đặt lề cho tiêu đề
                child: Text(
                  'Create\nAccount', // Tiêu đề
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 33), // Màu chữ trắng, kích thước chữ 33
                ),
              ),
              SingleChildScrollView(
                // Bọc các trường nhập liệu vào SingleChildScrollView để có thể cuộn khi giao diện nhỏ
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.28),
                  // Điều chỉnh vị trí của các trường nhập liệu sao cho cách đầu trang một khoảng hợp lý
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Căn lề trái cho các trường nhập liệu
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            // Trường nhập tên
                            TextField(
                              controller:
                                  nameController, // Điều khiển trường nhập liệu
                              style: TextStyle(
                                  color: Colors.white), // Màu chữ trắng
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // Bo góc
                                  borderSide: BorderSide(
                                    color: Colors.white, // Màu viền trắng
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors
                                        .black, // Màu viền khi có focus là đen
                                  ),
                                ),
                                errorStyle: TextStyle(
                                    color:
                                        Colors.white), // Màu chữ thông báo lỗi
                                errorText: _isNotValite
                                    ? "Enter your name"
                                    : null, // Lỗi nếu tên trống
                                hintText: "Name", // Gợi ý cho người dùng
                                hintStyle: TextStyle(
                                    color: Colors.white), // Màu chữ gợi ý
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  30, // Khoảng cách giữa các trường nhập liệu
                            ),
                            // Trường nhập email
                            TextField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.white),
                                errorText: _isNotValite
                                    ? "Enter your email"
                                    : null, // Lỗi nếu email trống
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: "Email", // Gợi ý cho email
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            // Trường nhập mật khẩu
                            TextField(
                              controller: passwordController,
                              style: TextStyle(color: Colors.white),
                              obscureText:
                                  true, // Ẩn mật khẩu khi người dùng nhập
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.white),
                                errorText: _isNotValite
                                    ? "Enter your password" // Lỗi nếu mật khẩu trống
                                    : null,
                                hintText: "Password", // Gợi ý cho mật khẩu
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            // Trường nhập xác nhận mật khẩu
                            TextField(
                              controller: confirmPasswordController,
                              style: TextStyle(color: Colors.white),
                              obscureText:
                                  true, // Ẩn mật khẩu khi người dùng nhập
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                errorStyle: TextStyle(color: Colors.white),
                                errorText: _isNotValite
                                    ? "Enter confirm password" // Lỗi nếu xác nhận mật khẩu trống
                                    : null,
                                hintText:
                                    "Confirm password", // Gợi ý cho xác nhận mật khẩu
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            // Button đăng ký
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight:
                                          FontWeight.w700), // Tiêu đề "Sign Up"
                                ),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xff4c505b),
                                  child: IconButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        registerUser(); // Gọi hàm đăng ký khi nhấn vào nút
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                      )),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            // Button đăng nhập
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyLogin())); // Chuyển đến màn hình đăng nhập
                                  },
                                  style: ButtonStyle(),
                                  child: Text(
                                    'Sign In', // Chữ "Sign In"
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      decoration: TextDecoration
                                          .underline, // Gạch chân chữ
                                      color: Colors.white,
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
