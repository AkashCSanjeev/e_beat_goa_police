import 'dart:convert';
import 'dart:developer';

import 'package:e_beat/components/TextField.dart';
import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/Admin/live_map.dart';
import 'package:e_beat/screens/User/all_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatefulWidget {
  LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("Login");
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 243, 243, 1),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          // alignment: Alignment.center,
          // height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 80),
                      // height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(
                          //   height: 100,
                          // ),
                          // const Icon(
                          //   Icons.lock,
                          //   size: 100,
                          // ),
                          // const SizedBox(
                          //   height: 50,
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "Username",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          LoginTextField(
                            controller: usernameController,
                            icon: Icons.perm_identity_rounded,
                            inputType: TextInputType.emailAddress,
                            hintText: "ID ex: GOA1099",
                            obscureText: false,
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "Password",
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          LoginTextField(
                            controller: passwordController,
                            icon: Icons.password,
                            inputType: TextInputType.text,
                            hintText: "Password",
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),

                          SizedBox(
                              // height: 100,
                              ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      // height: 100,

                      child: Column(
                        children: [
                          LoginBtn(
                            onTap: () {
                              print("clicked");
                              loginData(usernameController.text,
                                  passwordController.text, context);
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "forgot Password?",
                            style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  loginData(username, password, context) async {
    var response;
    try {
      response = await post(
          Uri.parse("https://ebeatapi.onrender.com/users/login"),
          body: {"policeId": username, "password": password});
      // print(response.body.toString());
      print(response.body);
      if (jsonDecode(response.body)['message'] ==
          'User Logged In Successfully') {
        print("test");
        print(jsonDecode(response.body)['data'][0]['user']['role']);
        // Obtain shared preferences.
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save an integer value to 'counter' key.
        await prefs.setString('userDetails', response.body);
        await prefs.setString(
            'userToken', jsonDecode(response.body)['data'][0]['token']);

        if (jsonDecode(response.body)['data'][0]['user']['role'] == 'e-beat') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return AllRoutes();
          }));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return LiveMap();
          }));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Enter valid Credentials"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      print(e);
    }
  }
}
