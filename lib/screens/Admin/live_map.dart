import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveMap extends StatefulWidget {
  // String user_id;
  // LiveMap(this.user_id);
  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, snapshot) {
          if (_added) {
            mymap(snapshot);
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GoogleMap(
            // polylines: polylines,
            minMaxZoomPreference: MinMaxZoomPreference(14, 20),
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              zoom: 20,
              target: LatLng(snapshot.data?.docs[0]['latitude'],
                  snapshot.data?.docs[0]['longitude']),
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
                  markerId: MarkerId('id'),
                  position: LatLng(snapshot.data?.docs[0]['latitude'],
                      snapshot.data?.docs[0]['longitude'])),
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

  Future<void> mymap(snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(snapshot.data?.docs[0]['latitude'],
          snapshot.data?.docs[0]['longitude']),
      zoom: 20,
    )));
  }
}
