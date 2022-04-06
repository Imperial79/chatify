import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

InputDecoration textFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey.withOpacity(0.5),
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide.none,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide.none,
    ),
  );
}

AppBar customAppBar(String text, context) {
  return AppBar(
    elevation: 0,
    backgroundColor: Color(0xff00635a),
    title: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
    ),
  );
}
