import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Admin/courseManagment/addmultiplecourses.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddEditCourse extends StatefulWidget {
  const AddEditCourse({super.key, required this.type, this.course});
  final String type;
  final CourseModel? course;

  @override
  State<AddEditCourse> createState() => _AddEditCourseState();
}

class _AddEditCourseState extends State<AddEditCourse> {
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseCreditHoursController = TextEditingController();
  TextEditingController courseContentPdfController = TextEditingController();
  String? selectedFilePath;
  FilePickerResult? result;
  String message = "";
  Future<void> addCourse() async {
    String url = "$baseUrl/Course/addCourse";
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields["courseCode"] = courseCodeController.text;
      request.fields["courseName"] = courseNameController.text;
      request.fields["creditHours"] = courseCreditHoursController.text;
      if (selectedFilePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'courseContent',
            selectedFilePath!,
          ),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var streamResponse = await http.Response.fromStream(response);
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
    }
  }

  Future<void> updateCourse() async {
    String url =
        "$baseUrl/Course/updateCourse"; // Assuming the update endpoint is different
    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.fields["courseCode"] = courseCodeController.text;
      request.fields["courseName"] = courseNameController.text;
      request.fields["creditHours"] = courseCreditHoursController.text;
      if (selectedFilePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'courseContent',
            selectedFilePath!,
          ),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var streamResponse = await http.Response.fromStream(response);
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
    }
  }

  Future<void> pickFile() async {
    result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFilePath = result!.files.single.path!;
        courseContentPdfController.text =
            result!.files.single.path ?? 'No file selected';
      });
    }
  }

  void textFieldValidator() {
    if (courseCodeController.text.trim().isEmpty) {
      showSnackBar("Course Code Required");
      return;
    }
    if (courseNameController.text.trim().isEmpty) {
      showSnackBar("Course Name Required");
      return;
    }
    if (courseCreditHoursController.text.trim().isEmpty) {
      showSnackBar("Credit Hours Required");
      return;
    }
    if (courseContentPdfController.text.isEmpty) {
      showSnackBar("Course Content File Required");
      return;
    }
    if (widget.type == "Edit") {
      updateCourse();
    } else {
      addCourse();
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void clearfields() {
    courseCodeController.clear();
    courseContentPdfController.clear();
    courseCreditHoursController.clear();
    courseNameController.clear();
  }

  @override
  void initState() {
    if (widget.type == "Edit") {
      courseCodeController.text = widget.course!.courseCode!;
      courseNameController.text = widget.course!.courseName!;
      courseCreditHoursController.text = widget.course!.creditHours!;
      courseContentPdfController.text = widget.course!.courseContentUriPath!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: MyAppBar(
        title: "${widget.type} Course",
        onPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => const AddMultipleCourses()));
        },
        icon: Icons.add,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MyTextField(
              hintText: "CourseCode Here",
              screenType: widget.type,
              controller: courseCodeController,
            ),
            MyTextField(
              hintText: "Course Name Here",
              controller: courseNameController,
            ),
            MyTextField(
              hintText: "Credit Hours Here",
              controller: courseCreditHoursController,
            ),
            MyTextField(
              hintText: "Course Content File",
              controller: courseContentPdfController,
              screenType: "Edit",
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: MyButton(
                onPressed: () {
                  pickFile();
                },
                width: 130,
                text: "Choose File",
              ),
            ),
            SizedBox(
              height: height * 0.44,
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: MyButton(
                onPressed: () {
                  textFieldValidator();
                },
                width: MediaQuery.of(context).size.width * 0.95,
                height: 40,
                text: "${widget.type} Course",
              ),
            )
          ],
        ),
      ),
    );
  }
}
