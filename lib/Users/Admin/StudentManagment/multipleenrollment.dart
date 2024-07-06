import 'dart:convert';
import 'dart:io';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';

import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as e;
import 'package:http/http.dart' as http;

class MultipleEnrollment extends StatefulWidget {
  const MultipleEnrollment({super.key});

  @override
  State<MultipleEnrollment> createState() => _MultipleEnrollmentState();
}

class _MultipleEnrollmentState extends State<MultipleEnrollment> {
  String file = "No File Selected";
  String? filePath;
  List<EnrollmentModel> enrollments = [];

  Future<void> enrollStudents() async {
    String url = "$baseUrl/enrollment/multipleEnroll";
    try {
      List<Map<String, dynamic>> usersJson =
          enrollments.map((e) => e.toJson()).toList();
      var response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(usersJson));

      List<dynamic> responseBody = jsonDecode(response.body);

      // Update users with response data
      for (var responseItem in responseBody) {
        var regNo = responseItem['regNo'];
        var user = enrollments.firstWhere((e) => e.regNo == regNo);
        user.status = responseItem['status'];
        user.message = responseItem['message'];
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        file = result.files.single.name;
        filePath = result.files.single.path;
      });
    }
  }

  void readExcelFile(String filePath) {
    enrollments.clear();
    try {
      var file = File(filePath);

      if (!file.existsSync()) {
        debugPrint("File does not exist");
        return;
      }

      var bytes = file.readAsBytesSync();
      var excel = e.Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        debugPrint("Excel file has no tables");
        return;
      }

      var sheet =
          excel.tables.keys.elementAt(3); // Assuming data is in the third sheet
      if (!excel.tables.containsKey(sheet)) {
        debugPrint("Sheet not found");
        return;
      }

      var table = excel.tables[sheet];
      var headerRow = table!.rows[0]; // Assuming the first row is the header

      Map<String, int> headerIndexes = {};
      List<String> headers = ["name", "regno", "smester", "courses"];

      for (var i = 0; i < headerRow.length; i++) {
        var cellValue = headerRow[i]?.value.toString().toLowerCase();
        if (headers.contains(cellValue)) {
          headerIndexes[cellValue!] = i;
        }
      }

      for (var header in headers) {
        if (!headerIndexes.containsKey(header)) {
          debugPrint("Header '$header' not found");
          return;
        }
      }

      for (var row in table.rows.skip(1)) {
        // Skip header row
        var regNo = row[headerIndexes["regno"]!]?.value.toString();
        var name = row[headerIndexes["name"]!]?.value.toString();
        var courses = row[headerIndexes["courses"]!]?.value.toString();
        var smesterNo = row[headerIndexes["smester"]!]?.value.toString();

        var enroll = EnrollmentModel(
            regNo: regNo,
            name: name,
            courseCode: courses,
            smesterNo: smesterNo);

        enrollments.add(enroll);
      }

      setState(() {});
    } catch (e) {
      debugPrint("Error reading excel file: $e");
    }
  }

  // void readExcelFile(String filePath) {
  //   try {
  //     var file = File(filePath);

  //     if (!file.existsSync()) {
  //       return;
  //     }

  //     var bytes = file.readAsBytesSync();
  //     var excel = e.Excel.decodeBytes(bytes);

  //     if (excel.tables.isEmpty) {
  //       return;
  //     }

  //     var sheet =
  //         excel.tables.keys.elementAt(3); // Assuming data is in the third sheet
  //     if (excel.tables.containsKey(sheet)) {
  //       var table = excel.tables[sheet];
  //       var headerRow = table!.rows[0]; // Assuming the first row is the header

  //       // Find the index of the column with the header "username"
  //       int nameIndex = headerRow.indexWhere(
  //           (cell) => cell?.value.toString().toLowerCase() == "name");
  //       int regnoIndex = headerRow.indexWhere(
  //           (cell) => cell?.value.toString().toLowerCase() == "regno");
  //       int smeseterIndex = headerRow.indexWhere(
  //           (cell) => cell?.value.toString().toLowerCase() == "smester");
  //       int coursesIndex = headerRow.indexWhere(
  //           (cell) => cell?.value.toString().toLowerCase() == "courses");

  //       if (nameIndex == -1) {
  //         debugPrint("Header 'regNo' not found");
  //         return;
  //       }
  //       if (regnoIndex == -1) {
  //         debugPrint("Header 'regNo' not found");
  //         return;
  //       }
  //       if (smeseterIndex == -1) {
  //         debugPrint("Header 'regNo' not found");
  //         return;
  //       }
  //       if (coursesIndex == -1) {
  //         debugPrint("Header 'regNo' not found");
  //         return;
  //       }

  //       for (var row in table.rows.skip(1)) {
  //         // Skip header row
  //         var regNo = row[regnoIndex]?.value.toString();
  //         var name = row[nameIndex]?.value.toString();
  //         var courses = row[coursesIndex]?.value.toString();
  //         print("$regNo $name $courses");
  //       }
  //       setState(() {});
  //     } else {
  //       debugPrint("Sheet not found");
  //     }
  //   } catch (e) {
  //     debugPrint("Error reading excel file: $e");
  //   }
  // }

  void editUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EditEnrollmentDialog(
          enrollment: enrollments[index],
          onConfirm: (updatedEnrollent) {
            setState(() {
              enrollments[index] = updatedEnrollent;
            });
          },
        );
      },
    );
  }

  void clearEnrolledStudent() {
    setState(() {
      enrollments.removeWhere((user) => user.status == 'Success');
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(title: "Multiple Enrollment"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton(
                  width: 100,
                  text: "Select File",
                  onPressed: () {
                    selectFile();
                  },
                ),
                SizedBox(
                    width: 100,
                    child: Text(
                      file,
                      overflow: TextOverflow.ellipsis,
                    )),
                MyButton(
                  width: 100,
                  text: "Load Data",
                  onPressed: () {
                    if (filePath == null) {
                      showSnackBar("Select File First");
                    } else {
                      readExcelFile(filePath!);
                    }
                  },
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: 320,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      MyButton(
                        text: "Clear",
                        onPressed: () {
                          clearEnrolledStudent();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      MyButton(
                        text: "Clear All",
                        onPressed: () {
                          enrollments.clear();
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: enrollments.length,
                      itemBuilder: (context, index) {
                        // return;
                        return BulkEnrollmentTile(
                          name: enrollments[index].name!,
                          regNo: enrollments[index].regNo!,
                          status: enrollments[index].status,
                          message: enrollments[index].message,
                          onDelete: () {
                            setState(() {
                              enrollments.removeAt(index);
                            });
                          },
                          onEdit: () {
                            editUser(index);
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            MyButton(
              onPressed: () {
                enrollStudents();
              },
              text: "Enroll Students",
              width: 300,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}

class BulkEnrollmentTile extends StatelessWidget {
  const BulkEnrollmentTile(
      {super.key,
      required this.onDelete,
      required this.onEdit,
      required this.name,
      required this.regNo,
      this.status,
      this.message});

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String name;
  final String? status;
  final String? message;
  final String regNo;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
      height: 130,
      decoration: BoxDecoration(
          color: const Color(backgroundColor),
          borderRadius: BorderRadius.circular(25)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(regNo),
                ],
              ),
              IconButton(
                  onPressed: () {
                    onEdit();
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                onPressed: () {
                  onDelete();
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          if (status != null && message != null) ...[
            // const SizedBox(height: 0),
            Text('$status',
                style: TextStyle(
                    color: status == 'Success' ? Colors.green : Colors.red)),
            SizedBox(
              width: 250,
              child: Text('$message',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: status == 'Success' ? Colors.green : Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}

class EnrollmentModel {
  String? regNo;
  String? smesterNo;
  String? courseCode;
  String? name;
  String? status;
  String? message;

  EnrollmentModel(
      {this.regNo,
      this.smesterNo,
      this.courseCode,
      this.name,
      this.status,
      this.message});

  EnrollmentModel.fromJson(Map<String, dynamic> json) {
    regNo = json['regNo'];
    smesterNo = json['smesterNo'];
    courseCode = json['courseCode'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['regNo'] = regNo;
    data['smesterNo'] = smesterNo;
    data['courseCode'] = courseCode;
    data['name'] = name;
    return data;
  }
}

class EditEnrollmentDialog extends StatefulWidget {
  const EditEnrollmentDialog(
      {super.key, required this.enrollment, required this.onConfirm});
  final EnrollmentModel enrollment;
  final Function(EnrollmentModel) onConfirm;

  @override
  State<EditEnrollmentDialog> createState() => _EditEnrollmentDialogState();
}

class _EditEnrollmentDialogState extends State<EditEnrollmentDialog> {
  late TextEditingController regNoController;
  late TextEditingController coursesController;

  @override
  void initState() {
    super.initState();
    regNoController = TextEditingController(text: widget.enrollment.regNo);
    coursesController =
        TextEditingController(text: widget.enrollment.courseCode);
  }

  @override
  void dispose() {
    regNoController.dispose();
    coursesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "Edit User",
      btncount: 2,
      cancelBtn: "Cancel",
      okbtn: "Save",
      functionOkbtn: () {
        widget.onConfirm(EnrollmentModel(
            regNo: regNoController.text.trim(),
            courseCode: coursesController.text.trim(),
            smesterNo: widget.enrollment.smesterNo,
            name: widget.enrollment.name));
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyTextField(controller: regNoController, hintText: "RegNo"),
            MyTextField(controller: coursesController, hintText: "Courses"),
          ],
        ),
      ),
    );
  }
}
