import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Common/downloadedbooks.dart';
import 'package:digitallibrary/Users/Common/librarybooks.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyItemMainScreen extends StatefulWidget {
  const MyItemMainScreen({super.key, required this.studentId});
  final int studentId;

  @override
  State<MyItemMainScreen> createState() => _MyItemMainScreenState();
}

class _MyItemMainScreenState extends State<MyItemMainScreen>
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
      appBar: const MyAppBar(title: "My Items"),
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
                tabBar("Downloaded Books"),
                tabBar("Bookmarked Books"),
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
                DownloadedBookScreen(
                  id: widget.studentId,
                ),
                LibraryBooksSubPage(
                  id: widget.studentId,
                  isbookmark: true,
                  user: "Student",
                )
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
