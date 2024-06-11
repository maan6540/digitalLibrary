import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  const MyDialog(
      {super.key,
      this.icon,
      this.title,
      this.content = "",
      this.okbtn = "",
      this.cancelBtn,
      this.btncount,
      this.child,
      this.functionOkbtn});

  final IconData? icon;
  final int? btncount;
  final String? title;
  final String? content;
  final String? okbtn, cancelBtn;
  final Function? functionOkbtn;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
      backgroundColor: const Color(mainColor),
      title: Column(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
          if (icon != null)
            const SizedBox(
              height: 5,
            ),
          if (title != null)
            Text(
              title!,
              style: const TextStyle(color: Colors.white),
            ),
          if (content != "")
            const SizedBox(
              height: 15,
            ),
          if (content != "")
            Text(
              content!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
        ],
      ),
      content: child,
      actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
      actions: [
        MyButton(
          onPressed: () {
            if (btncount == 1) {
              if (functionOkbtn != null) {
                functionOkbtn!();
              }
            } else {
              Navigator.pop(context);
            }
          },
          textcolor: const Color(mainColor),
          btncolor: Colors.white,
          text: cancelBtn ?? "OK",
        ),
        if (btncount == 2)
          MyButton(
            onPressed: () {
              if (functionOkbtn != null) {
                functionOkbtn!();
              }
            },
            textcolor: const Color(mainColor),
            btncolor: Colors.white,
            text: okbtn ?? "Ok",
          ),
      ],
    );
  }
}
