// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:digitallibrary/users/Common/login.dart';
import 'package:digitallibrary/CustomWidgets/dashboard.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/profiletile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentTeacherProfileScreen extends StatefulWidget {
  const StudentTeacherProfileScreen(
      {super.key, required this.title, required this.type});
  final String title, type;
  @override
  State<StudentTeacherProfileScreen> createState() =>
      _StudentTeacherProfileScreenState();
}

class _StudentTeacherProfileScreenState
    extends State<StudentTeacherProfileScreen> {
  late String name = '';
  late String regNo = '';
  late String phoneNo = '';
  bool isloading = false;
  TextEditingController passwordController = TextEditingController();

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

  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isloading = true;
      name = pref.getString("name")!;
      // for teacher it will store the username in reg no for more detail view login page logic
      regNo = pref.getString("regNo")!;
      phoneNo = pref.getString("phoneNo")!;
      passwordController.text = pref.getString("password")!;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isloading = false;
    });
  }

  Future<void> updatePassword() async {
    String url = "$baseUrl/user/updatepassword";
    try {
      var response = await http.patch(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "username": regNo,
            "password": passwordController.text.trim(),
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

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "",
      ),
      body: Stack(
        children: [
          DashBoard(
            text: widget.title,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  ProfileTile(title: "Name", data: name, icon: Icons.person),
                  const SizedBox(
                    height: 15,
                  ),
                  ProfileTile(
                      title: widget.type == "Student" ? "RegNo" : "Username",
                      data: regNo,
                      icon: Icons.info),
                  const SizedBox(
                    height: 15,
                  ),
                  ProfileTile(
                      title: "Phone No", data: phoneNo, icon: Icons.call),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    width: 300,
                    margin: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                    padding: const EdgeInsets.only(left: 20),
                    height: 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Password",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              width: 180,
                              height: 55,
                              child: MyTextField(
                                hintText: "",
                                controller: passwordController,
                                isPassword: true,
                                pwd: true,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 20, right: 10),
                          child: MyButton(
                            text: "Update",
                            onPressed: () {
                              if (passwordController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Password Required")));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (builder) {
                                      return MyDialog(
                                        icon: Icons.warning,
                                        title: "Update Password",
                                        content:
                                            "You will logout once password is updated",
                                        btncount: 2,
                                        okbtn: "Ok",
                                        cancelBtn: "Cancel",
                                        functionOkbtn: () {
                                          updatePassword();
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  MylogoutButton(ftn: logout)
                ],
              ),
            ),
          ),
          if (isloading)
            Container(
              color: const Color.fromARGB(153, 255, 255, 255),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}
