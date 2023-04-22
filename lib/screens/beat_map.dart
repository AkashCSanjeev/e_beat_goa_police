import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class UserMap extends StatefulWidget {
  List<LatLng> location;
  UserMap(this.location);

  @override
  State<UserMap> createState() => _UserMapState(location);
}

class _UserMapState extends State<UserMap> {
  List<LatLng> location;
  _UserMapState(this.location);

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.4027, 74.0078),
    zoom: 14,
  );

  // List<LatLng> latlng = [];
  Set<Polyline> polylines = {};
  Set<Marker> _markers = {};
  // int count = 0;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        polylines: polylines,
        zoomControlsEnabled: false,
        initialCameraPosition: _kGooglePlex,
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (controller) {
          _addMarker(location);
          _controller.complete(controller);
        },
        markers: _markers,
        onLongPress: null,
      ),
    );
  }

  void _addMarker(List<LatLng> pos) {
    for (int i = 0; i < pos.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId("$i"),
          icon: BitmapDescriptor.defaultMarker,
          position: pos[i],
        ),
      );
      setState(() {
        if (pos.length > 1) {
          drawPolyLine();
        }
      });
    }
  }

  void drawPolyLine() async {
    var waypoints = location.sublist(1, location.length - 1);
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${location[0].latitude},${location[0].longitude}',
        'destination':
            '${location[location.length - 1].latitude},${location[location.length - 1].longitude}',
        'waypoints': waypoints
            .map((latlng) =>
                "${latlng.latitude.toString()},${latlng.longitude.toString()}")
            .join('|'),
        'mode': 'driving',
        'key': 'AIzaSyDhw_dv7xSxPQWCQtzg6SnfuIEHpHBB_vc',
      },
    );
    print(url);
    final response = await http.get(url);
    final body = response.body;
    final json = jsonDecode(body);

    List<PointLatLng> pointss = PolylinePoints()
        .decodePolyline(json['routes'][0]['overview_polyline']['points']);

    polylines.add(Polyline(
        polylineId: PolylineId("1"),
        points: pointss.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color:
            Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        width: 4));

    setState(() {});
  }
}
