import 'dart:convert';

import 'package:e_beat/Models/choice_model.dart';
import 'package:e_beat/components/TextField.dart';
import 'package:e_beat/components/category_card.dart';
import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/User/expandedTile_locations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AreaCategory extends StatefulWidget {
  String lat, lng;
  int geoId;
  List<LatLng> location;
  AreaCategory(this.lat, this.lng, this.geoId, this.location);

  @override
  State<AreaCategory> createState() => _AreaCategoryState();
}

class _AreaCategoryState extends State<AreaCategory> {
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  TextEditingController _controllerDialogCat = TextEditingController();

  List<Choice> choices = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
  }

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
              return InkWell(
                onTap: () {
                  print(choices[index].title);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ext_tile_form(choices[index].id, widget.lat,
                        widget.lng, widget.geoId, widget.location);
                  }));
                },
                child: Center(
                  child: SelectCard(choice: choices[index]),
                ),
              );
            })),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Name Category"),
                    content: Container(
                      height: 100,
                      child: Column(
                        children: [
                          TextField(
                            controller: _controllerDialogCat,
                            decoration: InputDecoration(hintText: "Name"),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final String? action = prefs.getString('userToken');
                          final String? grpId = prefs.getString('userGrpId');
                          var response = await post(
                            Uri.parse(
                                "https://ebeatapi.onrender.com/category/create"),
                            body: {
                              "categoryName": _controllerDialogCat.text,
                              "gid": "${grpId}",
                            },
                            headers: {'Authorization': "Bearer $action"},
                          );

                          print(response.body);

                          Navigator.of(context).pop();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AreaCategory(widget.lat, widget.lng,
                                widget.geoId, widget.location);
                          })).then((value) => {
                                setState(
                                  () {},
                                )
                              });
                        },
                        child: Text("Submit"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("cancel"),
                      ),
                    ],
                  ));
        },
        child: Text('+'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void getCategory() async {
    print("getCategory");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('userToken');
    final String? grpId = prefs.getString('userGrpId');
    var response = await get(
      Uri.parse(
          "https://ebeatapi.onrender.com/category/getgroupcategory/$grpId"),
      headers: {'Authorization': "Bearer $action"},
    );
    for (var i = 0; i < jsonDecode(response.body)['data'].length; i++) {
      choices.add(Choice(jsonDecode(response.body)['data'][i]['categoryName'],
          jsonDecode(response.body)['data'][i]['_id']));
    }

    print(response.body);
    print("Perf" + prefs.getStringList('placeIds').toString());
    setState(() {});
  }
}
