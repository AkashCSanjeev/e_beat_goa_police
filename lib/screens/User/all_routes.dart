import 'dart:convert';

import 'package:e_beat/Models/created_route_model.dart';
import 'package:e_beat/screens/User/beat_admin.dart';
import 'package:e_beat/screens/User/create_route.dart';
import 'package:e_beat/screens/User/route_summary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllRoutes extends StatefulWidget {
  const AllRoutes({super.key});

  @override
  State<AllRoutes> createState() => _AllRoutesState();
}

class _AllRoutesState extends State<AllRoutes> {
  // ExistingRoute r1 = ExistingRoute("Farmagudi", "near Gec campus",
  //     ['farmagudi circle', 'gec circle', 'NIT Campus', 'Hostel'], "1", "ponda");
  // ExistingRoute r2 = ExistingRoute("Ponda", "City Area",
  //     ['A J De Almeida', 'Church', 'Tisk', 'Garden'], "2", "ponda");

  late List<ExistingRoute> er = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getAllRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 75, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return BeatAdmin();
                    }));
                  },
                  backgroundColor: Colors.amber,
                  child: Icon(
                    Icons.perm_identity,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              color: Colors.amber,
              margin: EdgeInsets.fromLTRB(20, 160, 20, 50),
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      leading: Text('${index + 1}'),
                      title: Text(er[index].routeName),
                      subtitle: Text(er[index].routeDescription),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return RouteSummary(er[index].area);
                          }));
                        },
                        icon: Icon(Icons.navigate_next),
                      ),
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: 100,
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: ListView.separated(
                              itemBuilder: (context, lindex) {
                                return ListTile(
                                  // leading: Text('${index + 1}'),
                                  title: Text(er[index].area[lindex].name),
                                  // trailing: Checkbox(
                                  //   value: false,
                                  //   onChanged: null,
                                  // ),
                                );
                              },
                              separatorBuilder: (context, lindex) {
                                return Divider(
                                  // height: 50,
                                  thickness: 1,
                                  color: Colors.blueGrey,
                                );
                              },
                              itemCount: er[index].area.length),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 50,
                      thickness: 1,
                      color: Colors.black,
                    );
                  },
                  itemCount: er.length),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 10, 40),
        child: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.add),
            backgroundColor: Colors.blueGrey,
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return CreateRoute();
              }));
            }),
      ),
    );
  }

  getAllRoutes() async {
    print("start");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('userToken');
    final String? userResponse = prefs.getString('userDetails');
    print("$userResponse");

    var userGrpDetails = await get(
      Uri.parse(
          "https://ebeatapi.onrender.com/users/usergroup/${jsonDecode("$userResponse")['data'][0]['user']['_id']}"),
      headers: {'Authorization': "Bearer $action"},
    );
    await prefs.setString('userGrpDetails', userGrpDetails.body);
    await prefs.setString(
        'userGrpId', jsonDecode(userGrpDetails.body)['data']['_id']);

    final String? userGrpId = prefs.getString('userGrpId');

    print("$userGrpId");
    var response = await get(
      Uri.parse("https://ebeatapi.onrender.com/routes/group/${userGrpId}"),
      headers: {'Authorization': "Bearer $action"},
    );
    print(jsonDecode(response.body)['data'][0]["curRoutes"].toString());

    List data = jsonDecode(response.body)['data'];

    for (var i = 0; i < data.length; i++) {
      var routeName = jsonDecode(response.body)['data'][i]['name'];
      var routeDes = jsonDecode(response.body)['data'][i]['description'];
      List<Area> area = [];

      for (var j = 0;
          j < jsonDecode(response.body)['data'][i]['curRoutes'].length;
          j++) {
        area.add(Area(
            jsonDecode(response.body)['data'][i]['curRoutes'][j]['name'],
            jsonDecode(response.body)['data'][i]['curRoutes'][j]['city'],
            jsonDecode(response.body)['data'][i]['curRoutes'][j]['_id']));
      }
      var id = jsonDecode(response.body)['data'][i]['_id'];

      er.add(ExistingRoute(routeName, routeDes, area, id, area[0].city));
    }

    setState(() {});
  }
}
