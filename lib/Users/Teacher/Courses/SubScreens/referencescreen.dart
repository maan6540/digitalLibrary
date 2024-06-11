// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CourseReferencesScreen extends StatefulWidget {
  const CourseReferencesScreen({
    super.key,
    required this.courseCode,
    required this.id,
    this.user = "Teacher",
  });

  final String courseCode;
  final int id;

  final String? user;

  @override
  State<CourseReferencesScreen> createState() => _CourseReferencesScreenState();
}

class _CourseReferencesScreenState extends State<CourseReferencesScreen> {
  late Future<List<ReferenceModel>> futureReferences;
  List<ReferenceModel> references = [];
  TextEditingController referenceNameController = TextEditingController();
  TextEditingController referenceLinkController = TextEditingController();
  String screenType = '';
  String message = '';
  int referenceId = 0;

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

  Future<void> addReference() async {
    String url = "$baseUrl/Reference/addReferenceMaterial";
    try {
      var response = await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "referenceTitle": referenceNameController.text.trim(),
            "referenceUri": referenceLinkController.text.trim(),
            "courseCode": widget.courseCode,
            "uploaderId": widget.id,
            "uploaderType": widget.user!
          }));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          futureReferences = getReferences();
          referenceLinkController.clear();
          referenceNameController.clear();
          setState(() {});
          showSnackBar("Reference Added");
        } else {
          showSnackBar(responsebody["message"]);
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateReference() async {
    String url = "$baseUrl/Reference/updateReferenceMaterial";
    try {
      var response = await http.put(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "referenceId": referenceId,
            "referenceTitle": referenceNameController.text.trim(),
            "referenceUri": referenceLinkController.text.trim()
          }));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          futureReferences = getReferences();
          referenceLinkController.clear();
          referenceNameController.clear();
          referenceId = 0;
          setState(() {});
          showSnackBar(responsebody["message"]);
        } else {
          showSnackBar(responsebody["message"]);
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      screenType = "";
    });
  }

  Future<void> deleteReference(int id, int index) async {
    String url = "$baseUrl/Reference/removeReferenceMaterial?referenceId=$id";
    try {
      var response = await http.delete(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          references.removeAt(index);
          setState(() {});
          showSnackBar("Reference Removed");
        } else {
          showSnackBar(responsebody["message"]);
        }
      } else {
        showSnackBar("Error : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            MyTextField(
              hintText: "Reference Name",
              controller: referenceNameController,
            ),
            MyTextField(
              hintText: "Reference Link",
              controller: referenceLinkController,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: MyButton(
                width: double.infinity,
                height: 40,
                text: screenType != "Edit"
                    ? "Add Reference "
                    : "Update Reference",
                onPressed: () {
                  if (referenceNameController.text.trim().isEmpty) {
                    showSnackBar("Reference Material Name Required");
                  } else if (referenceLinkController.text.trim().isEmpty) {
                    showSnackBar("Reference Material Link Required");
                  } else {
                    if (screenType != "Edit") {
                      addReference();
                    } else {
                      updateReference();
                    }
                  }
                },
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.553,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
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
                        itemCount: references.length,
                        itemBuilder: (context, index) {
                          return ReferenceTile(
                            refernce: references[index],
                            onDelete: (p0) {
                              deleteReference(p0, index);
                            },
                            onEdit: (p0) {
                              setState(() {
                                screenType = "Edit";
                                referenceNameController.text =
                                    references[index].referenceTitle!;
                                referenceLinkController.text =
                                    references[index].referenceUri!;

                                referenceId = p0;
                              });
                            },
                          );
                        },
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReferenceTile extends StatelessWidget {
  const ReferenceTile(
      {super.key,
      required this.onEdit,
      required this.onDelete,
      required this.refernce});

  final ReferenceModel refernce;
  final Function(int) onEdit;
  final Function(int) onDelete;

  Future<void> _launchUrl(Uri url, BuildContext context) async {
    try {
      await launchUrl(url);
    } catch (e) {
      ('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Error Launching URL"))); // Handle the error here, e.g., show a toast or display an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var url = refernce.referenceUri!;
        _launchUrl(Uri.parse(url), context);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: const Color(backgroundColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 180,
              child: Text(refernce.referenceTitle!),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                onEdit(refernce.id!);
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
            IconButton(
              onPressed: () {
                onDelete(refernce.id!);
              },
              icon: const Icon(
                Icons.delete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
