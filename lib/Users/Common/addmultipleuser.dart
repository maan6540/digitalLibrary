import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/edituserdialog.dart';
import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as e;
import 'dart:io';
import 'package:http/http.dart' as http;

class AddMultipleUsers extends StatefulWidget {
  const AddMultipleUsers({super.key});

  @override
  State<AddMultipleUsers> createState() => _AddMultipleUsersState();
}

class _AddMultipleUsersState extends State<AddMultipleUsers> {
  String file = "No File Selected";
  List<BulkUserModel> users = [];
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
    } else {
      // User canceled the picker
    }
  }

  void readExcelFile(String filePath) {
    users.clear();
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    // print(bytes);
    var excel = e.Excel.decodeBytes(bytes);

    var sheet =
        excel.tables.keys.elementAt(2); // Assuming data is in the third sheet

    if (excel.tables.containsKey(sheet)) {
      var table = excel.tables[sheet];
      for (var row in table!.rows.skip(1)) {
        // Skip header row
        // Extract cell values
        var username = row[0]?.value.toString();
        var password = row[1]?.value.toString();
        var role = row[2]?.value.toString();
        var department = row[3]?.value.toString();
        var name = row[4]?.value.toString();
        var phoneNo = row[5]?.value.toString();

        // Create BulkUserModel instance and add to list
        var user = BulkUserModel(
          username: username,
          password: password,
          role: role,
          department: department,
          name: name,
          phoneNo: phoneNo,
        );
        users.add(user);
      }
      setState(() {});
    } else {
      showSnackBar("Sheet not found");
    }
  }

  Future<void> addUsers() async {
    String url = "$baseUrl/user/RegisterUsers";
    try {
      List<Map<String, dynamic>> usersJson =
          users.map((user) => user.toJson()).toList();
      var response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(usersJson));

      List<dynamic> responseBody = jsonDecode(response.body);

      // Update users with response data
      for (var responseItem in responseBody) {
        var username = responseItem['username'];
        var user = users.firstWhere((user) => user.username == username);
        user.status = responseItem['status'];
        user.message = responseItem['message'];
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EditUserDialog(
          user: users[index],
          onConfirm: (updatedUser) {
            setState(() {
              users[index] = updatedUser;
            });
          },
        );
      },
    );
  }

  void clearRegisteredUsers() {
    setState(() {
      users.removeWhere((user) => user.status == 'Success');
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
      appBar: const MyAppBar(title: "Add Multiple Users"),
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
                          clearRegisteredUsers();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      MyButton(
                        text: "Clear All",
                        onPressed: () {
                          users.clear();
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return BulkUserTile(
                          name: users[index].name!,
                          username: users[index].username!,
                          status: users[index].status,
                          message: users[index].message,
                          onDelete: () {
                            setState(() {
                              users.removeAt(index);
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
              height: 16,
            ),
            MyButton(
              onPressed: () {
                addUsers();
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

class BulkUserTile extends StatelessWidget {
  const BulkUserTile({
    super.key,
    required this.onDelete,
    required this.onEdit,
    required this.name,
    required this.username,
    this.status,
    this.message,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String name;
  final String username;
  final String? status;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
      height: 120,
      decoration: BoxDecoration(
          color: const Color(backgroundColor),
          borderRadius: BorderRadius.circular(25)),
      child: Row(
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
              Text(username),
              if (status != null && message != null) ...[
                const SizedBox(height: 10),
                Text('$status',
                    style: TextStyle(
                        color:
                            status == 'Success' ? Colors.green : Colors.red)),
                Text('$message',
                    style: TextStyle(
                        color:
                            status == 'Success' ? Colors.green : Colors.red)),
              ],
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
              icon: const Icon(Icons.delete)),
        ],
      ),
    );
  }
}

class BulkUserModel {
  String? username;
  String? password;
  String? role;
  String? department;
  String? name;
  String? phoneNo;
  String? status;
  String? message;

  BulkUserModel(
      {this.username,
      this.password,
      this.role,
      this.department,
      this.name,
      this.phoneNo,
      this.status,
      this.message});

  BulkUserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    role = json['role'];
    department = json['department'];
    name = json['name'];
    phoneNo = json['phoneNo'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['role'] = role;
    data['department'] = department;
    data['name'] = name;
    data['phoneNo'] = phoneNo;
    return data;
  }
}
