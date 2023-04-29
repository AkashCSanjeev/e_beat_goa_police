import 'dart:convert';

import 'package:e_beat/screens/User/route_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../components/my_button.dart';

class CreateRoute extends StatefulWidget {
  const CreateRoute({super.key});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '1234';
  List<dynamic> _placesList = [];

  List<String> locations = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller.addListener(() {
      onChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Search Places"),
          ),
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.greenAccent,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_placesList[index]['description']),
                    onTap: () {
                      String selected = _placesList[index]['description'];
                      locations.add(selected);
                      _controller.clear();
                      print(selected);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 50,
                    thickness: 1,
                    color: Colors.black,
                  );
                },
                itemCount: _placesList.length),
          ),
          SizedBox(
            height: 60,
          ),
          Row(
            children: [
              Expanded(
                  child: OverviewBtn(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RouteSummary(locations);
                  }));
                },
                lable: "Start",
              )),
              Expanded(
                  child: OverviewBtn(
                onTap: null,
                lable: "Save",
              )),
            ],
          )
        ],
      ),
    );
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggesion(_controller.text);
  }

  void getSuggesion(String input) async {
    LatLng latLng = LatLng(15.4027, 74.0078);
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=AIzaSyDhw_dv7xSxPQWCQtzg6SnfuIEHpHBB_vc&sessiontoken=$_sessionToken&location=${latLng.latitude},${latLng.longitude}&components=country:in&radius=5000';

    print(request);
    var response = await http.get(Uri.parse(request));
    print(response.body.toString());
    if (response.statusCode == 200) {
      setState(() {
        _placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception('Failed to load');
    }
  }
}
