import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      this.width,
      this.height,
      this.btncolor,
      this.textcolor,
      this.radius,
      this.text,
      this.onPressed,
      this.fontsize});
  final double? width, height, radius, fontsize;
  final Color? btncolor, textcolor;
  final String? text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Container(
        width: width ?? 80,
        height: height ?? 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 25)),
          color: btncolor ?? const Color(mainColor),
        ),
        child: Center(
          child: Text(
            text ?? 'Btn',
            style: TextStyle(
                fontSize: fontsize ?? 16, color: textcolor ?? Colors.white),
          ),
        ),
      ),
    );
  }
}

class MylogoutButton extends StatelessWidget {
  const MylogoutButton({super.key, required this.ftn});
  final VoidCallback ftn;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ftn,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: 300,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(mainColor)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Logout",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              width: 15,
            ),
            Icon(
              Icons.logout,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
