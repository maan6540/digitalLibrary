// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddEditUserScreen extends StatefulWidget {
  const AddEditUserScreen(
      {super.key, required this.role, required this.type, this.id = 0});
  final String role;
  final String type;
  final int? id;

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _departmentAddController =
      TextEditingController();

  late Function() clearDropDown;

  int validateFields() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Name Required")));
      return 1;
    }
    if (widget.type != "Edit" &&
        _regNoController.text.trim().isEmpty &&
        widget.type == "Student") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("RegNo Required")));
      return 1;
    }
    if (_phoneNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("PhoneNo Required")));
      return 1;
    }
    if (department.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select Department")));
      return 1;
    }
    if (widget.role == "Teacher") {
      if (_usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Username Required")));
        return 1;
      }
    }
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password Required")));
      return 1;
    }
    return 0;
  }

  void clearfields() {
    _nameController.clear();
    _departmentAddController.clear();
    _passwordController.clear();
    _phoneNoController.clear();
    _regNoController.clear();
    clearDropDown();
    setState(() {
      department = '';
    });
    _usernameController.clear();
  }

  Future<void> addUser() async {
    if (validateFields() != 0) {
      return;
    }
    String url = "$baseUrl/user/RegisterUser";
    Map<String, String> requestbody = {
      "username": widget.role == "Teacher"
          ? _usernameController.text.trim()
          : _regNoController.text.trim(),
      "password": _passwordController.text.trim(),
      "role": widget.role,
      "department": department,
      "regNo": _regNoController.text.trim(),
      "name": _nameController.text.trim(),
      "phoneNo": _phoneNoController.text.trim()
    };
    try {
      var response = await http.post(Uri.parse(url),
          body: jsonEncode(requestbody), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseBody["message"],
              ),
            ),
          );
          clearfields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: Text(
                responseBody["message"],
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getInfo() async {
    if (widget.role == "Student") {
      String url = "$baseUrl/Student/getSingleStudent?studentId=${widget.id}";
      try {
        var response = await http.get(
          Uri.parse(url),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
        );
        if (response.statusCode == 200) {
          var responsebody = jsonDecode(response.body);
          var data = responsebody["data"];
          setState(() {
            _nameController.text = data[0]["studentName"];
            _regNoController.text = data[0]["studentRegNo"];
            _usernameController.text = data[0]["studentRegNo"];
            _phoneNoController.text = data[0]["studentPhoneNo"];
            department = data[0]["departmentName"];
            _passwordController.text = data[0]["password"];
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (widget.role == "Teacher") {
      String url = "$baseUrl/Teacher/getSingleTeacher?teacherId=${widget.id}";

      try {
        var response = await http.get(
          Uri.parse(url),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
        );

        if (response.statusCode == 200) {
          var responsebody = jsonDecode(response.body);
          var data = responsebody["data"];
          setState(() {
            _nameController.text = data[0]["teacherName"];
            _phoneNoController.text = data[0]["teacherPhone"];
            department = data[0]["departmentName"];
            _usernameController.text = data[0]["username"];
            _passwordController.text = data[0]["password"];
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> getDepartment() async {
    String url = "$baseUrl/department/allDepartment";
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Tyep": "application/json; charset=UTF-8"
        },
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> jsondata = responsebody["data"];
          for (var x in jsondata) {
            data.add(x["departmentName"]);
          }
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateUser() async {
    if (validateFields() != 0) {
      return;
    }
    String url = "$baseUrl/user/UpdateUser";
    Map<String, dynamic> requestbody = {
      "id": widget.id,
      "password": _passwordController.text.trim(),
      "role": widget.role,
      "department": department.toUpperCase().trim(),
      "name": _nameController.text.trim(),
      "phoneNo": _phoneNoController.text.trim()
    };
    try {
      var response = await http.put(
        Uri.parse(url),
        body: jsonEncode(requestbody),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody["status"] == "Success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseBody["message"],
              ),
            ),
          );
          clearfields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: Text(
                responseBody["message"],
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    if (widget.type == "Edit") {
      getInfo();
    }
    getDepartment();
    super.initState();
  }

  late List<String> data = [];
  late String department = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "${widget.type} ${widget.role}"),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        children: [
          MyTextField(
            hintText: "Name Here",
            controller: _nameController,
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.role == "Student")
            MyTextField(
              hintText: "RegNo Here",
              controller: _regNoController,
              screenType: widget.type,
            ),
          if (widget.role == "Student")
            const SizedBox(
              height: 10,
            ),
          MyTextField(
            hintText: "Phone No here",
            controller: _phoneNoController,
            inputType: TextInputType.number,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              MyDropDown(
                clearSelectedValueCallback: (p0) {
                  clearDropDown = p0;
                },
                data: data,
                hintText: department == '' ? "Select" : department,
                // searchEnabled: true,
                backgroundColor: const Color(iconColor),
                onSelected: (d) {
                  setState(() {
                    department = d;
                  });
                },
              ),
              const SizedBox(
                width: 15,
              ),
              MyButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return MyDialog(
                        icon: Icons.add_box_outlined,
                        title: "Add Department",
                        okbtn: "Add",
                        btncount: 2,
                        functionOkbtn: () {
                          String datafield = _departmentAddController.text
                              .trim()
                              .toUpperCase();
                          if (datafield.isNotEmpty) {
                            if (data.contains(datafield)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Department Already Present"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Department Added"),
                                ),
                              );
                              setState(() {
                                data.add(datafield);
                              });
                              Navigator.pop(context);
                            }
                            _departmentAddController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Department Name Required"),
                              ),
                            );
                          }
                        },
                        cancelBtn: "Cancel",
                        child: TextField(
                          controller: _departmentAddController,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.only(top: 0, bottom: 0, left: 10),
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
                },
                text: "Add",
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.role == "Teacher")
            MyTextField(
              hintText: "Username Here",
              controller: _usernameController,
              screenType: widget.type,
            ),
          if (widget.role == "Teacher")
            const SizedBox(
              height: 10,
            ),
          MyTextField(
            hintText: "Password Here",
            controller: _passwordController,
            isPassword: true,
            pwd: widget.type != "Edit" ? true : false,
          ),
          const SizedBox(
            height: 300,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: MyButton(
              onPressed: () {
                if (widget.type == "Edit") {
                  updateUser();
                } else {
                  addUser();
                }
              },
              height: 40,
              text: widget.type == "Edit"
                  ? "Update ${widget.role}"
                  : "Add ${widget.role}",
            ),
          ),
        ],
      ),
    );
  }
}
