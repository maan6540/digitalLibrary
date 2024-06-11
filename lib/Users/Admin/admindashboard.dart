import 'package:digitallibrary/CustomWidgets/dashboard.dart';
import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Admin/BookManagment/bookscreen.dart';
import 'package:digitallibrary/Users/Admin/adminprofile.dart';
import 'package:digitallibrary/Users/Admin/courseManagment/coursescreen.dart';
import 'package:digitallibrary/Users/Common/studentteachermanagment.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late List<AdmintileModel> data;
  @override
  void initState() {
    data = [
      AdmintileModel(
          text: "Student Managment",
          function: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StudentTeacherManagmentScreen(
                          user: "Student",
                        )));
          }),
      AdmintileModel(
          text: "Teacher Managment",
          function: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StudentTeacherManagmentScreen(
                          user: "Teacher",
                        )));
          }),
      AdmintileModel(
          text: "Course Managment",
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CourseScreen()));
          }),
      AdmintileModel(
          text: "Book Managment",
          function: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const BookScreen()));
          }),
      AdmintileModel(
          text: "Profile",
          function: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminProfileScreen()));
          }),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "",
      ),
      body: DashBoard(
        text: "Admin",
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (itme, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: adminTile(data[index]),
            );
          },
        ),
      ),
    );
  }

  Widget adminTile(AdmintileModel model) {
    return InkWell(
      onTap: () {
        model.function();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        width: 90,
        height: 50,
        alignment: Alignment.centerLeft,
        child: Text(model.text),
      ),
    );
  }
}

class AdmintileModel {
  String text;
  Function function;
  IconData? icon;
  AdmintileModel({required this.text, required this.function, this.icon});
}
