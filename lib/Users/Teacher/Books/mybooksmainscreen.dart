import 'package:digitallibrary/Users/Common/librarybooks.dart';
import 'package:digitallibrary/Users/Common/downloadedbooks.dart';
import 'package:digitallibrary/Users/Teacher/Books/SubScreen/myuploadedbooks.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyBookMainScreen extends StatefulWidget {
  const MyBookMainScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  State<MyBookMainScreen> createState() => _MyBookMainScreenState();
}

class _MyBookMainScreenState extends State<MyBookMainScreen>
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
              tabs: [
                tabBar("My Uploads"),
                tabBar("BookMarked"),
                tabBar("Downloads")
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
                MyUploadedBookScreen(teacherId: widget.teacherId),
                LibraryBooksSubPage(
                  id: widget.teacherId,
                  isbookmark: true,
                ),
                DownloadedBookScreen(id: widget.teacherId),
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
