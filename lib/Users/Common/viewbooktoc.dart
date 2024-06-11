import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookToc extends StatefulWidget {
  const BookToc({super.key, required this.bookId, required this.book});
  final int bookId;
  final BookModel book;

  @override
  State<BookToc> createState() => _BookTocState();
}

class _BookTocState extends State<BookToc> {
  late Future<List<TocModel>> futureToc;
  late List<TocModel> tocList;
  String message = '';
  late TextEditingController searchController;

  Future<List<TocModel>> getToc() async {
    String url = "$baseUrl/Book/getBookTOC?bookId=${widget.bookId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody["status"] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data = responsedata.map((e) => TocModel.fromJson(e)).toList();
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

  @override
  void initState() {
    super.initState();
    futureToc = getToc();
    tocList = [];
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Widget> buildTocList(List<TocModel> tocList) {
    List<TocModel> filteredList = filterTocList(tocList, searchController.text);

    Map<int, List<TocModel>> tocMap = {};

    // Organize TOC items by parent ID
    for (var toc in filteredList) {
      tocMap.putIfAbsent(toc.subTocOf ?? 0, () => []).add(toc);
    }

    // Function to recursively build the nested list
    List<Widget> buildNestedList(int parentId, int level) {
      if (!tocMap.containsKey(parentId)) {
        return [];
      }

      return tocMap[parentId]!.map((toc) {
        return Padding(
          padding: EdgeInsets.only(left: level * 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(toc.tocContent!),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ViewPdfFileScreen(
                                path:
                                    "$fileBaseUrl/BookPDFFolder/${widget.book.bookPdfPath!}",
                                name: "${widget.book.bookName}",
                                pageNo: toc.tocPageNo,
                              )));
                },
              ),
              ...buildNestedList(toc.tocId!, level + 1),
            ],
          ),
        );
      }).toList();
    }

    return buildNestedList(0, 0);
  }

  List<TocModel> filterTocList(List<TocModel> tocList, String keyword) {
    return tocList
        .where((toc) =>
            toc.tocContent!.toLowerCase().contains(keyword.toLowerCase()) ||
            toc.tocKeywords!
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .any((e) => e.contains(keyword.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "Book TOC"),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: searchController,
          //     decoration: const InputDecoration(
          //       hintText: "Search",
          //     ),
          //     onChanged: (value) {
          //       setState(() {});
          //     },
          //   ),
          // ),
          Expanded(
            child: FutureBuilder<List<TocModel>>(
              future: futureToc,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                } else {
                  tocList = snapshot.data!;
                  if (tocList.isEmpty) {
                    return const Center(
                      child: Text("No Table of Content Found"),
                    );
                  } else {
                    return ListView(
                      children: buildTocList(tocList),
                    );
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
