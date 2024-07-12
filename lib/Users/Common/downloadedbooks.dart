import 'dart:convert';
import 'dart:io';

import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewdownloadedbooktoc.dart';
import 'package:digitallibrary/Users/Common/viewpdffileoffline.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedBookScreen extends StatefulWidget {
  const DownloadedBookScreen({
    super.key,
    required this.id,
  });
  final int id;

  @override
  State<DownloadedBookScreen> createState() => _DownloadedBookScreenState();
}

class _DownloadedBookScreenState extends State<DownloadedBookScreen> {
  late Future<List<BookModel>> futurebooks;
  List<BookModel> books = [];
  TextEditingController searchController = TextEditingController();

  Future<List<BookModel>> getDownloadedBooks() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      List<String>? data =
          pref.getStringList('books'); // Change dynamic to String
      if (data != null) {
        // Parse JSON data and populate the books list
        List<BookModel> downloadedBooks =
            data.map((e) => BookModel.fromJson(jsonDecode(e))).toList();
        return downloadedBooks;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return []; // Return an empty list if there's an error or no data
  }

  Future<void> deleteDownloadedBook(int index) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      List<String>? data = pref.getStringList('books');
      if (data == null) {
        return;
      }
      await deleteFile(books[index].bookCoverPagePath!);
      await deleteFile(books[index].bookPdfPath!);
      data.removeWhere((item) {
        // Assuming item is a JSON string that contains bookPdfPath
        var bookData = json.decode(item);
        return bookData['bookPdfPath'] == books[index].bookPdfPath;
      });
      pref.setStringList('books', data);
      books.removeAt(index);
      setState(() {
        futurebooks = getDownloadedBooks();
      });
      showSnackBar("Book Deleted");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('File deleted successfully');
      } else {
        debugPrint('File does not exist');
      }
    } catch (e) {
      debugPrint("Error : $e");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<BookModel> filterBooks(String query) {
    if (query.isEmpty) return books;
    return books.where((book) {
      return book.bookName!.toLowerCase().contains(query.toLowerCase()) ||
          book.bookAuthorName!.toLowerCase().contains(query.toLowerCase()) ||
          (book.bookKeywords != null &&
              book.bookKeywords!.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  @override
  void initState() {
    futurebooks = getDownloadedBooks();
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: searchController,
          //     decoration: const InputDecoration(
          //       hintText: 'Search books...',
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.all(Radius.circular(10)),
          //       ),
          //       suffixIcon: Icon(Icons.search),
          //     ),
          //     onChanged: (value) {
          //       setState(
          //           () {}); // Trigger a rebuild whenever the search query changes
          //     },
          //   ),
          // ),
          Expanded(
            child: FutureBuilder<List<BookModel>>(
              future: futurebooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  books = snapshot.data ?? [];
                  if (books.isEmpty) {
                    return const Center(
                      child: Text("No Books Downloaded"),
                    );
                  } else {
                    books = books
                        .where((element) => element.userId == widget.id)
                        .toList();
                    if (books.isEmpty) {
                      return const Center(
                        child: Text("No Books Downloaded"),
                      );
                    } else {
                      List<BookModel> filteredBooks =
                          filterBooks(searchController.text);
                      List<BookModel> displayBooks =
                          searchController.text.isEmpty ? books : filteredBooks;

                      if (displayBooks.isEmpty) {
                        return const Center(
                          child: Text("No Books Found"),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: displayBooks.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => ViewPdfFileOffline(
                                      path: displayBooks[index].bookPdfPath!,
                                      name: displayBooks[index].bookName!,
                                    ),
                                  ),
                                );
                              },
                              child: MyDownloadedBookTile(
                                book: displayBooks[index],
                                icon1: Icons.delete,
                                ftn1: (id) {
                                  deleteDownloadedBook(index);
                                },
                                icon3: Icons.list,
                                ftn3: (p0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) =>
                                          ViewDownloadedBookToc(
                                        bookId: p0,
                                        book: displayBooks[index],
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
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyDownloadedBookTile extends StatelessWidget {
  const MyDownloadedBookTile({
    super.key,
    this.ftn1,
    this.icon1,
    this.ftn2,
    this.icon2,
    this.ftn3,
    this.icon3,
    this.ftn4,
    this.icon4,
    this.ftn5,
    this.icon5,
    this.ftn6,
    this.icon6,
    this.isMultiple = "No",
    required this.book,
  });

  final Function(int)? ftn1;
  final IconData? icon1;
  final Function(int)? ftn2;
  final IconData? icon2;
  final Function(int)? ftn3;
  final IconData? icon3;
  final Function(int)? ftn4;
  final IconData? icon4;
  final Function(int)? ftn5;
  final IconData? icon5;
  final Function(int)? ftn6;
  final IconData? icon6;
  final BookModel book;
  final String? isMultiple;

  @override
  Widget build(BuildContext context) {
    double calculateWidth() {
      if (icon1 == null && icon3 == null && icon5 == null ||
          icon2 == null &&
              icon4 == null &&
              icon6 == null &&
              (icon1 != null || icon3 != null || icon5 != null)) {
        return 30;
      } else {
        return 3;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      height: book.status != null ? 170 : 120,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 150,
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors
                  .grey.shade300, // Use a default color or define iconColor
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: for rounded corners
              child: Image.file(
                File("${book.bookCoverPagePath}"),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error,
                      color: Colors.red, size: 50); // Error icon
                }, // Error icon
              ),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isMultiple == "Yes" ? 110 : 130,
                child: Text(
                  book.bookName!,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: isMultiple == "Yes" ? 85 : 105,
                    child: Text(
                      book.bookAuthorName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (book.status != null)
                SizedBox(
                  width: 110,
                  child: Text(
                    style: TextStyle(
                        color: book.status == "Success"
                            ? Colors.green
                            : Colors.red),
                    "Status : ${book.status}",
                    overflow: TextOverflow.ellipsis,
                  ),
                )
            ],
          ),
          SizedBox(width: calculateWidth()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (icon1 != null && ftn1 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn1!(book.bookId!);
                      },
                      icon: Icon(
                        icon1,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon2 != null && ftn2 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn2!(book.bookId!);
                      },
                      icon: Icon(
                        icon2,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (icon3 != null && ftn3 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn3!(book.bookId!);
                      },
                      icon: Icon(
                        icon3,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon4 != null && ftn4 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn4!(book.bookId!);
                      },
                      icon: Icon(
                        icon4,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (icon5 != null && ftn5 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn5!(book.bookId!);
                      },
                      icon: Icon(
                        icon5,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon6 != null && ftn6 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn6!(book.bookId!);
                      },
                      icon: Icon(
                        icon6,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
