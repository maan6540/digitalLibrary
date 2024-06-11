// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/dashboard.dart';
import 'package:digitallibrary/CustomWidgets/dashboardtiles.dart';
import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/login.dart';
import 'package:digitallibrary/Users/Common/studentteacherprofile.dart';
import 'package:digitallibrary/Users/Teacher/Books/teacherbookscreen.dart';
import 'package:digitallibrary/Users/Teacher/Courses/teachercourses.dart';
import 'package:digitallibrary/Users/Teacher/Logs/studentlogsscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard(
      {super.key, required this.teacherId, this.isFirstLogin = "False"});
  final int teacherId;
  final String? isFirstLogin;

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late List<ModelDashBoardData> data;
  String regNo = '';

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('role');
    prefs.remove('username');
    prefs.remove('regNo');
    prefs.remove('phoneNo');
    prefs.remove('password');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Clear all existing routes
    );
  }

  Future<void> updatePassword(String password) async {
    String url = "$baseUrl/user/updatepassword";
    try {
      var response = await http.patch(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "username": regNo,
            "password": password,
            "isFirstLogin": "False"
          }));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          logout();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Server Down")));
    }
  }

  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    regNo = pref.getString("regNo")!;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void showdialog() {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return MyDialog(
          icon: Icons.warning,
          title: "Update Password",
          okbtn: "Update",
          btncount: 1,
          functionOkbtn: () {
            if (passwordController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password Required")));
            } else {
              updatePassword(passwordController.text.trim());
            }
          },
          child: TextField(
            controller: passwordController,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 10),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    data = [
      ModelDashBoardData(
        name: "Course",
        icon: const Icon(
          Icons.file_copy,
          size: 70,
          color: Color(iconColor),
        ),
        function: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => TeacherCoursesScreen(
                teacherId: widget.teacherId,
              ),
            ),
          );
        },
      ),
      ModelDashBoardData(
        name: "Books",
        icon: const Icon(
          Icons.book,
          size: 70,
          color: Color(iconColor),
        ),
        function: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => TeacherBooks(
                teacherId: widget.teacherId,
              ),
            ),
          );
        },
      ),
      ModelDashBoardData(
        name: "Student Logs",
        icon: const Icon(
          Icons.restore,
          size: 70,
          color: Color(iconColor),
        ),
        function: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => StudentLogsScreen(
                teacherId: widget.teacherId,
              ),
            ),
          );
        },
      ),
      ModelDashBoardData(
        name: "Profile",
        icon: const Icon(
          Icons.person,
          size: 70,
          color: Color(iconColor),
        ),
        function: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => const StudentTeacherProfileScreen(
                title: "Teacher Dashboard",
                type: "Teacher",
              ),
            ),
          );
        },
      ),
    ];
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isFirstLogin == "True") {
        getData().then((_) => showdialog());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: ""),
      body: DashBoard(
        text: "Teacher Dashboard",
        child: DashboardTiles(data: data),
      ),
    );
  }
}
