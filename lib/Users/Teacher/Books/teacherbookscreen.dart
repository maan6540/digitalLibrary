import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Common/librarybooks.dart';
import 'package:digitallibrary/Users/Teacher/Books/mybooksmainscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class TeacherBooks extends StatefulWidget {
  const TeacherBooks({super.key, required this.teacherId});
  final int teacherId;

  @override
  State<TeacherBooks> createState() => _TeacherBooksState();
}

class _TeacherBooksState extends State<TeacherBooks>
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
      appBar: const MyAppBar(title: "Books"),
      body: Column(
        children: [
          Container(
            color: const Color(backgroundColor),
            // margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5),

            child: TabBar(
              labelPadding: const EdgeInsets.only(left: 5, right: 5),
              dividerColor: Colors.transparent,
              controller: _tabController,
              tabs: [tabBar("Library Books"), tabBar("My Books")],
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
                LibraryBooksSubPage(id: widget.teacherId),
                MyBookMainScreen(teacherId: widget.teacherId)
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
