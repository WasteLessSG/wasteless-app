import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LessApp/mainStatsPage.dart';
import 'package:LessApp/login/landing.dart';

class Login extends StatefulWidget {

  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {
  String email, password;
//Firebase doesnt support custom usernames, username must be in form of email
//final GlobalKey<FormState> _formkey = GlobalKey<FormState> ();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Log In",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 50,
            ),

            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value.trim(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: "Enter your email",
                border: const OutlineInputBorder(),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            TextField(
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: "Enter your password",
                border: const OutlineInputBorder(),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            PageButton(
              title: "Sign In",
              callback: signIn,
            ),

          ], ),
      ),

    );
  }

  Future<void> signIn() async{
    try {
      FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MainStatsPage()));
    } catch (e) {
      _showAlertDialog("ERROR",e.message);
    }

  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}