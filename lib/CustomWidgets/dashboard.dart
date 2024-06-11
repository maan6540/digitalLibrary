import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key, required this.text, required this.child});
  final String text;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      color: const Color(mainColor),
      child: (Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.05,
          ),
          Text(
            text,
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1),
          ),
          const Text(
            "Lets Start Learning",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 4),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(backgroundColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
