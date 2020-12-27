import 'package:LessApp/wasteless-data.dart';
import 'package:flutter/material.dart';
import 'package:LessApp/styles.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TestPage extends StatefulWidget{
  @override
  TestPageState createState() => new TestPageState();
}

class TestPageState extends State<TestPage>{

  Future<WasteLessData> fetchWaste() async {
    final response = await http.get(
        'https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/waste',
        headers: {HttpHeaders.authorizationHeader: "jtBSs7AmEX4wSeMR44X5G5IlYWSwfYnn2WgUcz5h"}); //not working anymore

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return WasteLessData.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<WasteLessData> futureWaste;

  @override
  void initState() {
    super.initState();
    futureWaste = fetchWaste();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Styles.MainStatsPageHeader("TEST FOR DEBUGGING", FontWeight.bold, Colors.black),
      body: Center(
            child: FutureBuilder<WasteLessData>(
                  future: futureWaste,
                  builder: (context, snapshot) {
                      if (snapshot.hasData) {
                      return Text(snapshot.data.mass.toString());
                      } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                      }

                      // By default, show a loading spinner.
                      return CircularProgressIndicator();
                      },
                      ),
          ));
  }

}