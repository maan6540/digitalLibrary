import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/CustomWidgets/mytextfield.dart';
import 'package:digitallibrary/Users/Common/addmultipleuser.dart';
import 'package:flutter/material.dart';

class EditUserDialog extends StatefulWidget {
  final BulkUserModel user;
  final Function(BulkUserModel) onConfirm;

  const EditUserDialog(
      {required this.user, required this.onConfirm, super.key});

  @override
  EditUserDialogState createState() => EditUserDialogState();
}

class EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController roleController;
  late TextEditingController departmentController;
  late TextEditingController nameController;
  late TextEditingController phoneNoController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    passwordController = TextEditingController(text: widget.user.password);
    roleController = TextEditingController(text: widget.user.role);
    departmentController = TextEditingController(text: widget.user.department);
    nameController = TextEditingController(text: widget.user.name);
    phoneNoController = TextEditingController(text: widget.user.phoneNo);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    roleController.dispose();
    departmentController.dispose();
    nameController.dispose();
    phoneNoController.dispose();
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
        widget.onConfirm(
          BulkUserModel(
            username: usernameController.text,
            password: passwordController.text,
            role: roleController.text,
            department: departmentController.text,
            name: nameController.text,
            phoneNo: phoneNoController.text,
          ),
        );
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            MyTextField(controller: nameController, hintText: "Name"),
            // MyTextField(controller: roleController, hintText: "Role"),
            // MyTextField(
            //     controller: departmentController, hintText: "Department"),
            MyTextField(controller: phoneNoController, hintText: "Phone No"),
            MyTextField(controller: usernameController, hintText: "Username"),
            MyTextField(
              pwd: true,
              controller: passwordController,
              hintText: "Password",
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }
}
