// ignore_for_file: use_build_context_synchronously

import 'package:digitallibrary/Users/Admin/admindashboard.dart';
import 'package:digitallibrary/Users/Common/login.dart';
import 'package:digitallibrary/Users/Student/studentdashboard.dart';
import 'package:digitallibrary/Users/Teacher/teacherdashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> nextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("role");
    int? id = prefs.getInt("id");
    // if (!mounted) return;
    await Future.delayed(const Duration(seconds: 2));
    if (role == "Admin") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else if (role == "Teacher") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => TeacherDashboard(
                  teacherId: id!,
                )),
      );
    } else if (role == "Student") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => StudentDashboard(
                  studentId: id!,
                )),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    nextScreen();
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   nextScreen();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splashScreen.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
