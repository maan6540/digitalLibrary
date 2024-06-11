import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybooktile.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/myfloatingactionbutton.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/addeditbook.dart';
import 'package:digitallibrary/Users/Common/addtoc.dart';
import 'package:digitallibrary/Users/Common/viewbooktoc.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late Future<List<BookModel>> futureBooks;
  List<BookCategoryModel> categoryList = [];
  List<BookModel> books = [];
  String message = "";
  Future<List<BookModel>> getBooks() async {
    String url = "$baseUrl/Book/getAll";
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
    String url = "$baseUrl/Book/deleteBook?bookId=$id&uploaderId=0";
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

  Future<void> getCategories() async {
    String url = "$baseUrl/Book/getBookCategory";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "Success") {
          List<dynamic> responseData = responseBody['data'];
          categoryList =
              responseData.map((e) => BookCategoryModel.fromJson(e)).toList();
          setState(() {});
        }
      } else {
        showSnackBar("Unable to load Categories");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addCategory(String category) async {
    String url = "$baseUrl/Book/addBookCategory?bookCategory=$category";
    try {
      var response = await http.post(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        showSnackBar(responseBody["message"]);
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
    getCategories();
    futureBooks = getBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: const MyAppBar(title: "Book Screen"),
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
                                      "$fileBaseUrl/BookPDFFolder/${books[index].bookPdfPath!}")));
                    },
                    child: MyBookTile(
                      book: books[index],
                      icon1: Icons.add,
                      ftn1: (id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => AddBookToc(bookId: id),
                          ),
                        );
                      },
                      icon2: Icons.delete,
                      ftn2: (id) {
                        deleteBook(id, index);
                      },
                      icon3: Icons.edit,
                      ftn3: (id) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => AddEditBook(
                              type: "Edit",
                              uploaderId: 0,
                              book: books[index],
                            ),
                          ),
                        );

                        futureBooks = getBooks();
                        setState(() {});
                      },
                      icon4: Icons.list_sharp,
                      ftn4: (id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => BookToc(
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
      floatingActionButton: MyFloatingActionButton(
          onPressed: () async {
            BottomSheetOverlay.show(context, onAddCategory: () {
              showDialog(
                  context: context,
                  builder: (builder) {
                    TextEditingController categoryController =
                        TextEditingController();
                    return MyDialog(
                      icon: Icons.add_box_outlined,
                      title: "Add Category",
                      okbtn: "Add",
                      btncount: 2,
                      functionOkbtn: () {
                        String datafield =
                            categoryController.text.trim().toUpperCase();
                        if (datafield.isNotEmpty) {
                          if (categoryList.any((category) =>
                              category.categroyName!.toUpperCase() ==
                              datafield)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Category Already Present"),
                              ),
                            );
                          } else {
                            addCategory(categoryController.text.trim());
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text("Category Added"),
                            //   ),
                            // );
                            Navigator.pop(context);
                          }
                          categoryController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Category Required"),
                            ),
                          );
                        }
                      },
                      cancelBtn: "Cancel",
                      child: TextField(
                        controller: categoryController,
                        cursorColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.only(top: 0, bottom: 0, left: 10),
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  });
            }, onBookUpload: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => const AddEditBook(
                    type: "Add",
                    uploaderId: 0,
                  ),
                ),
              );
              futureBooks = getBooks();
              setState(() {});
            });
          },
          icon: Icons.file_upload_outlined),
    );
  }
}

class BottomSheetOverlay extends StatelessWidget {
  const BottomSheetOverlay(
      {super.key, required this.onBookUpload, required this.onAddCategory});
  final VoidCallback onAddCategory;
  final VoidCallback onBookUpload;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black54, // To give a dim background effect
          ),
        ),
        Positioned(
          bottom: 60,
          right: 50,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MyButton(
                    text: "Upload Book",
                    onPressed: () {
                      Navigator.of(context).pop();
                      onBookUpload();
                    },
                    width: 150,
                    height: 40,
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    text: "Add Category",
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAddCategory();
                    },
                    width: 150,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context,
      {required VoidCallback onBookUpload,
      required VoidCallback onAddCategory}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => BottomSheetOverlay(
          onBookUpload: onBookUpload,
          onAddCategory: onAddCategory,
        ),
      ),
    );
  }
}
