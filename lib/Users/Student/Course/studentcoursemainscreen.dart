import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Student/Course/SubScreens/studentcoursebooks.dart';
import 'package:digitallibrary/Users/Student/Course/SubScreens/studentlessonplan.dart';
import 'package:digitallibrary/Users/Teacher/Courses/SubScreens/sharedreferences.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class StudentCourseMainScree extends StatefulWidget {
  const StudentCourseMainScree({
    super.key,
    required this.studentId,
    required this.courseCode,
  });
  final int studentId;
  final String courseCode;

  @override
  State<StudentCourseMainScree> createState() => _StudentCourseMainScreeState();
}

class _StudentCourseMainScreeState extends State<StudentCourseMainScree>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: MyAppBar(title: widget.courseCode),
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
                tabBar("Books"),
                tabBar("Weekly LP"),
                tabBar("References")
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
                StudentCourseBooks(
                    courseCode: widget.courseCode, id: widget.studentId),
                StudentWeekLp(courseCode: widget.courseCode),
                AddReferencesMainScreen(
                  courseCode: widget.courseCode,
                  id: widget.studentId,
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
