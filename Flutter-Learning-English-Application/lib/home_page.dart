import 'package:application_learning_english/screens/account_screen.dart';
import 'package:application_learning_english/screens/library_screen.dart';
import 'package:application_learning_english/screens/popular_flashcard.dart';
import 'package:application_learning_english/user.dart';
import 'package:application_learning_english/utils/session_user.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning English',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    Library(),
    Community(),
    Profile(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  String? username;
  String? accountId;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    User? user = await getUserData();
    setState(() {
      username = user?.username;
      accountId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (username == null || accountId == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return LibraryScreen(username: username!, accountId: accountId!);
  }
}

class Community extends StatelessWidget {
  const Community({super.key});

  @override
  Widget build(BuildContext context) {
    return PopularFlashcard();
  }
}

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountScreen();
  }
}
