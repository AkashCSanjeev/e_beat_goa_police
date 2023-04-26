import 'package:e_beat/screens/beat_admin.dart';
import 'package:e_beat/screens/beat_location_table.dart';
import 'package:e_beat/screens/expandedTile_locations.dart';
import 'package:e_beat/screens/form_gov.dart';
import 'package:e_beat/screens/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BeatAdmin(),
    );
  }
}
