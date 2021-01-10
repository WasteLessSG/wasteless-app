import 'package:WasteLess/dashboard-new.dart';
import 'package:WasteLess/home.dart';
import 'package:flutter/material.dart';
import 'package:WasteLess/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {

  runApp(
    new MaterialApp(
theme: ThemeData(
primaryColor: Colors.green[900],
),
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));

}


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
// // Test User Account
//   try {
//     FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: "user@c.com", password: "password")).user;
//     runApp(
//     new MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.green[900],
//       ),
//         home: HomePage(user),
//     // home: Login(),
//     debugShowCheckedModeBanner: false,
//   ));
//   } catch (e) {
//
//     print("ERROR" + e.message );
//   }
//
// }