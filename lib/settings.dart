import 'package:LessApp/wasteless-data.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/styles.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget{
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Styles.MainStatsPageHeader("Settings", FontWeight.bold, Colors.black),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(
                title: 'Sign Out',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(
                title: 'Terms of Services',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: 'About Us',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

}