import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:digitallibrary/CustomWidgets/mybooktile.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewbooktoc.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentCourseBooks extends StatefulWidget {
  const StudentCourseBooks(
      {super.key, required this.courseCode, required this.id});
  final String courseCode;
  final int id;

  @override
  State<StudentCourseBooks> createState() => _StudentCourseBooksState();
}

class _StudentCourseBooksState extends State<StudentCourseBooks> {
  late Future<List<BookModel>> futureBooks;
  List<BookCategoryModel> categoryList = [];
  List<BookModel> books = [];
  String message = "";
  List<TocModel> tocList = [];
  List<BookModel> downloadedbooks = [];
  List<BookMarkModel> bookmarkedBooks = [];

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

  Future<String?> downloadImage(int bookId, int uniqueNumber) async {
    try {
      final url =
          '$baseUrl/Book/DownloadBookCover?BookId=$bookId'; // Replace with your API endpoint

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) {
          return null;
        }

        final pdfDir = Directory('${dir.path}/BookImage');
        if (!pdfDir.existsSync()) {
          pdfDir.createSync(recursive: true);
        }

        // Extract file extension from content-type header
        String? fileExtension;
        var contentType = response.headers['content-type'];
        if (contentType != null) {
          fileExtension = contentType.split('/').last;
        } else {
          fileExtension = 'PNG';
        }

        final filePath = '${pdfDir.path}/$uniqueNumber.$fileExtension';

        File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> getDownloadedBooks() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      List<String>? data =
          pref.getStringList('books'); // Change dynamic to String
      if (data == null) {
        return;
      } else {
        downloadedbooks = data
            .map((e) => BookModel.fromJson(jsonDecode(e)))
            .toList(); // Parse JSON string using jsonDecode
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<String?> downloadPDF(int bookId, int uniqueNumber) async {
    try {
      final url =
          '$baseUrl/Book/DownloadBook?BookId=$bookId'; // Replace with your API endpoint

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) {
          return null;
        }

        final pdfDir = Directory('${dir.path}/BookPDF');
        if (!pdfDir.existsSync()) {
          pdfDir.createSync(recursive: true);
        }

        // Extract file extension from content-type header
        String? fileExtension;
        var contentType = response.headers['content-type'];
        if (contentType != null) {
          fileExtension = contentType.split('/').last;
        } else {
          fileExtension = 'pdf';
        }
        final filePath = '${pdfDir.path}/$uniqueNumber.$fileExtension';

        File file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> downloadBook(int bookId, BookModel book, index) async {
    try {
      Random random = Random();
      int uniqueNumber =
          DateTime.now().millisecondsSinceEpoch + random.nextInt(1000);
      String? pdfPath = await downloadPDF(bookId, uniqueNumber);
      String? imagePath = await downloadImage(bookId, uniqueNumber);
      await getToc(bookId);

      if (pdfPath == null || imagePath == null) {
        showSnackBar("Failed to download");
      } else {
        saveInLocalStorage(pdfPath, imagePath, book, tocList);
        setState(() {
          books[index].isDownloaded = true;
        });
        showSnackBar("Book Downloaded");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getToc(int bookId) async {
    String url = "$baseUrl/Book/getBookTOC?bookId=$bookId";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          tocList = responsedata.map((e) => TocModel.fromJson(e)).toList();
          setState(() {});
        } else {
          message = responseBody["message"];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveInLocalStorage(String pdfPath, String imagePath,
      BookModel book, List<TocModel> tocList) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? existingBooks = prefs.getStringList('books');
      List<String>? existingTocs = prefs.getStringList("tocs");

      // If there are existing books, deserialize them
      List<BookModel> books = existingBooks != null
          ? existingBooks
              .map((bookJson) => BookModel.fromJson(jsonDecode(bookJson)))
              .toList()
          : [];

      // Deserialize existing TOCs if any
      List<TocModel> tocs = existingTocs != null
          ? existingTocs
              .map((tocJson) => TocModel.fromJson(jsonDecode(tocJson)))
              .toList()
          : [];

      BookModel saveBook = BookModel.copy(book);
      saveBook.userId = widget.id;
      saveBook.bookCoverPagePath = imagePath;
      saveBook.bookPdfPath = pdfPath;

      // Check if the book already exists with the same user ID and book ID
      bool foundDuplicate = false;
      for (int i = 0; i < books.length; i++) {
        if (books[i].userId == book.userId && books[i].bookId == book.bookId) {
          // Update the existing book instead of adding a new entry
          books[i] = book;
          foundDuplicate = true;
          break;
        }
      }

      // If no duplicate found, add the new book
      if (!foundDuplicate) {
        books.add(saveBook);
      }

      // Add TOC to the list
      tocs.addAll(tocList);

      // Serialize books and TOCs
      List<String> booksJsonList =
          books.map((book) => jsonEncode(book.toJson())).toList();
      List<String> tocsJsonList =
          tocs.map((toc) => jsonEncode(toc.toJson())).toList();

      // Store in SharedPreferences
      prefs.setStringList('books', booksJsonList);
      prefs.setStringList('tocs', tocsJsonList);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getBookmarkedBooks() async {
    String url =
        "$baseUrl/BookMark/getBookMark?userId=${widget.id}&userType=${"Student"}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          bookmarkedBooks =
              responsedata.map((e) => BookMarkModel.fromJson(e)).toList();
          setState(() {});
        } else {
          message = responseBody["message"];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addBookMark(int index, int bookId) async {
    String url = "$baseUrl/BookMark/addBookMark";
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          "bookId": bookId,
          "bookmarkOwnerId": widget.id,
          "bookmarkOwnerType": "Student"
        }),
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          books[index].isBookMarked = true;
          setState(() {});
        } else {
          showSnackBar("Unable to add BookMark");
        }
      } else {}
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> removeBookmark(int index, int bookId) async {
    String url =
        "$baseUrl/BookMark/removeBookMark?userId=${widget.id}&bookId=$bookId&userType=${"Student"}";
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          books[index].isBookMarked = false;
          bookmarkedBooks.removeWhere((element) => element.bookId == bookId);
          setState(() {});
        } else {
          showSnackBar("Unable to remove BookMark");
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
    getBookmarkedBooks();
    getDownloadedBooks();
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
              for (var x in books) {
                for (var y in downloadedbooks) {
                  if (x.bookId == y.bookId && y.userId == widget.id) {
                    x.isDownloaded = true;
                  }
                }
                for (var z in bookmarkedBooks) {
                  if (z.bookId == x.bookId) {
                    x.isBookMarked = true;
                  }
                }
              }

              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => ViewPdfFileScreen(
                              user: "Student",
                              studentId: widget.id,
                              itemId: books[index].bookId,
                              name: books[index].bookName!,
                              path:
                                  "$fileBaseUrl/BookPDFFolder/${books[index].bookPdfPath!}"),
                        ),
                      );
                    },
                    child: MyBookTile(
                      book: books[index],
                      icon1: books[index].isDownloaded == true
                          ? Icons.download_done
                          : Icons.download,
                      ftn1: (id) {
                        if (books[index].isDownloaded == true) {
                          showSnackBar("Book Already Downloaded");
                        } else {
                          downloadBook(id, books[index], index);
                        }
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
                      icon3: books[index].isBookMarked!
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_outlined,
                      ftn3: (id) {
                        if (books[index].isBookMarked!) {
                          removeBookmark(index, id);
                        } else {
                          addBookMark(index, id);
                        }
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
    );
  }
}
