import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
            logs = logs.reversed.toList();
            if (logs.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return LogsTile(logs: logs[index]);
                },
              );
            }
          }
        },
      ),
    );
  }
}

class LogsTile extends StatelessWidget {
  const LogsTile({super.key, required this.logs});
  final LogsModel logs;

  @override
  Widget build(BuildContext context) {
    // DateTime startDateTime = DateTime.parse(logs.startTime!);
    // DateTime endDateTime = DateTime.parse(logs.endTime!);
    String startDate =
        DateFormat('dd-MM-yyyy').format(DateTime.parse(logs.startTime!));
    String startTime =
        DateFormat('hh:mm a').format(DateTime.parse(logs.startTime!));
    String endDate =
        DateFormat('dd-MM-yyyy').format(DateTime.parse(logs.endTime!));
    String endTime =
        DateFormat('hh:mm a').format(DateTime.parse(logs.endTime!));
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Text(
              style: const TextStyle(fontSize: 20),
              logs.itemName!,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            "<<--------⨷-------->>",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    "Start Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Date : $startDate"),
                  Text("Time : $startTime"),
                ],
              ),
              const SizedBox(
                width: 50,
              ),
              Column(
                children: [
                  const Text(
                    "End Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Date : $endDate"),
                  Text("Time : $endTime"),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
