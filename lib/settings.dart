import 'package:LessApp/wasteless-data.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/styles.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';

class SettingsPage extends StatefulWidget{
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Styles.MainStatsPageHeader("Settings", FontWeight.bold, Colors.black),
      body: Text("test"),
    );
  }

}