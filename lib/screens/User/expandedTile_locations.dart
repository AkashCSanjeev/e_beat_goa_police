import 'dart:convert';

import 'package:e_beat/Models/EachLocation.dart';
import 'package:e_beat/screens/User/create_location.dart';
import 'package:flutter/material.dart';
import 'package:e_beat/screens/User/form_gov.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ext_tile_form extends StatefulWidget {
  String catId, lat, lng;
  int geoId;
  List<LatLng> location;
  ext_tile_form(this.catId, this.lat, this.lng, this.geoId, this.location);

  @override
  _ext_tile_formState createState() => _ext_tile_formState();
}

class _ext_tile_formState extends State<ext_tile_form> {
  final List<EachLocation> _items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoationInCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Locations')),
        body: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final item = _items[index];
              return Card(
                key: PageStorageKey(item.id),
                color: Colors.blue,
                elevation: 4,
                child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.end,
                    title: Text(
                      item.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    children: [
                      // This button is used to remove this item
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FloatingActionButton.extended(
                              label: Text('Report'),
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return logIn3();
                                }));
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FloatingActionButton.extended(
                              label: Text('All Good!'),
                              icon: Icon(Icons.thumb_up),
                              onPressed: () async {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                print("Perf2" +
                                    prefs.getStringList('placeIds').toString());
                                final String? action =
                                    prefs.getString('userToken');
                                final String? grpId =
                                    prefs.getString('userGrpId');
                                final String? userResponse =
                                    prefs.getString('userDetails');
                                final String? usesrId =
                                    jsonDecode("$userResponse")['data'][0]
                                        ['user']['_id'];
                                final List<String>? placeId =
                                    prefs.getStringList('placeIds');

                                print("PlaceIds");
                                print(placeId.toString());

                                var response = await post(
                                    Uri.parse(
                                        "https://ebeatapi.onrender.com/places/verifyreached"),
                                    body: {
                                      "userid": "${usesrId}",
                                      "placeid": item.id,
                                      "gid": "${grpId}",
                                      "ltd": "${widget.lat}",
                                      "lgn": "${widget.lng}"
                                    },
                                    headers: {
                                      'Authorization': "Bearer $action"
                                    });
                                print(action);
                                print(jsonEncode({
                                  "userid": "${usesrId}",
                                  "placeid": placeId![widget.geoId],
                                  "gid": "${grpId}",
                                  "ltd": "${widget.lat}",
                                  "lgn": "${widget.lng}"
                                }).toString());
                                print(response.body);
                                if (jsonDecode(response.body)["message"] ==
                                    "Place Visited Marked") {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text("Area marked"),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text("Not present in that area"),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                }
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ]),
              );
            }),
        floatingActionButton: FloatingActionButton.large(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CreateLocation(widget.catId, widget.location);
              }));
            },
            child: Text('+'),
            backgroundColor: Colors.blue[800]));
  }

  void getLoationInCategory() async {
    String url =
        "https://ebeatapi.onrender.com/places/byarea?category=${widget.catId}&";

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? areas = prefs.getStringList('areaIds');
    final String? action = prefs.getString('userToken');
    print(areas.toString());
    for (var i = 0; i < areas!.length; i++) {
      url = url + "area=${areas[i]}&";
    }

    var response = await get(
      Uri.parse(url),
      headers: {'Authorization': "Bearer $action"},
    );
    print(url);
    print(response.body);
    print("Perf" + prefs.getStringList('placeIds').toString());

    if (jsonDecode(response.body)['message'] == "No Places Found") {
    } else {
      for (var i = 0; i < jsonDecode(response.body)['data'].length; i++) {
        _items.add(EachLocation(
            jsonDecode(response.body)['data'][i]['_id'],
            jsonDecode(response.body)['data'][i]['name'],
            LatLng(double.parse(jsonDecode(response.body)['data'][i]['ltd']),
                double.parse(jsonDecode(response.body)['data'][i]['lgn']))));
      }
    }

    setState(() {});
  }
}
