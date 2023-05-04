import 'dart:async';
import 'dart:convert';

import 'package:e_beat/screens/User/beat_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

class CreateLocation extends StatefulWidget {
  String catID;
  List<LatLng> location;
  CreateLocation(this.catID, this.location);

  @override
  State<CreateLocation> createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocation> {
  final loc.Location currentLoc = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  Set<Marker> _markers = {};
  late double lat, lng;
  late double Slat = 0, Slng = 0;
  late String locationText = "";
  bool firstTime = true;
  String dropdownValue = "";

  final Completer<GoogleMapController> _controller = Completer();

  late TextEditingController locNameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCameraPosition();
  }

  @override
  Widget build(BuildContext context) {
    print("build $lat $lng");
    print("build $Slat $Slng");
    locNameController = TextEditingController(text: locationText);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final List<String>? areaId = prefs.getStringList('areaIds');
          final List<String>? areaName = prefs.getStringList('areaNames');
          final Map<String, String> area = {};

          for (var i = 0; i < areaName!.length; i++) {
            area.putIfAbsent(areaName[i], () => areaId![i]);
          }

          print(area.toString());

          print(areaId.toString());
          print(areaName.toString());
          print(dropdownValue);
          if (firstTime) {
            dropdownValue = areaName.first;
            firstTime = false;
          }

          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) =>
                        AlertDialog(
                      title: const Text("Name Location"),
                      content: Container(
                        height: 100,
                        child: Column(
                          children: [
                            TextField(
                              controller: locNameController,
                              decoration: InputDecoration(hintText: "Name"),
                            ),
                            DropdownButton<String?>(
                              value: dropdownValue,
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                dropdownValue = value!;
                                print(area[value]);
                                setState(() {});
                              },
                              items: areaName.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final String? action = prefs.getString('userToken');
                            final String? grpId = prefs.getString('userGrpId');
                            print(jsonEncode({
                              "name": "${locNameController.text}",
                              "area": "${area[dropdownValue]}",
                              "category": "${widget.catID}",
                              "ltd": "${Slat}",
                              "lgn": "${Slng}"
                            }));
                            var response = await post(
                              Uri.parse(
                                  "https://ebeatapi.onrender.com/places/create"),
                              body: {
                                "name": "${locNameController.text}",
                                "area": "${area[dropdownValue]}",
                                "category": "${widget.catID}",
                                "ltd": "${Slat}",
                                "lgn": "${Slng}"
                              },
                              headers: {'Authorization': "Bearer $action"},
                            );

                            print(response.body);
                            widget.location.add(LatLng(Slat, Slng));
                            print(widget.location.toString());

                            Navigator.of(context).pop();
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return UserMap(widget.location);
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
                    ),
                  ));
        },
      ),
      body: GoogleMap(
        minMaxZoomPreference: MinMaxZoomPreference(14, 20),
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14,
        ),
        myLocationEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        onLongPress: (latLng) {
          _addMarker(latLng);
        },
        // circles: fence,
        // cameraTargetBounds: new CameraTargetBounds(
        //   new LatLngBounds(
        //     northeast: bounds[0],
        //     southwest: bounds[1],
        //   ),
        // ),
      ),
    );
  }

  void setCameraPosition() async {
    try {
      final loc.LocationData _locationResult = await currentLoc.getLocation();
      lat = _locationResult.latitude!;
      lng = _locationResult.longitude!;
    } catch (e) {
      print(e);
    }
    print("$lat $lng");
    setState(() {});
  }

  void _addMarker(LatLng pos) async {
    _markers.add(
      Marker(
        markerId: MarkerId("$lat$lng"),
        icon: BitmapDescriptor.defaultMarker,
        position: pos,
      ),
    );
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    print(
        "${jsonDecode(jsonEncode(placemarks[0]))['street']},${jsonDecode(jsonEncode(placemarks[0]))['subLocality']},");
    locationText =
        "${jsonDecode(jsonEncode(placemarks[0]))['street']},${jsonDecode(jsonEncode(placemarks[0]))['subLocality']}";
    print("${pos.latitude}, ${pos.longitude}");
    Slat = pos.latitude;
    Slng = pos.longitude;
    setState(() {});
  }
}

//  TODO: CHECK LAT LNG USING PRINT

