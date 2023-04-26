import 'package:e_beat/components/TextField.dart';
import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/route_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class LogIn2 extends StatelessWidget {
  LogIn2({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 8.0,
            children: List.generate(choices.length, (index) {
              return Center(
                child: SelectCard(choice: choices[index]),
              );
            })),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        child: Text('+'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class Choice {
  const Choice({required this.title});
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Govt. Office'),
  const Choice(title: 'Medica'),
  const Choice(title: 'Education'),
  const Choice(title: 'Public Spot'),
  const Choice(title: 'Residence'),
  const Choice(title: 'Others..'),
];

class SelectCard extends StatelessWidget {
  const SelectCard({required this.choice});
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 15,
        margin: EdgeInsets.all(10),
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Center(
                        child: Text(choice.title,
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800])))),
              ]),
        ));
  }
}
