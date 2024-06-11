import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Teacher/Courses/SubScreens/coursebook.dart';
import 'package:digitallibrary/Users/Teacher/Courses/SubScreens/referencescreen.dart';
import 'package:digitallibrary/Users/Teacher/Courses/SubScreens/weeklpscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class CoursesMainScreen extends StatefulWidget {
  const CoursesMainScreen(
      {super.key, required this.teacherId, required this.courseCode});
  final int teacherId;
  final String courseCode;

  @override
  State<CoursesMainScreen> createState() => _CoursesMainScreenState();
}

class _CoursesMainScreenState extends State<CoursesMainScreen>
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
                CourseBookSubScreen(courseCode: widget.courseCode),
                WeekLPSubScreen(
                    courseCode: widget.courseCode, id: widget.teacherId),
                CourseReferencesScreen(
                    courseCode: widget.courseCode, id: widget.teacherId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabBar(String text) {
    return SizedBox(
      width: 120,
      height: 40,
      child: Center(child: Text(text)),
    );
  }
}
