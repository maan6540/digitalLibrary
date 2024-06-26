import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/Users/Teacher/Logs/studentnamesscreen.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class StudentLogsScreen extends StatefulWidget {
  const StudentLogsScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  State<StudentLogsScreen> createState() => _StudentLogsScreenState();
}

class _StudentLogsScreenState extends State<StudentLogsScreen> {
  late Future<List<int>> futureSmesterNumbers;
  List<int> smesterNumbers = [];
  String message = "";
  Future<List<int>> getSmesterNumbers() async {
    String url =
        "$baseUrl/Logs/getSmesterNumbers?teacherId=${widget.teacherId}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody['status'] == "Success") {
          List<dynamic> responseData = responsebody['data'];
          List<int> responsedata = responseData.map((e) => e as int).toList();
          return responsedata;
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
    futureSmesterNumbers = getSmesterNumbers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: "Student Logs",
      ),
      backgroundColor: const Color(backgroundColor),
      body: FutureBuilder(
        future: futureSmesterNumbers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            smesterNumbers = snapshot.data!;
            if (smesterNumbers.isEmpty) {
              return Center(
                child: Text(message),
              );
            } else {
              return ListView.builder(
                itemCount: smesterNumbers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => StudentNamesScreen(
                              smesterNumber: smesterNumbers[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: AlignmentDirectional.centerStart,
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: SizedBox(
                            width: 200,
                            child: Text(
                              "Smester ${smesterNumbers[index]}",
                              style: const TextStyle(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
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
