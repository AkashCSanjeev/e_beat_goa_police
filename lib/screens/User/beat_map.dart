import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_beat/screens/User/beat_location_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

class UserMap extends StatefulWidget {
  List<LatLng> location;
  UserMap(this.location);

  @override
  State<UserMap> createState() => _UserMapState(location);
}

class _UserMapState extends State<UserMap> {
  final loc.Location currentLoc = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  List<LatLng> location;
  _UserMapState(this.location);

  LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBioMetrics = false;
  List<BiometricType> _availableBiometrics = [];
  String autherized = 'no';

  Future<void> _checkBiometrics() async {
    bool canCheckBioMetrics = false;
    try {
      canCheckBioMetrics = await auth.canCheckBiometrics;
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      _canCheckBioMetrics = canCheckBioMetrics;
    });
  }

  Future<void> _getAvailableBiometric() async {
    List<BiometricType> availableBiometrics = [];

    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate(lat, lng, geoId) async {
    bool authenticate = false;
    try {
      authenticate =
          await auth.authenticate(localizedReason: "Scan you finger");
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    setState(() {
      autherized = authenticate ? "Success" : "failed";
      print(autherized);
    });
    if (autherized == "Success") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        trigger = false;
        return AreaCategory(lat, lng, geoId, location);
      }));
    }
  }

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(15.4027, 74.0078),
    zoom: 14,
  );

  Set<Polyline> polylines = {};
  Set<Marker> _markers = {};

  List<LatLng> bounds = [LatLng(15.4027, 74.0078), LatLng(15.4027, 74.0078)];

  final _geofenceStreamController = StreamController<Geofence>();

  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  final List<Geofence> _geofenceList = [];
  Set<Circle> fence = {};
  bool trigger = false;
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()['id']}');
    print(
        'geofence full: ${geofence.toJson()['latitude']} ${geofence.toJson()['longitude']}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);

    if (geofenceStatus == GeofenceStatus.ENTER && trigger == false) {
      trigger = true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(days: 365),
        content: Text("Reached"),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'verify',
            onPressed: () {
              print("Clicked");
              _authenticate(
                  "${geofence.toJson()['latitude']}",
                  "${geofence.toJson()['longitude']}",
                  int.parse(geofence.toJson()['id']));
            }),
      ));
    }
  }

  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    _requestLocationPermission();

    _getLocation();
    _listenToLocation();

    for (int i = 0; i < location.length; i++) {
      var value = Geofence(
        id: '$i',
        latitude: location[i].latitude,
        longitude: location[i].longitude,
        radius: [
          // GeofenceRadius(id: 'radius_25m', length: 25),
          GeofenceRadius(id: 'radius_100m', length: 100),
          // GeofenceRadius(id: 'radius_200m', length: 200),
        ],
      );
      var circle = Circle(
        circleId: CircleId("$i"),
        center: LatLng(location[i].latitude, location[i].longitude),
        radius: 100,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
      );
      _geofenceList.add(value);
      fence.add(circle);
    }
    _checkBiometrics();
    _getAvailableBiometric();

    if (_geofenceList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _geofenceService
            .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
        // _geofenceService.addLocationChangeListener(_onLocationChanged);
        // _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
        // _geofenceService.addActivityChangeListener(_onActivityChanged);
        // _geofenceService.addStreamErrorListener(_onError);
        _geofenceService.start(_geofenceList).catchError(_onError);
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    print("permisions");
    final permissionStatus = Permission.location.request();
    print(permissionStatus.toString());
    print(permissionStatus == PermissionStatus.granted);

    return permissionStatus == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        polylines: polylines,
        minMaxZoomPreference: MinMaxZoomPreference(14, 20),
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
        circles: fence,
        cameraTargetBounds: new CameraTargetBounds(
          new LatLngBounds(
            northeast: bounds[0],
            southwest: bounds[1],
          ),
        ),
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
    bounds[0] = LatLng(json['routes'][0]['bounds']['northeast']['lat'],
        json['routes'][0]['bounds']['northeast']['lng']);
    bounds[1] = LatLng(json['routes'][0]['bounds']['southwest']['lat'],
        json['routes'][0]['bounds']['southwest']['lng']);

    polylines.add(Polyline(
        polylineId: PolylineId("1"),
        points: pointss.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color:
            Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        width: 4));

    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _geofenceService
        .removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.stop();
    print("disposed");

    _stopListening();

    super.dispose();
  }

  _getLocation() async {
    try {
      print("Get location");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? grpId = prefs.getString('userGrpId');
      final String? userDet = prefs.getString('userDetails');

      final loc.LocationData _locationResult = await currentLoc.getLocation();

      await FirebaseFirestore.instance
          .collection('BeatGroups')
          .doc(grpId)
          .collection("location")
          .doc('${jsonDecode(userDet!)['data'][0]['user']['_id']}')
          .set({
        'Role': jsonDecode(userDet)['data'][0]['user']['role'],
        'name': jsonDecode(userDet)['data'][0]['user']['name'],
        'officerID': jsonDecode(userDet)['data'][0]['user']['_id'],
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
      });
    } catch (e) {
      print(e);
    }
  }

  _listenToLocation() async {
    print("Listen to location");
    _locationSubscription = currentLoc.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData curLoc) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final loc.LocationData _locationResult = await currentLoc.getLocation();
      final String? grpId = prefs.getString('userGrpId');
      final String? userDet = prefs.getString('userDetails');
      await FirebaseFirestore.instance
          .collection('BeatGroups')
          .doc(grpId)
          .collection("location")
          .doc('${jsonDecode(userDet!)['data'][0]['user']['_id']}')
          .set({
        'Role': jsonDecode(userDet)['data'][0]['user']['role'],
        'name': jsonDecode(userDet)['data'][0]['user']['name'],
        'officerID': jsonDecode(userDet)['data'][0]['user']['_id'],
        'latitude': curLoc.latitude,
        'longitude': curLoc.longitude,
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }
}
