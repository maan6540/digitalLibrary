// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/myfloatingactionbutton.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Admin/StudentManagment/multipleenrollment.dart';
import 'package:digitallibrary/Users/Admin/StudentManagment/studentenrollment.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:digitallibrary/users/Common/addedituser.dart';
// import 'package:digitallibrary/users/admin/StudentManagment/studentenrollment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentScreen extends StatefulWidget {
  const StudentScreen(
      {super.key, required this.departmentName, required this.departmentId});
  final String departmentName;
  final int departmentId;

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  Future<List<StudentModel>> getstudents() async {
    String url =
        '$baseUrl/Student/getAllStudent?departmentid=${widget.departmentId}';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8"
        },
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> jsondata = responsebody["data"];
          var data = jsondata.map((e) => StudentModel.fromJson(e)).toList();
          return data;
        } else if (responsebody["status"] == "Failed") {
          message = responsebody["message"];
        } else {
          message = "Error occured Plz contact Service Provider";
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  @override
  void initState() {
    studentdata = getstudents();
    super.initState();
  }

  late Future<List<StudentModel>> studentdata;
  late String message = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: MyAppBar(title: widget.departmentName),
      body: FutureBuilder(
        future: studentdata,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<StudentModel> data = snapshot.data!;
            if (data.isEmpty) {
              return Center(child: Text(message));
            } else {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return StudentTiles(
                      id: data[index].studentId!,
                      studentName: data[index].studentName!,
                      // regNo: data[index].studentRegNo!,
                      regNo: "202-NUN-0022",
                      onDelete: () {
                        setState(() {
                          data.removeAt(index);
                        });
                      },
                      onEdit: () {
                        studentdata = getstudents();
                        setState(() {});
                      },
                    );
                  });
            }
          }
        },
      ),
      floatingActionButton: MyFloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const MultipleEnrollment()));
          },
          icon: Icons.keyboard_double_arrow_up),
    );
  }
}

class StudentTiles extends StatelessWidget {
  Future<void> delete(BuildContext context) async {
    String url = "$baseUrl/user/deleteUser";
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(
          {"id": id, "role": "Student"},
        ),
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Student Deleted"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error Occured"),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  const StudentTiles(
      {super.key,
      required this.id,
      required this.studentName,
      required this.regNo,
      required this.onEdit,
      required this.onDelete});
  final String studentName;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String regNo;
  final int id;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  studentName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              SizedBox(
                width: 180,
                child: Text(
                  regNo,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => AddEditUserScreen(
                            role: "Student",
                            type: "Edit",
                            id: id,
                          )));
              onEdit();
            },
            child: const Icon(
              Icons.edit,
              color: Color(iconColor),
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (builder) {
                  return MyDialog(
                    icon: Icons.warning,
                    title: "Confitmation",
                    okbtn: "Yes",
                    cancelBtn: "No",
                    btncount: 2,
                    functionOkbtn: () {
                      delete(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Are you sure to delete\n$studentName\n$regNo",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
            },
            child: const Icon(
              Icons.delete,
              color: Color(iconColor),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentEnrollmentScreen(
                            regNo: regNo,
                            studentId: id,
                          )));
            },
            child: const Icon(
              CupertinoIcons.arrow_up_doc_fill,
              color: Color(iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
