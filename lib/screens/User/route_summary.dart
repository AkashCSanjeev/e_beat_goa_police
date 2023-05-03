import 'dart:convert';
import 'dart:ffi';

import 'package:e_beat/Models/created_route_model.dart';
import 'package:e_beat/components/my_button.dart';
import 'package:e_beat/screens/User/beat_admin.dart';
import 'package:e_beat/screens/User/beat_map.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteSummary extends StatefulWidget {
  List<Area> location;

  RouteSummary(this.location);

  @override
  State<RouteSummary> createState() => _RouteSummaryState();
}

class _RouteSummaryState extends State<RouteSummary> {
  List<LatLng> locationLatLng = [];

  String url = 'tel:+919422441471';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // storeAreaId();
    getLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 8, 25, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BeatAdmin();
                      }));
                    },
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Text(
              "Route Overview",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            Text("Select a starting and ending point of your journey"),
            SizedBox(
              height: 60,
            ),
            Card(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    width: 300,
                    height: 350,
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(widget.location[index].name),
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
                        itemCount: widget.location.length),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Spacer(),
            Column(
              children: [
                OverviewBtn(
                  onTap: () async {
                    // for (var i = 0; i < widget.location.length; i++) {
                    //   List<Location> latLng =
                    //       await locationFromAddress(widget.location[i].city);
                    //   locationLatLng.add(LatLng(
                    //       latLng.last.latitude, latLng.last.longitude));
                    // }
                    storeAreaId();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserMap(locationLatLng);
                    }));
                  },
                  lable: "Start",
                ),
                SizedBox(
                  height: 20,
                ),
                OverviewBtn(
                  onTap: () async {
                    final Uri url = Uri(scheme: 'tel', path: '9422441471');

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print('error');
                    }
                  },
                  lable: "Query",
                ),
                SizedBox(
                  height: 30,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void getLatLng() async {
    print("started");
    String uri = "https://ebeatapi.onrender.com/places/areaplace?";
    for (var i = 0; i < widget.location.length; i++) {
      uri = uri + "area=${widget.location[i].id}&";
    }

    print(uri);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('userToken');
    List<String> placeId = [];

    var response = await get(
      Uri.parse(uri),
      headers: {'Authorization': "Bearer $action"},
    );

    for (var i = 0; i < jsonDecode(response.body)['data'].length; i++) {
      locationLatLng.add(LatLng(
          double.parse(jsonDecode(response.body)['data'][i]['ltd']),
          double.parse(jsonDecode(response.body)['data'][i]['lgn'])));
      placeId.add(jsonDecode(response.body)['data'][i]['_id']);
    }
    print(locationLatLng.toString());
    print(placeId.toString());
    await prefs.setStringList('placeIds', placeId);
    print("Perf" + prefs.getStringList('placeIds').toString());
  }

  void storeAreaId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> areaId = [];
    List<String> areaName = [];
    for (var i = 0; i < widget.location.length; i++) {
      areaId.add(widget.location[i].id);
      areaName.add(widget.location[i].name);
    }
    print(areaId.toString());
    print(areaName.toString());
    await prefs.setStringList('areaIds', areaId);
    await prefs.setStringList('areaNames', areaName);
    print(prefs.getStringList('areaIds').toString());
  }
}
