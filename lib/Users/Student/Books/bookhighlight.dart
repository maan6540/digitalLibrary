// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookHighlight extends StatefulWidget {
  const BookHighlight({super.key, required this.studentId, required this.book});
  final int studentId;
  final BookModel book;
  @override
  State<BookHighlight> createState() => _BookHighlightState();
}

class _BookHighlightState extends State<BookHighlight>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: MyAppBar(title: widget.book.bookName!),
      body: Column(
        children: [
          Container(
            color: const Color(backgroundColor),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              dividerColor: Colors.transparent,
              controller: _tabController,
              tabs: [
                tabBar("My Highlights"),
                tabBar("All Highlights"),
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
                MyHighLights(
                  book: widget.book,
                  studentId: widget.studentId,
                  type: "",
                ),
                MyHighLights(book: widget.book, studentId: widget.studentId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabBar(String text) {
    return SizedBox(
      height: 40,
      child: Center(child: Text(text)),
    );
  }
}

class MyHighLights extends StatefulWidget {
  const MyHighLights(
      {super.key,
      required this.book,
      required this.studentId,
      this.type = "All"});
  final int studentId;
  final BookModel book;
  final String? type;

  @override
  State<MyHighLights> createState() => _MyHighLightsState();
}

class _MyHighLightsState extends State<MyHighLights> {
  late Future<List<HighlightModel>> futureHighlights;
  List<HighlightModel> highlights = [];
  String message = "";
  Future<List<HighlightModel>> getHighlights() async {
    String url = widget.type != "All"
        ? "$baseUrl/Highlight/getHighLight?studentId=${widget.studentId}&type=Book&highlightItemId=${widget.book.bookId}"
        : "$baseUrl/Highlight/getAllHighLight?type=Book&highlightItemId=${widget.book.bookId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data =
              responsedata.map((e) => HighlightModel.fromJson(e)).toList();
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

  Future<void> toggleHighlight(int id, int index) async {
    String url = "$baseUrl/Highlight/togglePublicPrivate?highlightId=$id";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          highlights[index].highlightType =
              highlights[index].highlightType == "Public"
                  ? "Private"
                  : "Public";
          setState(() {});
        } else {
          showSnackBar(responseBody["message"]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> updateHighlight(int index, String text) async {
    String url = "$baseUrl/Highlight/updateHighlight";
    int id = highlights[index].highlightId!;
    int pageNo = highlights[index].pageNo!;
    try {
      var response = await http.put(Uri.parse(url),
          headers: headers,
          body: jsonEncode(
              {"highlightId": id, "highlightName": text, "pageNo": pageNo}));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          showSnackBar(responseBody["message"]);
          highlights[index].highlightName = text;
          setState(() {});
        } else {
          showSnackBar(responseBody["message"]);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> removeHighlight(int id, int index) async {
    String url = "$baseUrl/Highlight/removeHighlight?highlightId=$id";
    try {
      var response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          showSnackBar(responseBody["message"]);
          highlights.removeAt(index);
          if (highlights.isEmpty) {
            message = "All Highlights Removed";
          }
          setState(() {});
        } else {
          showSnackBar(responseBody["message"]);
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  void showdialog(int index) {
    TextEditingController highlightController = TextEditingController();
    highlightController.text = highlights[index].highlightName!;
    setState(() {});
    showDialog(
      context: context,
      builder: (context) {
        return MyDialog(
          title: "Update Highlight",
          okbtn: "Update",
          cancelBtn: "Cancel",
          btncount: 2,
          functionOkbtn: () async {
            if (highlightController.text.trim().isEmpty) {
              showSnackBar("Add Highlight Name First");
            } else {
              await updateHighlight(index, highlightController.text.trim());
              Navigator.pop(context);
            }
          },
          child: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: highlightController,
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
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    futureHighlights = getHighlights();
    super.initState();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureHighlights,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            highlights = snapshot.data!;
            if (highlights.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: highlights.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPdfFileScreen(
                            path:
                                "$fileBaseUrl/BookPDFFolder/${widget.book.bookPdfPath!}",
                            name: widget.book.bookName!,
                            pageNo: highlights[index].pageNo,
                            user: "Student",
                            screenof: "Book",
                            studentId: widget.studentId,
                            itemId: widget.book.bookId,
                          ),
                        ),
                      );
                      futureHighlights = getHighlights();
                      setState(() {});
                    },
                    child: HighLightTile(
                      type: widget.type!,
                      highlight: highlights[index],
                      onDelete: () {
                        removeHighlight(highlights[index].highlightId!, index);
                      },
                      onEdit: () {
                        showdialog(index);
                      },
                      onToggle: () {
                        toggleHighlight(highlights[index].highlightId!, index);
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

class HighLightTile extends StatelessWidget {
  const HighLightTile(
      {super.key,
      required this.highlight,
      required this.onDelete,
      required this.onEdit,
      required this.onToggle,
      required this.type});
  final HighlightModel highlight;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25), color: Colors.white),
        child: Row(
          children: [
            SizedBox(
              width: type != "All" ? 170 : 250,
              child: Text(
                highlight.highlightName!,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (type != "All")
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
              ),
            if (type != "All")
              IconButton(
                onPressed: onToggle,
                icon: Icon(highlight.highlightType == "Public"
                    ? Icons.lock_open
                    : Icons.lock),
              ),
            if (type != "All")
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit),
              ),
          ],
        ),
      ),
    );
  }
}
