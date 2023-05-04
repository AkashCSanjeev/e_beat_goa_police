import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveMap extends StatefulWidget {
  // String user_id;
  // LiveMap(this.user_id);
  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  String? grpId;
  List<String>? ebeatID = [];
  bool _added = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    print(grpId);
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('BeatGroups')
            .doc(grpId)
            .collection('location')
            .doc("64440d4a8b3d61f503ae9528")
            .snapshots(),
        builder: (context, snapshot) {
          if (_added) {
            mymap(snapshot);
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          print("${snapshot.data!['latitude']}");
          return GoogleMap(
            // polylines: polylines,
            minMaxZoomPreference: MinMaxZoomPreference(14, 20),
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              zoom: 20,
              target: LatLng(
                  snapshot.data!['latitude'], snapshot.data!['longitude']),
            ),
            myLocationEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
            markers: {
              Marker(
                  markerId: MarkerId('b1'),
                  position: LatLng(
                      snapshot.data!['latitude'], snapshot.data!['longitude'])),
            },
            onLongPress: null,
            // circles: fence,
            // cameraTargetBounds: new CameraTargetBounds(
            //   new LatLngBounds(
            //     northeast: bounds[0],
            //     southwest: bounds[1],
            //   ),
            // ),
          );
        },
      ),
    );
  }

  getDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userResponse = prefs.getString('userDetails');
    final action = prefs.getString('userToken');
    print(jsonDecode("$userResponse")['data'][0]['user']['_id']);

    var userGrpDetails = await get(
      Uri.parse(
          "https://ebeatapi.onrender.com/users/usergroup/${jsonDecode("$userResponse")['data'][0]['user']['_id']}"),
      headers: {'Authorization': "Bearer $action"},
    );
    print(userGrpDetails.body);
    print(jsonDecode(userGrpDetails.body)['data']['ebeats'].length);
    for (var i = 0;
        i < jsonDecode(userGrpDetails.body)['data']['ebeats'].length;
        i++) {
      ebeatID!.add("${jsonDecode(userGrpDetails.body)['data']['ebeats'][i]}");
      print("${jsonDecode(userGrpDetails.body)['data']['ebeats'][i]}");
    }
    grpId = jsonDecode(userGrpDetails.body)['data']['_id'];
    print(userGrpDetails.body);
    print(ebeatID);
    setState(() {});
  }

  Future<void> mymap(snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(snapshot.data?.docs[0]['latitude'],
          snapshot.data?.docs[0]['longitude']),
      zoom: 20,
    )));
  }
}
