import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentLogs extends StatefulWidget {
  const StudentLogs({super.key, required this.studentId, required this.regNo});
  final int studentId;
  final String regNo;

  @override
  State<StudentLogs> createState() => _StudentLogsState();
}

class _StudentLogsState extends State<StudentLogs> {
  late Future<List<LogsModel>> futureLogs;
  List<LogsModel> logs = [];
  String message = "";

  Future<List<LogsModel>> getLogs() async {
    String url =
        "$baseUrl/Logs/getLogs?studentId=${widget.studentId}&type=Book";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody['status'] == "Success") {
          List<dynamic> responsedata = responsebody['data'];
          var data = responsedata.map((e) => LogsModel.fromJson(e)).toList();
          return data;
        } else {
          message = responsebody["message"];
        }
      } else {
        message = "Error : ${response.statusCode}";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  void initState() {
    futureLogs = getLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.regNo),
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            logs = snapshot.data!;
            if (logs.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return const ListTile(
                title: Text("Book"),
              );
            }
          }
        },
      ),
    );
  }
}
