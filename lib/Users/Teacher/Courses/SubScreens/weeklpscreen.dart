import 'dart:async';
import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeekLPSubScreen extends StatefulWidget {
  const WeekLPSubScreen(
      {super.key,
      required this.courseCode,
      required this.id,
      this.user = "Teacher"});
  final int id;
  final String courseCode;
  final String? user;

  @override
  State<WeekLPSubScreen> createState() => _WeekLPSubScreenState();
}

class _WeekLPSubScreenState extends State<WeekLPSubScreen> {
  late Future<List<WeekLPModel>> futureWeekLP;
  List<WeekLPModel> weekLp = [];
  TextEditingController weekNoController = TextEditingController();
  TextEditingController lessonPlanPdfController = TextEditingController();
  String message = '';
  String? lessonPlanPdfPath;
  String screenType = "";
  int weekLpId = 0;

  Future<void> selectWeekLPPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: ['PNG', 'xls'],
        );

    if (result != null) {
      setState(() {
        lessonPlanPdfController.text = result.files.single.name;
        lessonPlanPdfPath = result.files.single.path;
      });
    }
  }

  Future<void> addLessonPlan() async {
    String url = screenType != "Edit"
        ? "$baseUrl/LessonPlan/addLessonPlan"
        : "$baseUrl/LessonPlan/updateLessonPlan?id=$weekLpId";
    try {
      var request = screenType != "Edit"
          ? http.MultipartRequest('POST', Uri.parse(url))
          : http.MultipartRequest('PUT', Uri.parse(url));
      request.fields["courseCode"] = widget.courseCode;
      request.fields["lessonPlanTitle"] = weekNoController.text.trim();
      request.fields["creatorId"] = widget.id.toString();
      request.fields["creatorType"] = widget.user!;
      if (lessonPlanPdfPath != null && lessonPlanPdfPath!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "lessonPlanPdf",
            lessonPlanPdfPath!,
          ),
        );
      }

      var response = await request.send();
      var streamResponse = await http.Response.fromStream(response);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(streamResponse.body);
        if (responseBody["status"] == "Success") {
          showSnackBar(responseBody["message"]);

          clearfields();
        } else {
          showSnackBar(responseBody["message"]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
    screenType = "";
    setState(() {});
  }

  Future<void> deleteLessonPlan(int index, int id) async {
    String url = "$baseUrl/LessonPlan/removeLessonPlan?id=$id";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          weekLp.removeAt(index);
          setState(() {});
          showSnackBar("Lesson Plan Removed");
        } else {
          showSnackBar(responsebody["message"]);
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  void clearfields() {
    lessonPlanPdfController.clear();
    weekNoController.clear();
    lessonPlanPdfPath = "";
    futureWeekLP = getWeekLP();
    setState(() {});
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<List<WeekLPModel>> getWeekLP() async {
    String url = widget.user == "Student"
        ? "$baseUrl/LessonPlan/getMyLessonPlan?courseCode=${widget.courseCode}&studentId=${widget.id}"
        : "$baseUrl/LessonPlan/getAllLessonPlan?courseCode=${widget.courseCode}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data = responsedata.map((e) => WeekLPModel.fromJson(e)).toList();
          return data;
        } else {
          message = responseBody["message"];
        }
      } else {
        message = "Error ${response.statusCode}";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  @override
  void initState() {
    futureWeekLP = getWeekLP();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyTextField(
              hintText: "WeekNo",
              controller: weekNoController,
            ),
            MyTextField(
              hintText: "Lesson Plan Pdf",
              controller: lessonPlanPdfController,
              screenType: "Edit",
            ),
            Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(right: 10, top: 10),
              child: MyButton(
                text: "Browse",
                width: 100,
                height: 40,
                onPressed: () {
                  selectWeekLPPdf();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: MyButton(
                width: double.infinity,
                height: 40,
                text: screenType != "Edit"
                    ? "Add Lesson Plan"
                    : "Update Lesson Plan",
                onPressed: () {
                  if (weekNoController.text.trim().isEmpty) {
                    showSnackBar("Week No Required");
                  } else if (lessonPlanPdfController.text.trim().isEmpty) {
                    showSnackBar("Lesson Plan Pdf Required");
                  } else {
                    addLessonPlan();
                  }
                },
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.495,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: FutureBuilder(
                future: futureWeekLP,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.active) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    weekLp = snapshot.data!;
                    if (weekLp.isEmpty) {
                      return Center(
                        child: Text(message),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: weekLp.length,
                        itemBuilder: (context, index) {
                          return WeekLPTile(
                            weeklp: weekLp[index],
                            onDelete: (p0) {
                              deleteLessonPlan(index, p0);
                            },
                            onEdit: (p0) {
                              setState(() {
                                screenType = "Edit";
                                weekLpId = weekLp[index].lessonPlanId!;
                                weekNoController.text =
                                    weekLp[index].lessonPlanTitle!;
                                lessonPlanPdfController.text =
                                    weekLp[index].lessonPlanPdfPatn!;
                              });
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
    );
  }
}

class WeekLPTile extends StatelessWidget {
  const WeekLPTile(
      {super.key,
      required this.weeklp,
      required this.onDelete,
      required this.onEdit});
  final WeekLPModel weeklp;
  final Function(int) onEdit;
  final Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewPdfFileScreen(
                    path:
                        "$fileBaseUrl/LessonPlanPdfFolder/${weeklp.lessonPlanPdfPatn}",
                    name: weeklp.lessonPlanTitle!)));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(backgroundColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 180,
              child: Text(weeklp.lessonPlanTitle!),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                onEdit(weeklp.lessonPlanId!);
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
            IconButton(
              onPressed: () {
                onDelete(weeklp.lessonPlanId!);
              },
              icon: const Icon(
                Icons.delete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
