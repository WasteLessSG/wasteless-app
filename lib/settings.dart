import 'package:LessApp/login/change-password.dart';
import 'package:LessApp/login/login.dart';
import 'package:LessApp/wasteless-data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/styles.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:LessApp/TermsOfService.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';


class SettingsPage extends StatefulWidget{
  final FirebaseUser user;
  SettingsPage(this.user);

  @override
  SettingsPageState createState() => new SettingsPageState(this.user);
}

class SettingsPageState extends State<SettingsPage>{

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
  TextStyle linkStyle = TextStyle(color: Colors.blue);
  FirebaseUser user;
  SettingsPageState(this.user);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white30,
        appBar:AppBar(
          title: Text("Settings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green[900],
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: SettingsList(
                lightBackgroundColor: Colors.white,
                sections: [
                  SettingsSection(
                    titlePadding: EdgeInsets.fromLTRB(15,20, 0, 15),
                    title: 'Account',
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      fontSize: 20,
                    ),
                    tiles: [
                      SettingsTile(
                        title: 'Change Password ',
                        leading: Icon(Icons.lock_outlined),
                        onPressed: (BuildContext context) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => new ChangePassword(user))
                          );
                        },
                      ),

                      SettingsTile(
                        title: 'Sign Out',
                        leading: Icon(Icons.logout),
                        onPressed: (BuildContext context) {
                          _signOut();
                        },
                      ),
                    ],
                  ),

                  SettingsSection(
                    titlePadding: EdgeInsets.fromLTRB(15,20, 0, 15),
                    title: 'Miscellaneous ',
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      fontSize: 20,
                    ),
                    tiles: [

                      SettingsTile(
                        title: 'About Us',
                        leading: Icon(Icons.info_outlined),
                        onPressed:  (BuildContext context){
                          showDialog(context: context,
                              builder: (context){
                                return new AlertDialog(

                                  title: Text('About Us'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[

                                        RichText(
                                          text: TextSpan(
                                            style: defaultStyle,
                                            children: <TextSpan>[
                                              TextSpan(text: 'To find out more about WasteLess and the WasteLess solution, visit our website  '),
                                              TextSpan(
                                                  text: 'wastelesssg@github.io.',
                                                  style: linkStyle,
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {

                                                      _launchURL('wastelesssg@github.io');
                                                      print('wasteless website');
                                                    }),

                                            ],
                                          ),
                                        )


                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });

                        },
                      ),

                      SettingsTile(
                        title: 'Contact Us',
                        leading: Icon(Icons.mail_outlined),
                        onPressed:  (BuildContext context){
                          showDialog(context: context,
                              builder: (context){
                                return new AlertDialog(

                                  title: Text('Contact Us'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[

                                        RichText(
                                          text: TextSpan(
                                            style: defaultStyle,
                                            children: <TextSpan>[
                                              TextSpan(text: 'For feedback and other general inquiries, please contact us at  '),
                                              TextSpan(
                                                  text: 'sgwasteless@gmail.com.',
                                                  style: linkStyle,
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      _launchURL('mailto:sgwasteless@gmail.com');
                                                      print('email');
                                                    }),

                                            ],
                                          ),
                                        )


                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });

                        },
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
                        onPressed: (BuildContext context) {
                          showAboutDialog(
                              context: context,
                              applicationVersion: 'WasteLess v1.0',
                              applicationIcon: Image(
                                image: AssetImage('assets/icon.png'),
                                width: 50,
                                height: 50,
                              ),
                              //applicationIcon: Icon(Icons.copyright),
                              applicationLegalese: 'This app credits the following licenses.'
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),







      );

  }
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("signing out ");
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          new MaterialPageRoute(
              builder: (context) =>
              new Login()),
              (route) => false);

    } catch (e) {
      print(e); // TODO: show dialog with error
    }



  }
}

_launchURL(url) async {
  print("launching url");
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print("cannot launch url");
    throw 'Could not launch $url';

  }
}

