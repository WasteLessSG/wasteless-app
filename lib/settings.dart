import 'package:WasteLess/change-displayName.dart';
import 'package:WasteLess/login/change-password.dart';
import 'package:WasteLess/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:WasteLess/TermsOfService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:WasteLess/wasteless-data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget{
  final FirebaseUser user;
  SettingsPage(this.user);

  @override
  SettingsPageState createState() => new SettingsPageState(this.user);
}

class SettingsPageState extends State<SettingsPage>{


  TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
  TextStyle linkStyle = TextStyle(color: Colors.blue);
  FirebaseUser user;
  SettingsPageState(this.user);


  Future<Map> _fetchLoginData() async{

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/user/${user.uid.toString()}/login";

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget _loginAlert() {
    return FutureBuilder(
      future: _fetchLoginData(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData) {

          return Column(
            children: <Widget>[

              Text("1. Key in your Login number and press *\n2. Key in your Pin number and press *\n3. The display should show 'OPEN'\n",
                style: TextStyle(
                  fontSize: 15,
                  //fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              Text("If you accidentally pressed a wrong value, press # and start over again from step 1",
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Text("Login Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              SizedBox(
                height: 10,
              ),
              Text(snapshot.data["userLogin"].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  color: Colors.green[900],
                ),),
              SizedBox(
                height: 30,
              ),
              Text("Pin Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),),
              SizedBox(
                height: 10,
              ),
              Text(snapshot.data["pin"].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 50,
                ),),

            ],
          );

        }
        else if (snapshot.connectionState == ConnectionState.waiting ) {
          return Column(
            children: <Widget>[
              SizedBox( height: 20),
              CircularProgressIndicator(),
            ],
          );




        } else {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),

              Text("ERROR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.red,
                ),),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'PLEASE CONTACT THE WASTELESS TEAM AT '),
                    TextSpan(
                        text: 'SGWASTELESS@GMAIL.COM.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          color: Colors.red,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL('mailto:sgwasteless@gmail.com');
                            print('email');
                          }),

                  ],
                ),
              )

            ],
          );



        }
      }
    );
  }

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
                        title: 'Chute Login Info',
                        leading: Icon(Icons.meeting_room_outlined ),
                        onPressed:  (BuildContext context){
                          showDialog(context: context,
                              builder: (context){
                                return new AlertDialog(

                                  title: Text('Chute Login Information',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                  ),),
                                  content: SingleChildScrollView(
                                    child: Center(
                                      child: _loginAlert(),
                                    )
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
                        title: 'Change Display Name ',
                        leading: Icon(Icons.account_circle_outlined),
                        onPressed: (BuildContext context) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => new ChangeName(user))
                          );
                        },
                      ),
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

                        showDialog(context: context,
                        builder: (context){

                          return new AlertDialog(

                            title: Text('Are you sure you want to log out?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            // content: SingleChildScrollView(
                            //     child: Center(
                            //       child: Text('Are you sure you want to log out?',
                            //         style: TextStyle(
                            //           fontWeight: FontWeight.bold,
                            //         ),),
                            //     )
                            // ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  _signOut();
                                },
                              ),


                            ],
                          );
                        });
                        }
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
                                              TextSpan(text: 'Supported by SouthWest CDC and NUS. \n\nTo find out more about WasteLess and the WasteLess solution, visit our website  '),
                                              TextSpan(
                                                  text: 'wastelesssg.github.io.',
                                                  style: linkStyle,
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {

                                                      _launchURL('https://wastelesssg.github.io/#/');
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
                        title: 'Privacy Policy',
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
                                image: AssetImage('assets/logo.png'),
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

