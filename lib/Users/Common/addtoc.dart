// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/addmultipletoc.dart';
import 'package:digitallibrary/constants/constants.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddBookToc extends StatefulWidget {
  const AddBookToc({super.key, required this.bookId});
  final int bookId;

  @override
  State<AddBookToc> createState() => _AddBookTocState();
}

class _AddBookTocState extends State<AddBookToc> {
  late Future<List<TocModel>> futureToc;
  List<TocModel> tocList = [];
  TextEditingController contentController = TextEditingController();
  TextEditingController pageController = TextEditingController();
  TextEditingController keywordController = TextEditingController();
  String message = '';
  Future<List<TocModel>> getToc() async {
    String url = "$baseUrl/Book/getBookTOC?bookId=${widget.bookId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody['status'] == "Success") {
          List<dynamic> responseData = responseBody['data'];
          var data = responseData.map((e) => TocModel.fromJson(e)).toList();
          return data;
        } else {
          message = responseBody['message'];
        }
      } else {
        message = "Error Occured";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<void> removeToc(int id, int index) async {
    String url = "$baseUrl/Book/deleteTOC?tocId=$id";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody['status'] == "Success") {
          tocList.removeAt(index);
          setState(() {});
        } else {
          showSnackBar(responsebody["message"]);
        }
      } else {
        showSnackBar("Error : First Delete SubContent");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  Future<void> addToc({String? content, String? pageNo, int? subTocId}) async {
    String url = "$baseUrl/Book/addTOC";
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          {
            "tocContent": content ?? contentController.text,
            "pageNo": pageNo ?? pageController.text,
            "bookId": widget.bookId,
            "subTocOf": subTocId ?? "",
            "keywords": keywordController.text.trim()
          },
        ),
      );
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "success") {
          showSnackBar("Toc Added");
          futureToc = getToc();
          setState(() {});
          clearfields();
        } else {
          showSnackBar("Unable to Add Toc");
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar("Server Down");
    }
  }

  void clearfields() {
    contentController.clear();
    pageController.clear();
    keywordController.clear();
  }

  void validate() {
    if (contentController.text.trim().isEmpty) {
      showSnackBar("Content Name Required");
      return;
    }
    if (pageController.text.trim().isEmpty) {
      showSnackBar("Page No Required");
      return;
    }
    addToc();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    futureToc = getToc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(
        title: "Add TOC",
        onPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => AddMultipleToc(
                        bookId: widget.bookId,
                      )));
        },
        icon: Icons.add,
      ),
      body: Column(
        children: [
          MyTextField(
            hintText: "Content Name",
            controller: contentController,
          ),
          MyTextField(
            hintText: "Page No",
            controller: pageController,
            inputType: TextInputType.number,
          ),
          MyTextField(
            hintText: "Key Words",
            controller: keywordController,
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 30, 20, 50),
            child: MyButton(
              width: double.infinity,
              height: 40,
              text: "Add Content",
              onPressed: () {
                addToc();
              },
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                color: Color(backgroundColor),
              ),
              // height: MediaQuery.of(context).size.height * 0.5215,
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<TocModel>>(
                      future: futureToc,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.active ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No data available'),
                          );
                        } else {
                          tocList = snapshot.data!;

                          return ListView.builder(
                            itemCount: tocList.length,
                            itemBuilder: (context, index) {
                              return TocTile(
                                onAdd: (id) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return myDialogAddToc(id);
                                    },
                                  );
                                },
                                // onEdit: (id) {

                                // },
                                onDelete: (id) {
                                  removeToc(id, index);
                                },
                                toc: tocList[index],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MyDialog myDialogAddToc(int id) {
    TextEditingController subTocController = TextEditingController();
    TextEditingController pageNoController = TextEditingController();
    return MyDialog(
      title: "Add Sub TOC",
      btncount: 2,
      okbtn: "Add",
      cancelBtn: "Cancel",
      functionOkbtn: () async {
        if (subTocController.text.trim().isEmpty) {
          showSnackBar("Content Name Required");
        } else if (pageNoController.text.trim().isEmpty) {
          showSnackBar("Page No Required");
        } else {
          await addToc(
            content: subTocController.text.trim(),
            pageNo: pageNoController.text.trim(),
            subTocId: id,
          );
          Navigator.pop(context);
        }
      },
      child: SizedBox(
        height: 104,
        child: Column(
          children: [
            TextField(
              controller: subTocController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                label: Text(
                  "Sub Toc",
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 10),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextField(
              controller: pageNoController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text(
                  "Page No",
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 10),
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
  }
}

class TocTile extends StatelessWidget {
  const TocTile(
      {super.key,
      required this.onAdd,
      // required this.onEdit,
      required this.onDelete,
      required this.toc});
  final Function(int) onDelete;
  final Function(int) onAdd;
  // final Function(int) onEdit;
  final TocModel toc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      child: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.538,
              child: Text(
                toc.tocContent!,
                overflow: TextOverflow.ellipsis,
              )),
          // IconButton(
          //     onPressed: () {
          //       onEdit(toc.tocId!);
          //     },
          //     icon: const Icon(
          //       Icons.edit,
          //       color: Color(iconColor),
          //     )),
          IconButton(
              onPressed: () {
                onDelete(toc.tocId!);
              },
              icon: const Icon(
                Icons.delete,
                color: Color(iconColor),
              )),
          IconButton(
            onPressed: () {
              onAdd(toc.tocId!);
            },
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(iconColor),
            ),
          ),
        ],
      ),
    );
  }
}
