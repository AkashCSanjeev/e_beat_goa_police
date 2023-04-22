import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class UserMap extends StatefulWidget {
  const UserMap({super.key});

  @override
  State<UserMap> createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.4027, 74.0078),
    zoom: 14,
  );

  List<LatLng> latlng = [];
  Set<Polyline> polylines = {};
  Set<Marker> _markers = {};
  int count = 0;

  List<dynamic> legs = [];

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
          _controller.complete(controller);
        },
        markers: _markers,
        onLongPress: _addMarker,
      ),
    );
  }

  void _addMarker(LatLng pos) {
    latlng.add(pos);
    _markers.add(
      Marker(
        markerId: MarkerId(count.toString()),
        icon: BitmapDescriptor.defaultMarker,
        position: pos,
      ),
    );
    count++;
    setState(() {
      if (latlng.length > 1) {
        drawPolyLine();
      }
    });
  }

  void drawPolyLine() async {
    var waypoints = latlng.sublist(1, latlng.length - 1);
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${latlng[0].latitude},${latlng[0].longitude}',
        'destination':
            '${latlng[latlng.length - 1].latitude},${latlng[latlng.length - 1].longitude}',
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
