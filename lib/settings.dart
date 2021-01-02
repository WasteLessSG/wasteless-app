import 'package:LessApp/wasteless-data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/styles.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:LessApp/TermsOfService.dart';

class SettingsPage extends StatefulWidget{
  final FirebaseUser user;
  SettingsPage(this.user);

  @override
  SettingsPageState createState() => new SettingsPageState(this.user);
}

class SettingsPageState extends State<SettingsPage>{

  FirebaseUser user;
  SettingsPageState(this.user);


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),


      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: Styles.MainStatsPageHeader("Settings", FontWeight.bold, Colors.black),
        body: SettingsList(
          lightBackgroundColor: Colors.white,
          sections: [
            SettingsSection(
              title: 'Account',
              tiles: [
                SettingsTile(
                  title: 'Change Password ',
                  leading: Icon(Icons.lock_outlined),
                  onPressed: (BuildContext context) {},
                ),

                SettingsTile(
                  title: 'Sign Out',
                  leading: Icon(Icons.logout),
                  onPressed: (BuildContext context) {},
                ),
              ],
            ),
            
            SettingsSection(
              title: 'Miscellaneous ',
              tiles: [

                SettingsTile(
                  title: 'About Us',
                  leading: Icon(Icons.info_outlined),
                  onPressed: (BuildContext context) {},
                ),

                SettingsTile(
                  title: 'Contact Us',
                  leading: Icon(Icons.mail_outlined),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile(
                  title: 'Terms of Services',
                  leading: Icon(Icons.article_outlined),
                  onPressed: (BuildContext context) {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => new TermsOfService())
                    );
                  },
                ),
                SettingsTile(
                  title: 'Licences',
                  leading: Icon(Icons.copyright),
                  onPressed: (BuildContext context) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}