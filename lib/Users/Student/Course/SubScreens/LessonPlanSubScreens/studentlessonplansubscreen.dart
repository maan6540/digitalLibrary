import 'dart:convert';

import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentLessonPlanSubScreen extends StatefulWidget {
  const StudentLessonPlanSubScreen({super.key, required this.courseCode});
  final String courseCode;

  @override
  State<StudentLessonPlanSubScreen> createState() =>
      _StudentLessonPlanSubScreenState();
}

class _StudentLessonPlanSubScreenState
    extends State<StudentLessonPlanSubScreen> {
  late Future<List<WeekLPModel>> futureWeekLP;
  List<WeekLPModel> weekLp = [];
  String message = '';
  Future<List<WeekLPModel>> getWeekLP() async {
    String url =
        "$baseUrl/LessonPlan/getAllLessonPlan?courseCode=${widget.courseCode}";
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
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 20),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPdfFileScreen(
                                        path:
                                            "$fileBaseUrl/LessonPlanPdfFolder/${weekLp[index].lessonPlanPdfPatn}",
                                        name: weekLp[index].lessonPlanTitle!)));
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            child: Text(weekLp[index].lessonPlanTitle!),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            }),
      ),
    );
  }
}
