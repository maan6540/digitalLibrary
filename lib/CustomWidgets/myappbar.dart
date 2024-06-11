// ignore_for_file: use_build_context_synchronously

import 'package:digitallibrary/CustomWidgets/mydialog.dart';
import 'package:digitallibrary/Users/Common/login.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar(
      {super.key,
      required this.title,
      this.height = 60,
      this.onPress,
      this.icon});
  final double? height;
  final String title;
  final IconData? icon;
  final VoidCallback? onPress;

  Future<void> logout(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("role", "");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) =>
          false, // This predicate function will remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(mainColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      actions: [
        if (onPress != null && icon != null)
          IconButton(
              onPressed: () {
                onPress!();
              },
              icon: Icon(
                icon,
                color: Colors.white,
              )),
        IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (builder) {
                    return MyDialog(
                      icon: Icons.warning,
                      title: "Logout",
                      content: "Are you sure to logout",
                      cancelBtn: "No",
                      okbtn: "Yes",
                      functionOkbtn: () async {
                        await logout(context);
                        // Navigator.pop(context);
                      },
                      btncount: 2,
                    );
                  });
            },
            icon: const Icon(
              Icons.login,
              color: Colors.white,
            ))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
