import 'dart:convert';
import 'dart:ffi';

import 'package:e_beat/Models/created_route_model.dart';
import 'package:e_beat/screens/User/route_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:objectid/objectid.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/my_button.dart';
import 'all_routes.dart';

class CreateRoute extends StatefulWidget {
  const CreateRoute({super.key});

  @override
  State<CreateRoute> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerDialogName = TextEditingController();
  TextEditingController _controllerDialogDes = TextEditingController();
  String newVal = "";

  // var uuid = Uuid();
  // String _sessionToken = '1234';

  List<Area> locations = [];
  List<ObjectId> locationId = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _controller.addListener(() {
    //   onChange();
    // });
  }

  @override
  Widget build(BuildContext context) {
    List<Area> area = [];
    // var response  = post(Uri.parse(uri));
    // for (var i = 0; i < City().cityList.length; i++) {
    //   if(City().cityList[i].city == ){
    //     area.add(City().cityList[i]);
    //   }
    //
    String? textSelected = "";

    List<String> curRoutes = [
      "644f6c6fee60e58eb042b3ee",
      "644f6ca4ee60e58eb042b3f5",
      "644f8f18f894846c02a5d0f9"
    ];
    Map<String, dynamic> args = {
      "name": _controllerDialogName.text,
      "gid": "64444e10180bf61baeaf2d67",
      "description": _controllerDialogDes.text,
      "curRoutes": curRoutes
    };

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return AllRoutes();
          }));
        }),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          TypeAheadFormField(
              debounceDuration: Duration(milliseconds: 500),
              textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      hintText: 'Select Area')),
              onSuggestionSelected: (selectedArea) {},
              itemBuilder: (context, Area index) {
                return ListTile(
                  title: Text("${index.name}"),
                  onTap: () {
                    print(index.id);
                    locations.add(index);
                    locationId.add(ObjectId.fromHexString(index.id));
                    setState(() {});
                  },
                );
              },
              suggestionsCallback: getSuggestions),
          Container(
            width: double.infinity,
            height: 400,
            color: Colors.blueGrey,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(locations[index].name),
                    // onTap: () {
                    //   String selected = _placesList[index]['description'];

                    //   _controller.clear();
                    //   print(selected);
                    // },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 50,
                    thickness: 1,
                    color: Colors.black,
                  );
                },
                itemCount: locations.length),
          ),
          SizedBox(
            height: 100,
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
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Name the route"),
                            content: Container(
                              height: 100,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _controllerDialogName,
                                    decoration:
                                        InputDecoration(hintText: "Name"),
                                  ),
                                  TextField(
                                    controller: _controllerDialogDes,
                                    decoration: InputDecoration(
                                        hintText: "Description"),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  print("Submit Cliked");
                                  print(jsonEncode({
                                    "name": _controllerDialogName.text,
                                    "gid": "64444e10180bf61baeaf2d67",
                                    "description": _controllerDialogDes.text,
                                    "curRoutes": [
                                      "644f6c6fee60e58eb042b3ee",
                                      "644f6ca4ee60e58eb042b3f5",
                                      "644f8f18f894846c02a5d0f9"
                                    ]
                                  }).toString());
                                  print("test");
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  final String? grpId =
                                      prefs.getString('userGrpId');
                                  final String? action =
                                      prefs.getString('userToken');

                                  try {
                                    var response = await post(
                                      Uri.parse(
                                          "https://ebeatapi.onrender.com/routes/create"),
                                      body: jsonEncode(<String, dynamic>{
                                        "name": _controllerDialogName.text,
                                        "gid": "64444e10180bf61baeaf2d67",
                                        "description":
                                            _controllerDialogDes.text,
                                        "curRoutes": curRoutes
                                      }),
                                      headers: {
                                        "Content-type": "application/json",
                                        'Authorization': "Bearer $action"
                                      },
                                    );
                                    print(response.body.toString());
                                  } catch (e) {
                                    print(e);
                                  }

                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return AllRoutes();
                                  }));
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
                lable: "Save",
              )),
            ],
          )
        ],
      ),
    );
  }

  Future<List<Area>> getSuggestions(String query) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('userToken');
    final String? userResponse = prefs.getString('userDetails');
    final String? userGrpDetails = prefs.getString('userGrpDetails');

    // print("$action");
    // print("${jsonDecode("$userResponse")['data'][0]['user']['_id']}");
    // print("${userGrpDetails.body}");

    var respose = await get(
      Uri.parse(
          "https://ebeatapi.onrender.com/areas/bycity?city=${jsonDecode("$userGrpDetails")['data']['gcity']}"),
      headers: {'Authorization': "Bearer $action"},
    );
    final List area = jsonDecode(respose.body)['data'];
    print(area.toString());
    return area.map((e) => Area.fromjson(e)).where((element) {
      final nameLower = element.name.toLowerCase();
      final queryLower = query.toLowerCase();

      return nameLower.contains(queryLower);
    }).toList();
  }

  // void onChange() {
  //   if (_sessionToken == null) {
  //     setState(() {
  //       _sessionToken = uuid.v4();
  //     });
  //   }

  // getSuggesion(_controller.text);
}

// void getSuggesion(String input) async {
//   LatLng latLng = LatLng(15.4027, 74.0078);
//   String baseURL =
//       'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//   String request =
//       '$baseURL?input=$input&key=AIzaSyDhw_dv7xSxPQWCQtzg6SnfuIEHpHBB_vc&sessiontoken=$_sessionToken&location=${latLng.latitude},${latLng.longitude}&components=country:in&radius=5000';

//   print(request);
//   var response = await http.get(Uri.parse(request));
//   print(response.body.toString());
//   if (response.statusCode == 200) {
//     setState(() {
//       _placesList = jsonDecode(response.body.toString())['predictions'];
//     });
//   } else {
//     throw Exception('Failed to load');
//   }
// }
// }
