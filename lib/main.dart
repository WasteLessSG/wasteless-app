import 'package:LessApp/settings.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/home.dart';
import 'package:LessApp/test.dart';
import 'package:LessApp/login/login.dart';

void main()  => runApp( new MaterialApp(
 // home: Landing(),
 //  home: HomePage(),
  home: Login(),
  // home: TestPage(),
  debugShowCheckedModeBanner: false,
));