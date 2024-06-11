import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/mybooktile.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/CustomWidgets/myfloatingactionbutton.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/addeditbook.dart';
import 'package:digitallibrary/Users/Common/addtoc.dart';
import 'package:digitallibrary/Users/Common/viewbooktoc.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyUploadedBookScreen extends StatefulWidget {
  const MyUploadedBookScreen({super.key, required this.teacherId});
  final int teacherId;
  @override
  State<MyUploadedBookScreen> createState() => _MyUploadedBookScreenState();
}

class _MyUploadedBookScreenState extends State<MyUploadedBookScreen> {
  late Function() clearDropDown;
  late Future<List<BookModel>> futureBooks;
  List<BookCategoryModel> categoryList = [];
  List<BookModel> books = [];
  String message = "";
  String courseCode = "";
  List<CourseModel> courses = [];
  List<String> courseNames = [];
  Future<void> getCourses() async {
    String url =
        "$baseUrl/Course/getTeacherCourses?teacherId=${widget.teacherId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> responsedata = responsebody["data"];
          courses = responsedata.map((e) => CourseModel.fromJson(e)).toList();
          courseNames = courses.map((e) => e.courseName!).toList();
        } else {
          message = responsebody["message"];
        }
      } else {
        message = "Error : ${response.statusCode}";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
  }

  Future<List<BookModel>> getBooks() async {
    String url = "$baseUrl/Book/getMyBooks?uploaderId=${widget.teacherId}";
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

  Future<void> deleteBook(int id, int index) async {
    String url =
        "$baseUrl/Book/deleteBook?bookId=$id&uploaderId=${widget.teacherId}";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          books.removeAt(index);
          setState(() {});
          showSnackBar(responseBody["message"]);
        } else {
          showSnackBar(responseBody["message"]);
        }
      } else {
        showSnackBar("Error Occured");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> assignBook(String courseCode, int bookId) async {
    String url = "$baseUrl/CourseBookAssign/assignBookCourse";
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          {"courseCode": courseCode, "bookId": bookId},
        ),
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        showSnackBar(responsebody['message']);
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  void assignBookToCourse(int bookId) {
    showDialog(
      context: context,
      builder: (builder) => MyDialog(
        title: "Assign to Course",
        icon: Icons.add_box_outlined,
        okbtn: "Assign",
        cancelBtn: "Cancel",
        btncount: 2,
        functionOkbtn: () {
          if (courseCode == "") {
            showSnackBar("Select Course First");
          } else {
            assignBook(courseCode, bookId);
            Navigator.pop(context);
          }
        },
        child: MyDropDown(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          data: courseNames,
          onSelected: (s) {
            getCourseCode(s);
          },
          clearSelectedValueCallback: (x) {
            clearDropDown = x;
          },
        ),
      ),
    );
  }

  Future<void> toggleBookPublicPrivate(int bookId) async {
    String url = "$baseUrl/Book/togglePublicPrivate?bookId=$bookId";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // var responseBody = jsonDecode(response.body);
        // showSnackBar(responseBody["message"]);
        setState(() {
          futureBooks = getBooks();
        });
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

  void getCourseCode(String courseName) {
    for (var x in courses) {
      if (x.courseName == courseName) {
        courseCode = x.courseCode!;
      }
    }
  }

  @override
  void initState() {
    futureBooks = getBooks();
    getCourses();
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
                child: Text("No Books Uploaded"),
              );
            } else {
              return ListView.builder(
                itemCount: books.length + 1,
                itemBuilder: (context, index) {
                  if (index == books.length) {
                    return const SizedBox(
                        height: 100); // Extra space at the end
                  }
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
                      icon1: Icons.assignment,
                      ftn1: (id) {
                        assignBookToCourse(id);
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
                      icon3: books[index].uploadType == "Public"
                          ? Icons.lock_open
                          : Icons.lock,
                      ftn3: (id) {
                        toggleBookPublicPrivate(id);
                      },
                      icon4: Icons.delete,
                      ftn4: (p0) {
                        deleteBook(p0, index);
                      },
                      icon5: Icons.add,
                      ftn5: (id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => AddBookToc(bookId: id),
                          ),
                        );
                      },
                      icon6: Icons.edit,
                      ftn6: (id) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => AddEditBook(
                              type: "Edit",
                              uploaderId: widget.teacherId,
                              book: books[index],
                            ),
                          ),
                        );
                        futureBooks = getBooks();
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: MyFloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (builder) =>
                    AddEditBook(type: "Add", uploaderId: widget.teacherId),
              ),
            );
            setState(() {
              futureBooks = getBooks();
            });
          },
          icon: Icons.upload),
    );
  }
}
