import 'dart:io';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as e;
// import 'package:http/http.dart' as http;

class MultipleEnrollment extends StatefulWidget {
  const MultipleEnrollment({super.key});

  @override
  State<MultipleEnrollment> createState() => _MultipleEnrollmentState();
}

class _MultipleEnrollmentState extends State<MultipleEnrollment> {
  String file = "No File Selected";
  String? filePath;

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
    try {
      var file = File(filePath);

      if (!file.existsSync()) {
        return;
      }

      var bytes = file.readAsBytesSync();
      var excel = e.Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        return;
      }

      // var sheet =
      //     excel.tables.keys.elementAt(2); // Assuming data is in the third sheet
      // if (excel.tables.containsKey(sheet)) {
      //   var table = excel.tables[sheet];
      //   for (var row in table!.rows.skip(1)) {
      //     // Skip header row
      //     // Extract cell values
      //     var username = row[0]?.value.toString();
      //     var password = row[1]?.value.toString();
      //     var role = row[2]?.value.toString();
      //     var department = row[3]?.value.toString();
      //     var name = row[4]?.value.toString();
      //     var phoneNo = row[5]?.value.toString();

      //     // Create BulkUserModel instance and add to list
      //     var user = BulkUserModel(
      //       username: username,
      //       password: password,
      //       role: role,
      //       department: department,
      //       name: name,
      //       phoneNo: phoneNo,
      //     );
      //     // users.add(user);
      //   }
      //   setState(() {});
      // } else {
      //   debugPrint("Sheet not found");
      // }
    } catch (e) {
      //
    }
  }

  void editUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Container();
        // return EditUserDialog(
        //   user: users[index],
        //   onConfirm: (updatedUser) {
        //     setState(() {
        //       users[index] = updatedUser;
        //     });
        //   },
        // );
      },
    );
  }

  void clearEnrolledStudent() {
    setState(() {
      // users.removeWhere((user) => user.status == 'Success');
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      // showSnackBar("Select File First");
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
                          // clearRegisteredUsers();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      MyButton(
                        text: "Clear All",
                        onPressed: () {
                          // users.clear();
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
                      // itemCount: users.length,
                      itemBuilder: (context, index) {
                        return;
                        // return BulkUserTile(
                        //   name: users[index].name!,
                        //   username: users[index].username!,
                        //   status: users[index].status,
                        //   message: users[index].message,
                        //   onDelete: () {
                        //     setState(() {
                        //       users.removeAt(index);
                        //     });
                        //   },
                        //   onEdit: () {
                        //     // editUser(index);
                        //   },
                        // );
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
                // addUsers();
              },
              text: "Add Users",
              width: 300,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
