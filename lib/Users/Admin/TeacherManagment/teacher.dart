// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:digitallibrary/users/Common/addedituser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherScreen extends StatefulWidget {
  const TeacherScreen(
      {super.key, required this.departmentName, required this.departmentId});
  final String departmentName;
  final int departmentId;

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  Future<List<TeacherModel>> getTeachers() async {
    String url =
        '$baseUrl/Teacher/getAllTeacher?departmentId=${widget.departmentId}';
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
          var data = jsondata.map((e) => TeacherModel.fromJson(e)).toList();
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

  late String message = '';
  late Future<List<TeacherModel>> teachers;
  @override
  void initState() {
    teachers = getTeachers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: MyAppBar(title: widget.departmentName),
      body: FutureBuilder(
        future: teachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<TeacherModel> data = snapshot.data!;
            if (data.isEmpty) {
              return Center(child: Text(message));
            } else {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return TeacherTile(
                    id: data[index].teacherId!,
                    teacherName: data[index].teacherName!,
                    onDelete: () {
                      setState(
                        () {
                          data.removeAt(index);
                        },
                      );
                    },
                    onEdit: () async {
                      teachers = getTeachers();
                      setState(() {});
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class TeacherTile extends StatelessWidget {
  Future<void> delete(BuildContext context) async {
    String url = "$baseUrl/user/deleteUser";
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(
          {"id": id, "role": "Teacher"},
        ),
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          onDelete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Teacher Deleted"),
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

  const TeacherTile(
      {super.key,
      required this.id,
      required this.teacherName,
      required this.onEdit,
      required this.onDelete});
  final String teacherName;
  final VoidCallback onDelete;
  final int id;
  final VoidCallback onEdit;
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
          SizedBox(
            width: 180,
            child: Text(
              teacherName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => AddEditUserScreen(
                    role: "Teacher",
                    type: "Edit",
                    id: id,
                  ),
                ),
              );
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
                      "Are you sure to delete\n$teacherName",
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
        ],
      ),
    );
  }
}
