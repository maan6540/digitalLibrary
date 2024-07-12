import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffileoffline.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewDownloadedBookToc extends StatefulWidget {
  const ViewDownloadedBookToc(
      {super.key, required this.bookId, required this.book});
  final int bookId;
  final BookModel book;

  @override
  State<ViewDownloadedBookToc> createState() => _ViewDownloadedBookTocState();
}

class _ViewDownloadedBookTocState extends State<ViewDownloadedBookToc> {
  late Future<List<TocModel>> futureToc;
  late List<TocModel> tocList;
  late TextEditingController searchController;
  Future<List<TocModel>> getToc(int bookId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? existingTocs = prefs.getStringList("tocs");

    // If there are no existing TOCs, return an empty list
    if (existingTocs == null) {
      return [];
    }

    // Deserialize existing TOCs
    List<TocModel> tocs = existingTocs
        .map((tocJson) => TocModel.fromJson(jsonDecode(tocJson)))
        .toList();

    // Filter TOCs by bookId
    List<TocModel> tocList = tocs.where((toc) => toc.bookId == bookId).toList();

    return tocList;
  }

  @override
  void initState() {
    super.initState();
    futureToc = getToc(widget.bookId);
    tocList = [];
    searchController = TextEditingController();
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
                          builder: (builder) => ViewPdfFileOffline(
                                path: widget.book.bookPdfPath!,
                                name: widget.book.bookName!,
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
