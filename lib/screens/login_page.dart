import 'package:e_beat/components/TextField.dart';
import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/all_routes.dart';
import 'package:flutter/material.dart';

class LogIn extends StatelessWidget {
  LogIn({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("Login");
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 100,
              ),
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                "Welcome Back",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              LoginTextField(
                controller: usernameController,
                icon: Icon(Icons.perm_identity_rounded),
                inputType: TextInputType.emailAddress,
                hintText: "ID ex: GOA1099",
                obscureText: false,
              ),
              SizedBox(
                height: 10.0,
              ),
              LoginTextField(
                controller: passwordController,
                icon: Icon(Icons.password),
                inputType: TextInputType.text,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    "forgot Password?",
                    style: TextStyle(
                        color: Colors.blue[600], fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              SizedBox(
                height: 25.0,
              ),
              LoginBtn(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return AllRoutes();
                  }));
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
