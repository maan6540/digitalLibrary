// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/dashboard.dart';
import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Users/Common/login.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String username = "";
  String password = "";
  TextEditingController passwordController = TextEditingController();
  Future<void> getData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      password = pref.getString("password")!;
      username = pref.getString("username")!;
      // await Future.delayed(const Duration(milliseconds: 500));
      passwordController.text = password;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("role", "");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) =>
            false, // This predicate function will remove all previous routes
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updatePassword() async {
    String url = "$baseUrl/user/updatepassword";
    try {
      var response = await http.patch(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "username": username,
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
      appBar: const MyAppBar(title: ""),
      body: DashBoard(
        text: "Admin Profile",
        child: ListView(
          children: [
            adminProfileTile("Name", "Mehran Khan", Icons.person),
            adminProfileTile("Username", username, Icons.info),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                        width: MediaQuery.of(context).size.width * 0.58,
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
            Container(
              margin: const EdgeInsets.fromLTRB(20, 100, 20, 30),
              child: MyButton(
                height: 45,
                text: "Logout",
                onPressed: () {
                  logout();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget adminProfileTile(String heading, String text, IconData icon) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.only(left: 10),
      height: 100,
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(iconColor),
            size: 65,
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: const TextStyle(fontSize: 24),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
