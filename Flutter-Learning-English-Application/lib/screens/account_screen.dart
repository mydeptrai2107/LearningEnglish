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
  late SharedPreferences prefs;
  User? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    user = await getUserData();
    setState(() {});
  }

  void logOutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
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
        automaticallyImplyLeading: false,
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Image.asset("assets/avatar.png", width: 70, height: 70),
                    const SizedBox(width: 20),
                    if (user != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Username',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user?.username ?? "Email not available",
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
                "Settings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SettingItem(
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
                title: "About",
                icon: Ionicons.earth,
                bgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingLogout(
                title: "Log out",
                icon: Ionicons.log_out,
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: logOutUser,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
