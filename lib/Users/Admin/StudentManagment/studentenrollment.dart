import 'dart:async';
import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen(
      {super.key, required this.regNo, required this.studentId});
  final String regNo;
  final int studentId;

  @override
  State<StudentEnrollmentScreen> createState() =>
      _StudentEnrollmentScreenState();
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  late Future<List<EnrolledCoursesModel>> futureEnrolledCourses;
  late Future<List<String>> futureCourseName;
  List<UnEnrolledCourses> unenrolledCourses = [];
  List<String> courseName = [];
  String courseCode = "";
  String message = "";
  TextEditingController smesterNoController = TextEditingController();
  TextEditingController sessionController = TextEditingController();
  List<EnrolledCoursesModel> courses = [];

  late Function() clearDropDown;

  Future<List<EnrolledCoursesModel>> getEnrolledCourses() async {
    String url =
        "$baseUrl/enrollment/getEnrollment?studentId=${widget.studentId}&year=${DateTime.now().year}&month=4";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> responseData = responsebody['data'];
          var data = responseData
              .map((e) => EnrolledCoursesModel.fromJson(e))
              .toList();
          return data;
        } else {
          message = "No Course Enrolled Yet";
        }
      } else {
        message = "Error Occured";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  Future<List<String>> getUnErnolledCourses() async {
    String url =
        "$baseUrl/enrollment/unEnrolledCourses?studentId=${widget.studentId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> responsedata = responsebody["data"];
          unenrolledCourses =
              responsedata.map((e) => UnEnrolledCourses.fromJson(e)).toList();
          var courseName = unenrolledCourses.map((e) => e.courseName!).toList();

          setState(() {});
          return courseName;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<void> enroll() async {
    if (courseCode == "") {
      showSnackBar("Plz Select Course");
      return;
    }
    String url = "$baseUrl/enrollment/enroll";
    try {
      var response = await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "year": DateTime.now().year,
            "month": DateTime.now().month,
            "smesterNo": smesterNoController.text.trim(),
            "studentId": widget.studentId,
            "courseCode": [courseCode]
          }));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        showSnackBar(responseBody["message"]);
        clearDropDown();
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
    courseCode = "";
  }

  Future<void> removeEnrollment(int index) async {
    String url =
        "$baseUrl/enrollment/removeEnrollment?studentId=${widget.studentId}&year=${DateTime.now().year}&month=${DateTime.now().month}&courseCode=${courses[index].courseCode!}";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          futureCourseName = getUnErnolledCourses();
          setState(() {
            courses.removeAt(index);
          });
          showSnackBar("Enrollment Removed");
        }
      } else {
        showSnackBar("Error Occured");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> getSemseterNo() async {
    String url =
        "$baseUrl/enrollment/GetSemesterNumber?studentId=${widget.studentId}&year=${DateTime.now().year}&month=${DateTime.now().month}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      smesterNoController.text = response.body;
      // setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void setCourseCode(String courseName) {
    for (var x in unenrolledCourses) {
      if (x.courseName == courseName) {
        courseCode = x.courseCode!;
      }
    }
  }

  void generateSession() {
    int year = DateTime.now().year;
    int month = DateTime.now().month;
    if (month >= 1 && month <= 6) {
      sessionController.text = "SPRING$year";
    } else {
      sessionController.text = "FALL$year";
    }
    setState(() {});
  }

  @override
  void initState() {
    generateSession();
    getSemseterNo();
    futureCourseName = getUnErnolledCourses();
    futureEnrolledCourses = getEnrolledCourses();
    getUnErnolledCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "${widget.regNo}\nEnrollment",
        height: 80,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        color: const Color(backgroundColor),
        child: Column(
          children: [
            // MyTextField(
            //   hintText: "Smester No",
            //   controller: smesterNoController,
            // ),
            MyTextField(
              hintText: "Session",
              controller: sessionController,
              screenType: "Edit",
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: futureCourseName,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) {
                  return Container(
                    width: 320,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      color: Colors.grey[100],
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    child: const Row(
                      children: [
                        Text("Loading"),
                        SizedBox(
                          width: 210,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                          size: 30,
                        )
                      ],
                    ),
                  );
                } else {
                  courseName = snapshot.data!;
                  if (courseName.isEmpty) {
                    return Container(
                      width: 320,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        color: Colors.grey[100],
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: const Row(
                        children: [
                          Text("No Course Left"),
                          SizedBox(
                            width: 170,
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                            size: 30,
                          )
                        ],
                      ),
                    );
                  } else {
                    return MyDropDown(
                      clearSelectedValueCallback: (callback) {
                        clearDropDown = callback;
                      },
                      width: 320,
                      height: 50,
                      textColor: Colors.black,
                      backgroundColor: Colors.grey[100],
                      borderColor: Colors.grey,
                      data: courseName,
                      onSelected: (v) {
                        setCourseCode(v);
                      },
                    );
                  }
                }
              },
            ),
            const SizedBox(
              height: 50,
            ),
            MyButton(
              onPressed: () async {
                await enroll();
                futureEnrolledCourses = getEnrolledCourses();
                futureCourseName = getUnErnolledCourses();
                // await Future.delayed(const Duration(milliseconds: 500));
                setState(() {});
              },
              text: "Enroll",
              width: 200,
              height: 40,
              // ),
            ),
            const SizedBox(
              height: 45,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Enrolled Courses",
                      style: TextStyle(
                          fontSize: 24, decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: futureEnrolledCourses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.connectionState ==
                                  ConnectionState.active) {
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
                                  return EnrolledCourseWidget(
                                    courseName: courses[index].courseName!,
                                    courseCode: courses[index].courseCode!,
                                    studentId: courses[index].studentId!,
                                    onDelete: () {
                                      removeEnrollment(index);
                                    },
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnrolledCourseWidget extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final int studentId;
  final VoidCallback onDelete;

  const EnrolledCourseWidget({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.studentId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 10, 7, 0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  courseName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  courseCode,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}

class UnEnrolledCourses {
  String? courseCode;
  String? courseName;

  UnEnrolledCourses({this.courseCode, this.courseName});

  UnEnrolledCourses.fromJson(Map<String, dynamic> json) {
    courseCode = json['courseCode'];
    courseName = json['courseName'];
  }
}
