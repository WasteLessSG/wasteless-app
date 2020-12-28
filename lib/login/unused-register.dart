import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LessApp/login/unused-landing.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => new RegisterState();
}

class RegisterState extends State<Register> {
  String email, password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sign Up",
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
              title: "Register",
              callback: register,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> register() async {
    if (email == null) {
      _showAlertDialog("Error", "Please enter your email");
    } else if (!isEmail(email)) {
      _showAlertDialog("Error", "Please enter a valid email");
    } else if (password == null) {
      _showAlertDialog("Error", "Please enter a password");
    } else if (password.length < 6 || password == null) {
      _showAlertDialog(
          "Error", "Your password needs to be longer than 6 characters");
    } else
      try {
        FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
            .user;

        Firestore.instance.collection("askedquestions")
            .document("user_" + email)
            .collection("questions")
            .document("allTimeQuestionCounter")
            .setData(
            {'counter': 0 ,}
        ).then((response) {
          print("success setting up counter");
        }).catchError((error) {
          print(error);
          _showAlertDialog(
              'Error', 'Problem Initializing User');
        } );


        Navigator.pop(context);

        _showAlertDialog("Status", "Registered Successfully");
      } catch (e) {
        _showAlertDialog("ERROR", e.message);
      }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  bool isEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }
}
