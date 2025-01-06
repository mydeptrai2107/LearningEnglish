import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../user.dart';
import '../widgets/edit_item.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender = "man";
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
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
    prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      setState(() {
        user = User.fromJson(userMap);
        _nameController.text = user!.fullName;
        _usernameController.text = user!.username;
        _emailController.text = user!.email;
        // gender = user!.gender;
      });
    }
  }

  void saveUserData() async {
    // if (user != null) {
    //   user.fullName = _nameController.text;
    //   // user!.age = int.tryParse(_ageController.text) ?? user!.age;
    //   user!.email = _emailController.text;
    //   // user!.gender = gender;

    //   String userJson = jsonEncode(user!.toJson());
    //   await prefs.setString('user', userJson);
    //   Navigator.pop(context); // Trở lại màn hình trước đó
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: saveUserData,
              style: IconButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: Size(60, 50),
                elevation: 3,
              ),
              icon: const Icon(Ionicons.checkmark, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Photo",
                widget: Column(
                  children: [
                    Image.asset(
                      "assets/avatar.png",
                      height: 100,
                      width: 100,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text("Upload Image"),
                    ),
                  ],
                ),
              ),
              EditItem(
                title: "Name",
                widget: TextField(
                  controller: _nameController,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Username",
                widget: TextField(
                  controller: _usernameController,
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Email",
                widget: TextField(
                  controller: _emailController,
                  readOnly: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
