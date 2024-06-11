import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Teacher/Logs/studentlogs.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class StudentNamesScreen extends StatefulWidget {
  const StudentNamesScreen({super.key, required this.smesterNumber});
  final int smesterNumber;

  @override
  State<StudentNamesScreen> createState() => _StudentNamesScreenState();
}

class _StudentNamesScreenState extends State<StudentNamesScreen> {
  late Future<List<StudentModel>> futureStudents;
  List<StudentModel> students = [];
  String message = '';
  Future<List<StudentModel>> getStudents() async {
    String url = "$baseUrl/Logs/getStudents?smesterNo=${widget.smesterNumber}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody['status'] == "Success") {
          List<dynamic> responsedata = responsebody['data'];
          var data = responsedata.map((e) => StudentModel.fromJson(e)).toList();
          return data;
        } else {
          message = responsebody["message"];
        }
      } else {
        message = "Error : ${response.statusCode}";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  @override
  void initState() {
    futureStudents = getStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Student Names"),
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            students = snapshot.data!;
            if (students.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => StudentLogs(
                            studentId: students[index].studentId!,
                            regNo: students[index].studentRegNo!,
                          ),
                        ),
                      );
                    },
                    child: Container(
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
                                  students[index].studentName!,
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
                                  students[index].studentRegNo!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
