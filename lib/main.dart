import 'package:flutter/material.dart';
import 'package:WasteLess/login/login.dart';

/**
 * Initialises application
 */
void main() {
  runApp(
    new MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green[900],
      ),
      home: Login(),
      debugShowCheckedModeBanner: false,
    )
  );

}