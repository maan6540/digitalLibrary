import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.inputType,
    this.screenType,
    this.pwd = false,
    this.isPassword = false,
  });

  final TextInputType? inputType;
  final String hintText;
  final TextEditingController? controller;
  final String? screenType;
  final bool? isPassword;
  final bool? pwd;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isobsecure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.screenType == "Edit"
              ? Colors.grey
              : const Color(backgroundColor),
          border: Border.all(color: Colors.grey[800]!)),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.only(left: 10),
      child: TextFormField(
        obscureText: widget.isPassword == true ? isobsecure : !isobsecure,
        textInputAction: TextInputAction.next,
        controller: widget.controller,
        keyboardType: widget.inputType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          suffixIcon: widget.isPassword! && widget.pwd!
              ? InkWell(
                  onTap: () {
                    setState(() {
                      isobsecure = !isobsecure;
                    });
                  },
                  child: Icon(
                    isobsecure ? Icons.visibility : Icons.visibility_off,
                    color: const Color(iconColor),
                  ),
                )
              : Container(width: 1),
        ),
        readOnly: widget.screenType == 'Edit' ? true : false,
      ),
    );
  }
}
