// import 'package:e_beat/screens/User/expandedTile_locations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';

// class BeatAdminPI extends StatefulWidget {
//   BeatAdminPI({Key? key}) : super(key: key);

//   @override
//   _BeatAdminPIState createState() => _BeatAdminPIState();
// }

// class _BeatAdminPIState extends State<BeatAdminPI> {
//   int _selectedIndex = 0;
//   final List<Widget> _widgetOptions = <Widget>[
//     ext_tile_form(),
//     Text('Search Page',
//         style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//     Text('Profile Page',
//         style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//     Text('History',
//         style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           AppBar(title: const Text('Dashboard'), backgroundColor: Colors.blue),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.add_location_alt),
//                 // title: Text('Home'),
//                 label: ('Track'),
//                 backgroundColor: Colors.green),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.add_chart),
//                 // title: Text('Search'),
//                 label: ('CRUD'),
//                 backgroundColor: Colors.yellow),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.add_alert),
//               // title: Text('Profile'),
//               label: ('Alert'),
//               backgroundColor: Colors.blue,
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.history),
//               // title: Text('Profile'),
//               label: ('History'),
//               backgroundColor: Colors.blue,
//             ),
//           ],
//           type: BottomNavigationBarType.shifting,
//           currentIndex: _selectedIndex,
//           selectedItemColor: Colors.black,
//           iconSize: 40,
//           onTap: _onItemTapped,
//           elevation: 5),
//     );
//   }
// }
