// TODO: Set up Query

import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/beat_admin.dart';
import 'package:e_beat/screens/beat_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteSummary extends StatelessWidget {
  List<String> location;
  RouteSummary(this.location);
  String url = 'tel:+919422441471';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 25, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return BeatAdmin();
                        }));
                      },
                      backgroundColor: Colors.amber,
                      child: Icon(
                        Icons.perm_identity,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Route",
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
              Text(
                "Overview",
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 300,
                    height: 350,
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(location[index]),
                            trailing: Checkbox(
                              value: false,
                              onChanged: null,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 50,
                            thickness: 1,
                            color: Colors.amber,
                          );
                        },
                        itemCount: location.length),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: OverviewBtn(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return UserMap();
                      }));
                    },
                    lable: "Start",
                  )),
                  Expanded(
                      child: OverviewBtn(
                    onTap: () async {
                      final Uri url = Uri(scheme: 'tel', path: '9422441471');

                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        print('error');
                      }
                    },
                    lable: "Query",
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
