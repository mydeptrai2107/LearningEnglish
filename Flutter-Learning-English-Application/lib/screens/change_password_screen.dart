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


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final urlRoot = kIsWeb ? webURL : androidURL;


  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  late SharedPreferences prefs;
  bool _isNotValidate =
      false;
  late User user;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    initGetDataUser();
  }


  void initGetDataUser() async {
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap =
          jsonDecode(userJson);
      user = User.fromJson(userMap);
    }
  }


  void changePassword() async {

    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      // Kiểm tra xem mật khẩu mới và xác nhận mật khẩu mới có khớp không.
      if (_newPasswordController.text == _confirmPasswordController.text) {
        setState(() {
          isLoading = true;
        });


        var reqBody = {
          '_id': user.uid,
          'oldPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text
        };


        var res = await http.post(Uri.parse('$urlRoot/accounts/changePassword'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reqBody));

        var jsonResponse = jsonDecode(res.body);

        setState(() {
          isLoading = false;
        });


        if (jsonResponse['code'] == 0) {
          showSuccessToast(
              context: context,
              title: 'Success',
              description: 'Change password successfully!');
          Navigator.pop(context);
        } else {
          showErrorToast(
              context: context,
              title: 'Error',
              description: jsonResponse['message']);
        }
      } else {

        showErrorToast(
            context: context,
            title: 'Error',
            description: 'Password and confirm password not match!');
      }
    } else {
      setState(() {
        _isNotValidate =
            true;
        isLoading = false;
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
                context);
          },
          icon:
              const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                changePassword();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: Size(60, 50),
                elevation: 3,
              ),
              icon: Icon(Ionicons.checkmark,
                  color: Colors.white),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
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
                    obscureText: true,
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

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}


class EditItem extends StatelessWidget {
  final String title;
  final Widget widget;

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
        widget,
      ],
    );
  }
}
