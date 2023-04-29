import 'package:e_beat/Models/created_route_model.dart';
import 'package:e_beat/screens/User/beat_admin.dart';
import 'package:e_beat/screens/User/create_route.dart';
import 'package:e_beat/screens/User/route_summary.dart';
import 'package:flutter/material.dart';

class AllRoutes extends StatefulWidget {
  const AllRoutes({super.key});

  @override
  State<AllRoutes> createState() => _AllRoutesState();
}

class _AllRoutesState extends State<AllRoutes> {
  ExistingRoute r1 = ExistingRoute("Farmagudi", "near Gec campus",
      ['farmagudi circle', 'gec circle', 'NIT Campus', 'Hostel']);
  ExistingRoute r2 = ExistingRoute(
      "Ponda", "City Area", ['A J De Almeida', 'Church', 'Tisk', 'Garden']);

  late List<ExistingRoute> er = [r1, r2];

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
                            return RouteSummary(er[index].locations);
                          }));
                        },
                        icon: Icon(Icons.navigate_next),
                      ),
                      children: [
                        Text(er[index].locations.toString()),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CreateRoute();
              }));
            }),
      ),
    );
  }
}
