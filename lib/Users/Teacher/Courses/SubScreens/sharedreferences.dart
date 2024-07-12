import 'dart:convert';

import 'package:digitallibrary/Users/Common/viewpdffileoffline.dart';
import 'package:digitallibrary/Users/Teacher/Courses/SubScreens/weeklpscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddReferencesMainScreen extends StatefulWidget {
  const AddReferencesMainScreen(
      {super.key, required this.courseCode, required this.id});
  final String courseCode;
  final int id;

  @override
  State<AddReferencesMainScreen> createState() =>
      _AddReferencesMainScreenState();
}

class _AddReferencesMainScreenState extends State<AddReferencesMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: Column(
        children: [
          Container(
            color: const Color(backgroundColor),
            // margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5),

            child: TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              dividerColor: Colors.transparent,
              controller: _tabController,
              tabs: [
                tabBar("Add References"),
                tabBar("Shared References"),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: const Color(mainColor),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(mainColor),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WeekLPSubScreen(
                  courseCode: widget.courseCode,
                  id: widget.id,
                  user: "Student",
                ),
                ViewSharedReferences(
                  studentId: widget.id,
                  courseCode: widget.courseCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabBar(String text) {
    return SizedBox(
      height: 40,
      child: Center(child: Text(text)),
    );
  }
}

class ViewSharedReferences extends StatefulWidget {
  const ViewSharedReferences(
      {super.key, required this.courseCode, required this.studentId});
  final String courseCode;
  final int studentId;

  @override
  State<ViewSharedReferences> createState() => _ViewSharedReferencesState();
}

class _ViewSharedReferencesState extends State<ViewSharedReferences> {
  late Future<List<ShareStudentsModel>> futureShares;
  List<ShareStudentsModel> shares = [];
  String message = '';
  Future<List<ShareStudentsModel>> getmyShares() async {
    String url =
        "$baseUrl/Sharing/getSharing?studentId=${widget.studentId}&courseCode=${widget.courseCode}";
    print(widget.studentId);
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> responsedata = responsebody["data"];
          var data =
              responsedata.map((e) => ShareStudentsModel.fromJson(e)).toList();
          return data;
        } else {
          message = "No share found";
        }
      } else {
        message = "No Share Found";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  void initState() {
    futureShares = getmyShares();
    super.initState();
  }

  void delete(int id, int index) async {
    String url = "$baseUrl/Sharing/removeSharing?sharingId=$id";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        shares.removeAt(index);
        setState(() {});
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureShares,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            shares = snapshot.data!;
            if (shares.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: shares.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(shares[index].lessonPlanTitle!),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => ViewPdfFileOffline(
                                  path:
                                      "$fileBaseUrl/LessonPlanPdfFolder/${shares[index].lessonPlanPdfPatn}",
                                  name: shares[index].lessonPlanTitle!)));
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        delete(shares[index].sharingId!, index);
                      },
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

class ShareStudentsModel {
  String? studentName;
  int? sharingId;
  String? lessonPlanPdfPatn;
  String? sharedBy;
  String? lessonPlanTitle;
  ShareStudentsModel(
      {this.sharingId,
      this.studentName,
      this.lessonPlanPdfPatn,
      this.sharedBy,
      this.lessonPlanTitle});

  ShareStudentsModel.fromJson(Map<String, dynamic> json) {
    studentName = json['studentName'];
    sharingId = json['sharingId'];
    lessonPlanPdfPatn = json['lessonPlanPdfPatn'];
    sharedBy = json["studentName"];
    lessonPlanTitle = json["lessonPlanTitle"];
  }
}
