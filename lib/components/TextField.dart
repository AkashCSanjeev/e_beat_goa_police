import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final controller;
  final icon;
  final inputType;
  final String hintText;
  final bool obscureText;

  const LoginTextField(
      {super.key,
      required this.controller,
      required this.icon,
      required this.inputType,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          border: InputBorder.none,
          // icon: icon,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Colors.blue.shade300,
              )),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
            ),
          ),
          fillColor: Color.fromRGBO(254, 243, 243, 1),
          filled: true,
        ),
      ),
    );
  }
}
