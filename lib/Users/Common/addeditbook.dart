import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/addmultiplebooks.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddEditBook extends StatefulWidget {
  const AddEditBook({
    super.key,
    required this.type,
    required this.uploaderId,
    this.book,
    this.category,
  });
  final String type;
  final int uploaderId;
  final BookModel? book;
  final String? category;

  @override
  State<AddEditBook> createState() => _AddEditBookState();
}

class _AddEditBookState extends State<AddEditBook> {
  TextEditingController bookTitleController = TextEditingController();
  TextEditingController bookCategoryController = TextEditingController();
  TextEditingController bookCoverPageController = TextEditingController();
  TextEditingController bookPdfController = TextEditingController();
  TextEditingController bookAuthorsController = TextEditingController();
  TextEditingController bookKeywordsController = TextEditingController();
  // final int _selectedValue = 1;

  late Function() clearDropDown;

  int categoryId = 0;
  String? imagePath;
  String? bookPdfPath;
  late String category = '';
  List<BookCategoryModel> categorylist = [];
  List<String> categoryNames = [];
  String publicPrivate = '';

  Future<void> selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        bookCoverPageController.text = result.files.single.name;
        imagePath = result.files.single.path;
      });
    }
  }

  Future<void> selectBookPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        bookPdfController.text = result.files.single.name;
        bookPdfPath = result.files.single.path;
      });
    }
  }

  Future<void> getCategory() async {
    String url = "$baseUrl/Book/getBookCategory";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responseData = responseBody["data"];
          var data =
              responseData.map((e) => BookCategoryModel.fromJson(e)).toList();
          categorylist = data;
          categoryNames = data.map((e) => e.categroyName!).toList();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadBook() async {
    String url = widget.type == "Edit"
        ? "$baseUrl/Book/updateBook?bookId=${widget.book!.bookId!}"
        : "$baseUrl/Book/uploadBook";
    try {
      var request = widget.type == "Edit"
          ? http.MultipartRequest('PUT', Uri.parse(url))
          : http.MultipartRequest('POST', Uri.parse(url));
      request.fields["bookName"] = bookTitleController.text.trim();
      request.fields["categoryId"] = categoryId.toString();
      request.fields["bookAuthor"] = bookAuthorsController.text.trim();
      request.fields["keywords"] = bookKeywordsController.text.trim();
      request.fields["uploadType"] =
          widget.uploaderId == 0 ? "Public" : publicPrivate;
      request.fields["uploaderId"] = widget.uploaderId.toString();

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "bookImage",
            imagePath!,
          ),
        );
      }
      if (bookPdfPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "bookPdf",
            bookPdfPath!,
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

  void getCategoryId(String categoryName) {
    for (var x in categorylist) {
      if (x.categroyName == categoryName) {
        categoryId = x.categoryId!;
      }
    }
  }

  void clearfields() {
    bookTitleController.clear();
    bookCategoryController.clear();
    imagePath = null;
    bookPdfPath = null;
    bookCoverPageController.clear();
    bookPdfController.clear();
    bookAuthorsController.clear();
    bookKeywordsController.clear();
    category = "";
    clearDropDown();
    categoryId = 0;
    publicPrivate = '';
    setState(() {});
  }

  void validateField() {
    if (bookTitleController.text.trim().isEmpty) {
      showSnackBar("Book Title Required");
      return;
    }
    if (categoryId == 0) {
      showSnackBar("Select Category First");
      return;
    }
    if (bookCoverPageController.text.trim().isEmpty) {
      showSnackBar("Select Image First");
      return;
    }
    if (bookPdfController.text.trim().isEmpty) {
      showSnackBar("Select Book Pdf First");
      return;
    }
    if (bookAuthorsController.text.trim().isEmpty) {
      showSnackBar("Author Required");
      return;
    }
    if (bookKeywordsController.text.trim().isEmpty) {
      showSnackBar("Keywords Required");
      return;
    }
    if (widget.uploaderId != 0 && publicPrivate == "") {
      showSnackBar("Select Public or Private");
      return;
    }

    uploadBook();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void setdropdown() async {
    await getCategory();
    if (widget.type == "Edit") {
      category = widget.book!.categroyName!;
      getCategoryId(category);
    }
    setState(() {});
  }

  @override
  void initState() {
    if (widget.type == "Edit") {
      setState(() {
        bookTitleController.text = widget.book!.bookName!;
        bookCategoryController.text = widget.book!.categroyName!;
        bookCoverPageController.text = widget.book!.bookCoverPagePath!;
        bookPdfController.text = widget.book!.bookPdfPath!;
        bookAuthorsController.text = widget.book!.bookAuthorName!;
        if (widget.book!.bookKeywords != null) {
          bookKeywordsController.text = widget.book!.bookKeywords!;
        }
        publicPrivate = widget.book!.uploadType!;
      });
    }
    setdropdown();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "${widget.type} Book",
        onPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => const AddMultipleBooks()));
        },
        icon: Icons.add,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextField(
              hintText: "Title",
              controller: bookTitleController,
            ),
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8, left: 12),
              width: double.infinity,
              height: 50,
              child: MyDropDown(
                clearSelectedValueCallback: (callback) {
                  clearDropDown = callback;
                },
                hintText: category.isEmpty ? "Select" : category,
                data: categoryNames,
                onSelected: (c) {
                  setState(() {
                    category = c;
                    getCategoryId(c);
                  });
                },
                backgroundColor: const Color(iconColor),
                borderColor: Colors.black12,
              ),
            ),
            MyTextField(
              hintText: "Cover Page Path",
              controller: bookCoverPageController,
              screenType: "Edit",
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 12, top: 8),
              child: MyButton(
                text: "Browse",
                onPressed: () {
                  selectImage();
                },
              ),
            ),
            MyTextField(
              hintText: "Book Pdf Path",
              controller: bookPdfController,
              screenType: "Edit",
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 12, top: 8),
              child: MyButton(
                text: "Browse",
                onPressed: () {
                  selectBookPdf();
                },
              ),
            ),
            MyTextField(
              hintText: "Authors",
              controller: bookAuthorsController,
            ),
            MyTextField(
              hintText: "Keywords",
              controller: bookKeywordsController,
            ),
            if (widget.uploaderId != 0)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: MyDropDown(
                    height: 50,
                    width: double.infinity,
                    backgroundColor: const Color(iconColor),
                    borderColor: Colors.black12,
                    textColor: Colors.white,
                    data: const ["Public", "Private"],
                    onSelected: (v) {
                      publicPrivate = v;
                    },
                    hintText: publicPrivate == "" ? "Select" : publicPrivate,
                    clearSelectedValueCallback: (callback) {
                      clearDropDown = callback;
                    }),
              ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: ListTile(
            //         title: const Text("Public"),
            //         leading: Radio<int>(
            //           value: 1,
            //           groupValue: _selectedValue,
            //           onChanged: (int? value) {
            //             setState(() {
            //               _selectedValue = value!;
            //             });
            //           },
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: ListTile(
            //         title: const Text("Private"),
            //         leading: Radio<int>(
            //           value: 2,
            //           groupValue: _selectedValue,
            //           onChanged: (int? value) {
            //             setState(() {
            //               _selectedValue = value!;
            //             });
            //           },
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(
              height: widget.uploaderId == 0
                  ? MediaQuery.of(context).size.height * 0.26
                  : MediaQuery.of(context).size.height * 0.2,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: MyButton(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.9,
                text: "Upload Book",
                onPressed: () {
                  validateField();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
