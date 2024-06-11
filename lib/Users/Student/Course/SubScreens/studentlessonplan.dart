import 'package:digitallibrary/Users/Student/Course/SubScreens/LessonPlanSubScreens/studentlessonplansubscreen.dart';
import 'package:digitallibrary/Users/Student/Course/SubScreens/LessonPlanSubScreens/studentreferencesubscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class StudentWeekLp extends StatefulWidget {
  const StudentWeekLp({super.key, required this.courseCode});
  final String courseCode;

  @override
  State<StudentWeekLp> createState() => _StudentWeekLpState();
}

class _StudentWeekLpState extends State<StudentWeekLp>
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
              tabs: [tabBar("Lesson Plan"), tabBar("Reference Material")],
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
                StudentLessonPlanSubScreen(courseCode: widget.courseCode),
                StudentReferenceMaterialSubScreen(courseCode: widget.courseCode)
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
