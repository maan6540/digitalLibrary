import 'dart:convert';
import 'dart:io';
import 'package:digitallibrary/Users/Common/viewpdffileoffline.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/downloadedbooks.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as e;
import 'package:http/http.dart' as http;

class AddMultipleBooks extends StatefulWidget {
  const AddMultipleBooks({super.key});

  @override
  State<AddMultipleBooks> createState() => _AddMultipleBooksState();
}

class _AddMultipleBooksState extends State<AddMultipleBooks> {
  TextEditingController bookTitleController = TextEditingController();
  TextEditingController bookCategoryController = TextEditingController();
  TextEditingController bookCoverPageController = TextEditingController();
  TextEditingController bookPdfController = TextEditingController();
  TextEditingController bookAuthorsController = TextEditingController();
  TextEditingController bookKeywordsController = TextEditingController();

  String? imagePath;
  String? bookPdfPath;
  String file = "No File Selected";
  String? filePath;
  List<BookModel> books = [];

  Future<void> uploadBooks() async {
    String url = "$baseUrl/Book/uploadBook";

    for (int i = 0; i < books.length; i++) {
      var book = books[i];
      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // Ensure all properties are not null before adding to the request
        if (book.bookName != null) {
          request.fields["bookName"] = book.bookName!.trim();
        }
        if (book.categoryId != null) {
          request.fields["categoryId"] = book.categoryId!.toString();
        }
        if (book.bookAuthorName != null) {
          request.fields["bookAuthor"] = book.bookAuthorName!.trim();
        }
        if (book.bookKeywords != null) {
          request.fields["keywords"] = book.bookKeywords!.trim();
        }
        if (book.uploadType != null) {
          request.fields["uploadType"] = book.uploadType!.trim();
        }
        request.fields["uploaderId"] = '0';

        if (book.bookCoverPagePath != null &&
            book.bookCoverPagePath!.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(
              "bookImage",
              book.bookCoverPagePath!,
            ),
          );
        }

        //  if (book.bookPdfPath != null && book.bookPdfPath!.isNotEmpty) {
        //   request.files.add(
        //     await http.MultipartFile.fromPath(
        //       "bookPdf",
        //       book.bookPdfPath!,
        //     ),
        //   );
        // }

        var response = await request.send();
        if (response.statusCode == 200) {
          var streamResponse = await http.Response.fromStream(response);
          var responseBody = jsonDecode(streamResponse.body);
          books[i].status = responseBody['status'];
        } else {
          books[i].status = "Error : ${response.statusCode}";
        }
      } catch (e) {
        debugPrint(e.toString());
        books[i].status = "Server Down";
      }

      setState(() {});
    }
  }

  Future<void> selectFile() async {
    if (await Permission.storage.request().isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          file = result.files.single.name;
          filePath = result.files.single.path;
        });
      } else {
        // User canceled the picker
      }
    } else {
      // Handle the case when permissions are not granted
      showSnackBar("Storage permissions are required to upload books.");
    }
  }

  void readExcelFile(String filePath) {
    books.clear();
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    var excel = e.Excel.decodeBytes(bytes);

    var sheet =
        excel.tables.keys.elementAt(4); // Assuming data is in the third sheet

    if (excel.tables.containsKey(sheet)) {
      var table = excel.tables[sheet];
      for (var row in table!.rows.skip(1)) {
        // Skip header row
        // Extract cell values
        var title = row[0]?.value.toString();
        var categoryId = row[1]?.value.toString();
        var authors = row[2]?.value.toString();
        var keywords = row[3]?.value.toString();
        var type = row[4]?.value.toString();
        var coverPage = row[5]?.value.toString();
        var bookPdf = row[6]?.value.toString();
        var bookPdfPath = "/storage/emulated/0/book/$bookPdf";
        var coverPagePath = "/storage/emulated/0/book/$coverPage";
        BookModel book = BookModel(
            bookName: title,
            bookAuthorName: authors,
            categoryId: categoryId,
            bookKeywords: keywords,
            uploadType: type,
            bookCoverPagePath: coverPagePath,
            bookId: 0,
            bookPdfPath: bookPdfPath);
        books.add(book);
      }
      setState(() {});
    } else {
      showSnackBar("Sheet not found");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Multiple Books"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton(
                  width: 100,
                  text: "Select File",
                  onPressed: () {
                    selectFile();
                  },
                ),
                SizedBox(
                    width: 100,
                    child: Text(
                      file,
                      overflow: TextOverflow.ellipsis,
                    )),
                MyButton(
                  width: 100,
                  text: "Load Data",
                  onPressed: () {
                    if (filePath == null) {
                      showSnackBar("Select File First");
                    } else {
                      readExcelFile(filePath!);
                    }
                  },
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: 320,
              decoration: BoxDecoration(
                color: const Color(backgroundColor),
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      MyButton(
                        text: "Clear",
                        onPressed: () {
                          setState(() {
                            books.removeWhere(
                                (element) => element.status == "Success");
                          });
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      MyButton(
                        text: "Clear All",
                        onPressed: () {
                          books.clear();
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.63,
                    child: ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return MyDownloadedBookTile(
                          isMultiple: "Yes",
                          book: books[index],
                          ftn1: (id) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ViewPdfFileOffline(
                                        path: books[index].bookPdfPath!,
                                        name: "name")));
                          },
                          icon1: Icons.edit,
                          ftn3: (id) {
                            setState(() {
                              books.removeAt(index);
                            });
                          },
                          icon3: Icons.delete,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MyButton(
              onPressed: () {
                uploadBooks();
              },
              text: "Upload Books",
              width: 300,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
