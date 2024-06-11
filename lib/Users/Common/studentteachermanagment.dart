// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/Users/Admin/StudentManagment/students.dart';
import 'package:digitallibrary/Users/Admin/TeacherManagment/teacher.dart';
import 'package:digitallibrary/Users/Common/addedituser.dart';
import 'package:digitallibrary/Users/Common/addmultipleuser.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentTeacherManagmentScreen extends StatefulWidget {
  const StudentTeacherManagmentScreen({super.key, required this.user});
  final String user;

  @override
  State<StudentTeacherManagmentScreen> createState() =>
      _StudentTeacherManagmentScreenState();
}

class _StudentTeacherManagmentScreenState
    extends State<StudentTeacherManagmentScreen> {
  late Future<List<DepartmentModel>> departments;

  Future<List<DepartmentModel>> getData() async {
    String url = "$baseUrl/department/allDepartment";
    // print(url);
    try {
      var response = await http.get(Uri.parse(url), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      });
      // .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        var responsebody = jsonDecode(response.body);
        if (responsebody["status"] == "Success") {
          List<dynamic> jsonList = responsebody["data"];
          var data = jsonList.map((e) => DepartmentModel.fromJson(e)).toList();
          // await Future.delayed(const Duration(seconds: 1));
          message = "";
          return data;
        } else {
          message = responsebody["message"];
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responsebody["message"])));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      message = "Server Down";
    }
    return [];
  }

  late String message = '';
  @override
  void initState() {
    departments = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "${widget.user} Departments"),
      body: Container(
        color: const Color(backgroundColor),
        child: FutureBuilder<List<DepartmentModel>>(
          future: departments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              List<DepartmentModel> data = snapshot.data!;
              if (data.isEmpty) {
                return Center(child: Text(message));
              } else {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (widget.user == "Teacher") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => TeacherScreen(
                                        departmentId: data[index].departmentId!,
                                        departmentName:
                                            data[index].departmentName!,
                                      )));
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => StudentScreen(
                                  departmentId: data[index].departmentId!,
                                  departmentName: data[index].departmentName!),
                            ),
                          );
                        }
                      },
                      child: DepartmentTile(
                        department: data[index].departmentName!,
                        id: data[index].departmentId!,
                        onUpdate: (updatedName) {
                          // Update the department name in the list
                          setState(() {
                            data[index].departmentName = updatedName;
                          });
                        },
                        onDelete: () {
                          setState(() {
                            data.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 20,
          bottom: 30,
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(mainColor),
          child: const Icon(
            Icons.person_add_alt,
            color: Colors.white,
          ),
          onPressed: () {
            bottomSheet(context);
          },
        ),
      ),
    );
  }

  void bottomSheet(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              overlayEntry.remove();
            },
            child: Container(
              color: Colors.black54, // To give a dim background effect
            ),
          ),
          Positioned(
            bottom: 60,
            right: 50,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MyButton(
                      text: "Add Single ${widget.user}",
                      onPressed: () async {
                        overlayEntry.remove();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditUserScreen(
                              role: widget.user,
                              type: 'Add',
                            ),
                          ),
                        );
                        departments = getData();
                        setState(() {});
                      },
                      width: 170,
                      height: 40,
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Add Multiple ${widget.user}",
                      onPressed: () async {
                        overlayEntry.remove();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => const AddMultipleUsers(),
                          ),
                        );
                        departments = getData();
                        setState(() {});
                      },
                      width: 170,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlayState.insert(overlayEntry);
  }
}

class DepartmentTile extends StatefulWidget {
  const DepartmentTile({
    super.key,
    required this.department,
    required this.id,
    required this.onUpdate,
    required this.onDelete,
  });

  final String department;
  final int id;
  final Function(String) onUpdate;
  final VoidCallback onDelete;

  @override
  State<DepartmentTile> createState() => _DepartmentTileState();
}

class _DepartmentTileState extends State<DepartmentTile> {
  final TextEditingController _departmentNameController =
      TextEditingController();

  Future<void> updateDepartmentName() async {
    if (_departmentNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Department Name Required")));
      return;
    }

    String url = '$baseUrl/department/updateDepartment';
    Map<String, dynamic> requestBody = {
      "id": widget.id,
      "department": _departmentNameController.text.trim()
    };
    String requestBodyString = jsonEncode(requestBody);
    try {
      var response = await http.put(Uri.parse(url),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8"
          },
          body: requestBodyString);
      debugPrint(response.body);
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(responsedata["message"])));
        // Pass back the updated department name
        widget.onUpdate(_departmentNameController.text.trim());
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Server Down")));
      debugPrint(e.toString());
    }
  }

  Future<void> deleteDepartment() async {
    String url = '$baseUrl/department/deleteDepartment?id=${widget.id}';
    try {
      var response =
          await http.delete(Uri.parse(url), headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
      });
      if (response.statusCode == 200 || response.statusCode == 500) {
        var responseData = jsonDecode(response.body);
        showDialog(
            context: context,
            builder: (context) => MyDialog(
                icon: Icons.info,
                title: responseData["status"],
                content: responseData["message"]));
        if (responseData["status"] == "Success") {
          widget.onDelete();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Server Down")));
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _departmentNameController.text = widget.department;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
      height: 50,
      width: 50,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                widget.department,
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      backgroundColor: const Color(mainColor),
                      title: Column(
                        children: [
                          const Icon(
                            Icons.info,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "Update Department Name",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white)),
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _departmentNameController,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                            ),
                          ),
                        ],
                      ),
                      actionsPadding:
                          const EdgeInsets.only(right: 20, bottom: 20),
                      actions: [
                        MyButton(
                          onPressed: () {
                            updateDepartmentName();
                            Navigator.pop(context);
                          },
                          textcolor: const Color(mainColor),
                          btncolor: Colors.white,
                          text: "OK",
                        ),
                        MyButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          textcolor: const Color(mainColor),
                          btncolor: Colors.white,
                          text: "Cancel",
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(
                Icons.edit,
                color: Color(iconColor),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialog(
                      icon: Icons.warning,
                      title: "Confirmation",
                      content: "Are you sure to delete",
                      btncount: 2,
                      okbtn: "Yes",
                      cancelBtn: "No",
                      functionOkbtn: () {
                        deleteDepartment();
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: const Icon(
                Icons.delete,
                color: Color(iconColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DepartmentModel {
  int? departmentId;
  String? departmentName;

  DepartmentModel({this.departmentId, this.departmentName});

  DepartmentModel.fromJson(Map<String, dynamic> json) {
    departmentId = json['departmentId'];
    departmentName = json['departmentName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['departmentId'] = departmentId;
    data['departmentName'] = departmentName;
    return data;
  }
}
