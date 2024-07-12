import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/studentteachercoursetile.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Teacher/Courses/coursesmainscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  late Future<List<CourseModel>> futureCourses;
  List<CourseModel> courses = [];
  String message = '';

  Future<List<CourseModel>> getCourses() async {
    String url =
        "$baseUrl/Course/getTeacherCourses?teacherId=${widget.teacherId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> responsedata = responsebody["data"];
          var data = responsedata.map((e) => CourseModel.fromJson(e)).toList();
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
    futureCourses = getCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: const MyAppBar(title: "Courses"),
      body: FutureBuilder(
        future: futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          } else {
            courses = snapshot.data!;
            if (courses.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return TeacherStudentCourseTile(
                    role: "Teacher",
                    course: courses[index],
                    onPressed: (p0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => CoursesMainScreen(
                            teacherId: widget.teacherId,
                            courseCode: p0,
                          ),
                        ),
                      );
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
