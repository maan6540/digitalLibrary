import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mydropdown.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class ViewPdfFileScreen extends StatefulWidget {
  const ViewPdfFileScreen({
    super.key,
    required this.path,
    required this.name,
    this.pageNo,
    this.studentId = 0,
    this.user = "Admin",
    this.itemId = 0,
    this.screenof = "Book",
  });
  final String path;
  final int? itemId;
  final String name;
  final int? pageNo;
  final int? studentId;
  final String? user;
  final String? screenof;

  @override
  ViewPdfFileScreenState createState() => ViewPdfFileScreenState();
}

class ViewPdfFileScreenState extends State<ViewPdfFileScreen>
    with WidgetsBindingObserver {
  late PdfViewerController _pdfViewerController;

  String startTime = "";

  void createLog() async {
    if (DateTime.now().difference(DateTime.parse(startTime)) <
            const Duration(seconds: 10) &&
        widget.user == "Student") {
      return;
    }
    if (widget.itemId == 0) {
      return;
    }

    try {
      String url = "$baseUrl/Logs/createLog";
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          {
            "type": "Start",
            "studentId": widget.studentId,
            "logItemType": widget.screenof,
            "logItemId": widget.itemId,
            "actionPerformed": "Reading",
            "startTime": startTime,
            "endTime": DateTime.now().toString(),
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody['status'] == "Success") {
          debugPrint("Log Created");
          const Duration(seconds: 3);
          startTime = DateTime.now().toString();
        } else {
          debugPrint("Error : ${responsebody['message']}");
        }
      } else {
        debugPrint("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    startTime = DateTime.now().toString();
    _pdfViewerController = PdfViewerController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    createLog();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    createLog();
    if (AppLifecycleState.resumed == state) {
      startTime = DateTime.now().toString();
      print(startTime);
    }
    // switch (state) {
    //   case AppLifecycleState.inactive:
    //     print("ViewPdfFileScreen is inactive");
    //     break;
    //   case AppLifecycleState.paused:
    //     print("ViewPdfFileScreen is paused");
    //     createLog();
    //     break;
    //   case AppLifecycleState.resumed:
    //     print("ViewPdfFileScreen is resumed");
    //     break;
    //   case AppLifecycleState.detached:
    //     print("ViewPdfFileScreen is detached");
    //     break;
    // }
  }

  Future<void> addHighlight(
      int pageNo, String text, String publicPrivate) async {
    String url = "$baseUrl/Highlight/createHighlight";
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          {
            "studentId": widget.studentId,
            "highlightdItemType": widget.screenof,
            "highlightItemId": widget.itemId,
            "highlightType": publicPrivate,
            "highlightName": text,
            "pageNo": pageNo
          },
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

  void showdialog(int pageNo) {
    TextEditingController highlightController = TextEditingController();
    String publicPrivate = '';
    showDialog(
      context: context,
      builder: (context) {
        return MyDialog(
          title: "Add Highlight",
          okbtn: "Add",
          cancelBtn: "Cancel",
          btncount: 2,
          functionOkbtn: () {
            if (highlightController.text.trim().isEmpty) {
              showSnackBar("Add Highlight Name First");
            } else if (publicPrivate.trim().isEmpty) {
              showSnackBar("Select Public or Private");
            } else {
              addHighlight(
                  pageNo, highlightController.text.trim(), publicPrivate);
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
                const SizedBox(
                  height: 10,
                ),
                MyDropDown(
                    width: double.infinity,
                    backgroundColor: const Color(mainColor),
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    data: const ["Public", "Private"],
                    onSelected: (p0) {
                      publicPrivate = p0;
                    },
                    clearSelectedValueCallback: (f) {})
              ],
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.name,
        isNotPdf: "No",
      ),
      body: GestureDetector(
        onDoubleTap: () {
          if (widget.user == "Student") {
            showdialog(_pdfViewerController.pageNumber);
          }
        },
        child: SfPdfViewer.network(
          enableTextSelection: false,
          enableDoubleTapZooming: false,
          widget.path,
          controller: _pdfViewerController,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            if (widget.pageNo != null) {
              _pdfViewerController.jumpToPage(widget.pageNo!);
            }
          },
        ),
      ),
    );
  }
}
