import 'dart:convert';

import 'package:application_learning_english/login_page.dart'; // Import trang đăng nhập.
import 'package:application_learning_english/toastify/account.dart'; // Import tiện ích thông báo (toast).
import 'package:flutter/foundation.dart'; // Import để xác định nền tảng của ứng dụng (Web hay Android).
import 'package:flutter/material.dart'; // Import thư viện Flutter cho UI.
import 'package:http/http.dart'
    as http; // Import thư viện HTTP để thực hiện các yêu cầu mạng.
import 'config.dart'; // Import file cấu hình chứa các URL cần thiết.
import 'loading_overlay.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() =>
      _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final urlRoot = kIsWeb
      ? webURL
      : androidURL;

  TextEditingController emailController =
      TextEditingController();
  bool _isNotValidate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }


  void resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    // Kiểm tra nếu email không rỗng
    if (emailController.text.isNotEmpty) {
      var reqBody = {
        'email': emailController.text,
      };


      var res = await http.post(Uri.parse('$urlRoot/accounts/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reqBody));

      var jsonResponse =
          jsonDecode(res.body);
      setState(() {
        _isLoading = false;
      });

      if (jsonResponse['code'] == 0) {

        showSuccessToast(
          context: context,
          title: 'Success',
          description:
              'Please check email to take new password',
        );
        // Chuyển hướng đến màn hình đăng nhập.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyLogin()),
        );
      } else {
        // Nếu có lỗi, in thông báo lỗi.
        print(jsonResponse['message']);
      }
    } else {
      setState(() {
        _isNotValidate = true; // Hiển thị lỗi nếu email chưa được nhập.
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/login.png'),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent,
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: Stack(
            children: [
              Container(),
              Container(
                padding: EdgeInsets.only(
                    left: 35, top: 130),
                child: Text(
                  'Reset\nPassword', // Tiêu đề màn hình
                  style: TextStyle(color: Colors.white, fontSize: 33),
                ),
              ),
              SingleChildScrollView(
                // Cho phép cuộn màn hình nếu nội dung quá dài.
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: [
                            TextField(
                              controller:
                                  emailController, // Controller cho email.
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                errorStyle: TextStyle(color: Colors.black),
                                errorText: _isNotValidate
                                    ? "Enter your email" // Lỗi nếu email không hợp lệ.
                                    : null,
                                hintText:
                                    "Email", // Gợi ý "Email" khi chưa nhập.
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 30), // Khoảng cách giữa các phần tử.
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {
                                  resetPassword(); // Gọi hàm reset password khi bấm nút.
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.blue, // Màu nền của nút
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 20,
                                  ), // Kích thước nút.
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ), // Bo góc cho nút.
                                  ),
                                ),
                                child: Text(
                                  'Confirm', // Nút xác nhận
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: 40), // Khoảng cách giữa các phần tử.
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xff4c505b),
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyLogin(),
                                        ),
                                      ); // Quay lại màn hình đăng nhập.
                                    },
                                    icon: Icon(Icons.arrow_back),
                                  ),
                                ),
                              ],
                            ),
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
