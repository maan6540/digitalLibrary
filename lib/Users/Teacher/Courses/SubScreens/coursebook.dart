import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/mybooktile.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewbooktoc.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class CourseBookSubScreen extends StatefulWidget {
  const CourseBookSubScreen({super.key, required this.courseCode});
  final String courseCode;
  @override
  State<CourseBookSubScreen> createState() => _CourseBookSubScreenState();
}

class _CourseBookSubScreenState extends State<CourseBookSubScreen> {
  late Future<List<BookModel>> futureBooks;
  List<BookCategoryModel> categoryList = [];
  List<BookModel> books = [];
  String message = "";
  Future<List<BookModel>> getBooks() async {
    String url =
        "$baseUrl/CourseBookAssign/getCourseAssignedBook?courseCode=${widget.courseCode}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data = responsedata.map((e) => BookModel.fromJson(e)).toList();
          return data;
        } else {
          message = responseBody["message"];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  Future<void> removeBookAssignment(
      int bookId, String courseCode, int index) async {
    String url =
        "$baseUrl/CourseBookAssign/removeBookCourse?courseCode=$courseCode&bookId=$bookId";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "Success") {
          showSnackBar("Assignment Removed");
          books.removeAt(index);
          setState(() {});
        } else {
          showSnackBar("Error Removing Assignment");
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    futureBooks = getBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            books = snapshot.data!;
            if (books.isEmpty) {
              return const Center(
                child: Text("No Books in library"),
              );
            } else {
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => ViewPdfFileScreen(
                              name: books[index].bookName!,
                              path:
                                  "$fileBaseUrl/BookPDFFolder/${books[index].bookPdfPath!}"),
                        ),
                      );
                    },
                    child: MyBookTile(
                      book: books[index],
                      icon1: Icons.delete,
                      ftn1: (id) {
                        removeBookAssignment(id, widget.courseCode, index);
                      },
                      icon2: Icons.list_sharp,
                      ftn2: (id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookToc(
                              bookId: id,
                              book: books[index],
                            ),
                          ),
                        );
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
