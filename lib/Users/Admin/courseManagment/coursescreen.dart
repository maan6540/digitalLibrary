// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/CustomWidgets/myfloatingactionbutton.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Admin/courseManagment/addeditcourse.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late Future<List<CourseModel>> futureCourses;
  List<CourseModel> courses = [];
  List<AllTeacherModel> teachers = [];
  List<String> teacherNames = [];
  int teacherId = 0;
  String message = '';

  late Function() clearDropDown;

  Future<List<CourseModel>> getCourses() async {
    String url = "$baseUrl/Course/getAll";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data = responsedata.map((e) => CourseModel.fromJson(e)).toList();
          return data;
        } else {
          message = responseBody["message"];
        }
      } else {
        message = "Server Not Responding";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  Future<void> deleteCourse(String courseCode) async {
    String url = "$baseUrl/Course/deleteCourse?courseCode=$courseCode";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          showSnackBar(responsebody["message"]);
          setState(() {
            futureCourses = getCourses();
          });
        } else {
          showSnackBar(responsebody["message"]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> assignCourse(String courseCode) async {
    String url = "$baseUrl/Course/courseAssign";
    try {
      var response = await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode({"courseCode": courseCode, "teacherId": teacherId}));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        showSnackBar(responseBody["message"]);

        clearDropDown();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    teacherId = 0;
  }

  Future<Map<String, dynamic>> getCourseAssignment(String courseCode) async {
    String url = "$baseUrl/Course/getCourseAssignment?courseCode=$courseCode";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        return {"status": "Failed"};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {"status": "Failed", "message": e.toString()};
    }
  }

  Future<void> removeCourseAssignment(String courseCode, int teacherId) async {
    String url = "$baseUrl/Course/removeCourseAssign";
    try {
      var response = await http.delete(Uri.parse(url),
          headers: headers,
          body: jsonEncode({"courseCode": courseCode, "teacherId": teacherId}));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          showSnackBar("Course Assignment Removed");
          Navigator.pop(context);
        } else {
          showSnackBar("Error Occured");
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> getAllTeachers() async {
    String url = "$baseUrl/Teacher/getAll";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        List<dynamic> teacherList = responsebody["data"];
        var data = teacherList.map((e) => AllTeacherModel.fromJson(e)).toList();
        teachers = data;
        teacherNames = teachers.map((e) => e.teacherName!).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void getTeacherId(String teacherName) {
    for (var x in teachers) {
      if (x.teacherName == teacherName) {
        teacherId = x.teacherId!;
      }
    }
  }

  @override
  void initState() {
    getAllTeachers();
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
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                  return CourseTile(
                    course: courses[index],
                    onEdit: (id) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditCourse(
                            type: "Edit",
                            course: courses[index],
                          ),
                        ),
                      );
                      futureCourses = getCourses();
                      setState(() {});
                    },
                    onDelete: (id) async {
                      showDialog(
                          context: context,
                          builder: (builder) {
                            return MyDialog(
                              icon: Icons.warning,
                              title: "Confirmation",
                              content:
                                  "Are you sure to delete ${courses[index].courseCode}",
                              btncount: 2,
                              cancelBtn: "No",
                              okbtn: "Yes",
                              functionOkbtn: () {
                                deleteCourse(courses[index].courseCode!);
                                Navigator.pop(context);
                              },
                            );
                          });
                    },
                    onAssign: (id) async {
                      var assignmentData =
                          await getCourseAssignment(courses[index].courseCode!);

                      showDialog(
                        context: context,
                        builder: (_) {
                          return MyDialog(
                            icon: Icons.add,
                            title: "Assign ${courses[index].courseCode}",
                            okbtn: "Assign",
                            cancelBtn: "Cancel",
                            btncount: 2,
                            functionOkbtn: () {
                              if (teacherId == 0) {
                                showSnackBar("Please Select Teacher First");
                              } else {
                                assignCourse(courses[index].courseCode!);
                              }
                            },
                            child: SizedBox(
                              height: 90,
                              child: Column(
                                children: [
                                  MyDropDown(
                                    clearSelectedValueCallback: (p0) {
                                      clearDropDown = p0;
                                    },
                                    borderColor: Colors.white,
                                    backgroundColor: const Color(mainColor),
                                    textColor: Colors.white,
                                    hintText: "Select Teacher",
                                    data: teacherNames,
                                    onSelected: (d) {
                                      getTeacherId(d);
                                    },
                                  ),
                                  if (assignmentData["status"] == "Success")
                                    Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          width: 178,
                                          child: Text(
                                            assignmentData["data"][0]
                                                ["teacherName"],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await removeCourseAssignment(
                                                courses[index].courseCode!,
                                                assignmentData["data"][0]
                                                    ["teacherId"]);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )
                                  else
                                    const Text(
                                      textAlign: TextAlign.left,
                                      "Course not assigned",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: MyFloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddEditCourse(type: "Add")));
          futureCourses = getCourses();
          setState(() {});
        },
        icon: Icons.file_upload,
      ),
    );
  }
}

class CourseTile extends StatelessWidget {
  const CourseTile(
      {super.key,
      required this.course,
      required this.onEdit,
      required this.onDelete,
      required this.onAssign});
  final CourseModel course;
  final Function(String) onEdit;
  final Function(String) onDelete;
  final Function(String) onAssign;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  style: const TextStyle(fontSize: 20),
                  course.courseName!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(course.courseCode!),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        onEdit(course.courseCode!);
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        onDelete(course.courseCode!);
                      },
                      icon: const Icon(Icons.delete)),
                ],
              ),
              IconButton(
                  onPressed: () {
                    onAssign(course.courseCode!);
                  },
                  icon: const Icon(Icons.person_add)),
            ],
          )
        ],
      ),
    );
  }
}

class AllTeacherModel {
  String? teacherName;
  int? teacherId;

  AllTeacherModel({this.teacherName, this.teacherId});

  AllTeacherModel.fromJson(Map<String, dynamic> json) {
    teacherName = json['teacherName'];
    teacherId = json['teacherId'];
  }
}
