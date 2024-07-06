// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/Users/Admin/admindashboard.dart';
import 'package:digitallibrary/Users/Student/studentdashboard.dart';
import 'package:digitallibrary/Users/Teacher/teacherdashboard.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  bool _obsecure = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text("Username required"),
        ),
      );
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 500),
          content: Text("Password required"),
        ),
      );
      return;
    }

    Map<String, dynamic> requestBody = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
    };
    try {
      setState(() {
        loading = true;
      });

      String url = "$baseUrl/user/loginUser";
      String requestBodyString = jsonEncode(requestBody);
      debugPrint(url);
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBodyString,
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          setState(() {
            loading = false;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Map<String, dynamic> data = responseBody["data"][0];
          debugPrint(data["role"]);
          if (data["role"] == "Student") {
            prefs.setString("regNo", data["regNo"]);
            prefs.setString("role", "Student");
            prefs.setString("password", data["password"]);
            prefs.setString("name", data["name"]);
            prefs.setString("phoneNo", data["phoneNo"]);
            prefs.setInt("id", data["id"]);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentDashboard(
                  studentId: data["id"],
                  isFirstLogin: data["isFirstLogin"],
                ),
              ),
            );
          } else if (data["role"] == "Admin") {
            prefs.setString("role", "Admin");
            prefs.setString("password", data["password"]);
            prefs.setString("username", data["username"]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboard(),
              ),
            );
          } else if (data["role"] == "Teacher") {
            prefs.setString("role", "Teacher");
            prefs.setString(
                "regNo",
                data[
                    "username"]); //the regNo key is storing username for the profile screen
            prefs.setString("password", data["password"]);
            prefs.setString("name", data["name"]);
            prefs.setString("phoneNo", data["phoneNo"]);
            prefs.setInt("id", data["id"]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherDashboard(
                  teacherId: data["id"],
                  isFirstLogin: data["isFirstLogin"],
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Role undefined"),
              ),
            );
          }

          setState(() {
            loading = false;
          });

          debugPrint(data.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody["message"]),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Server Down ${e.toString()}"),
        ),
      );
    }
    setState(() {
      loading = false;
    });
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (!RegExp(r"^[^@]+@nun\.com$").hasMatch(value) &&
        !RegExp(r"^\d{3}-NUN-\d{4}$").hasMatch(value)) {
      return 'Invalid Username or RegNo format';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: width,
              height: height,
              color: const Color(mainColor),
              child: (Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Image(
                      width: 150,
                      height: 150,
                      image: AssetImage("assets/loginLogo.png")),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  const Text(
                    "Digital Library",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1),
                  ),
                  const Text(
                    "Northern University Nowshera",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: height * 0.5,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: height * 0.05,
                        ),
                        const Text(
                          "LOGIN",
                          style:
                              TextStyle(color: Color(mainColor), fontSize: 28),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                    hintText: "UserName",
                                    contentPadding: EdgeInsets.only(
                                      left: 15,
                                    ),
                                  ),
                                  validator: _validateUsername,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFormField(
                                  obscureText: _obsecure,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                    hintText: "Password",
                                    contentPadding:
                                        const EdgeInsets.only(left: 15),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obsecure = !_obsecure;
                                        });
                                      },
                                      icon: Icon(
                                        _obsecure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(iconColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                            style: ButtonStyle(
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(mainColor)),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
            ),
          ),
          if (loading)
            Container(
              alignment: Alignment.center,
              color: const Color.fromARGB(172, 236, 236, 236),
              child: const CircularProgressIndicator(
                color: Color(mainColor),
                strokeWidth: 5,
              ),
            ),
        ],
      ),
    );
  }
}
