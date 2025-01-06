import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_learning_english/user.dart';

Future<User?> getUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user');
  if (userJson != null) {
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return User.fromJson(userMap);
  }
  return null;
}
