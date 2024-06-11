// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class StudentReferenceMaterialSubScreen extends StatefulWidget {
  const StudentReferenceMaterialSubScreen(
      {super.key, required this.courseCode});
  final String courseCode;

  @override
  State<StudentReferenceMaterialSubScreen> createState() =>
      _StudentReferenceMaterialSubScreenState();
}

class _StudentReferenceMaterialSubScreenState
    extends State<StudentReferenceMaterialSubScreen> {
  late Future<List<ReferenceModel>> futureReferences;
  List<ReferenceModel> references = [];

  String message = '';

  Future<List<ReferenceModel>> getReferences() async {
    String url =
        "$baseUrl/Reference/getReferenceMaterial?courseCode=${widget.courseCode}";
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == "Success") {
          List<dynamic> responsedata = responseBody["data"];
          var data =
              responsedata.map((e) => ReferenceModel.fromJson(e)).toList();
          return data;
        } else {
          message = responseBody["message"];
        }
      } else {
        message = "Error ${response.statusCode}";
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      await launchUrl(url);
    } catch (e) {
      ('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error Launching URL"),
        ),
      ); // Handle the error here, e.g., show a toast or display an error message to the user
    }
  }

  @override
  void initState() {
    futureReferences = getReferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 20),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: FutureBuilder(
          future: futureReferences,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              references = snapshot.data!;
              if (references.isEmpty) {
                return Center(
                  child: Text(message),
                );
              } else {
                return ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _launchUrl(
                              Uri.parse(references[index].referenceUri!));
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          child: Text(references[index].referenceTitle!),
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
