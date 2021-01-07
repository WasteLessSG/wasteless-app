import 'dart:convert';
import 'package:async/async.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HistoryPage extends StatefulWidget{

  final FirebaseUser user;
  HistoryPage(this.user);

  @override
  HistoryPageState createState() => new HistoryPageState(this.user);
}

class HistoryPageState extends  State<HistoryPage> {
  FirebaseUser user;
  HistoryPageState(this.user);

  NumberFormat nf = NumberFormat("###.00", "en_US");

  String _selectedType = "Select Type";
  String _selectedTrend = "Select Trend";

  List<bool> _typeChosen = [true, false, false];
  List<String> _typeList = ["Select Type", "Trash", "Recyclables"];

  List<bool> _trendChosen = [true, false, false, false];
  List<String> _trendList = ["Select Trend", "Week", "Month", "All Time"];
  List list = List();
  Map map = Map();

  final df = new DateFormat('dd-MM-yyyy hh:mm a');
  final df2 = new DateFormat(DateFormat.YEAR_MONTH_DAY, 'en_US');
  final df3 = DateFormat.yMMMd();
  final df4 = new DateFormat('d MMM yyyy');
  final df5 = new DateFormat('MMM');
  final dfFilter = DateFormat("yyyy-MM-dd");
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _fetchData() async {
    var now = new DateTime.now();
    var prevMonth = new DateTime(now.year, now.month - 1, now.day);
    var prevWeek = new DateTime(now.year, now.month, now.day - 6);

    String currentType;
    String timeRangeStartValue;
    String timeRangeEndValue = (now.millisecondsSinceEpoch * 1000).toString();

    if (_typeChosen[1]) {
      currentType = "general";
    } else {
      currentType = "all";
    }

    if (_selectedTrend == "All Time") {
      //TODO: AFTER TESTING, CHANGE THIS VALUE. should at least be 1609926000
      timeRangeStartValue = "0";
    } else if (_selectedTrend == "Month") {
      timeRangeStartValue = (prevMonth.millisecondsSinceEpoch * 1000).toString();
    } else {
      timeRangeStartValue = (prevWeek.millisecondsSinceEpoch * 1000).toString();
    }

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${user.uid.toString()}?aggregateBy=day&timeRangeStart=${timeRangeStartValue}&timeRangeEnd=${timeRangeEndValue}&type=${currentType}";

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
    } else {
      throw Exception('Failed to load data');
    }
  }


  Widget _buildList() {

    var now = new DateTime.now();
    List newList = list;

    newList = new List.from(newList.reversed);

    if (_typeChosen[0] || _trendChosen[0]) {
      return Expanded(
        child: Center(
          child: Text("Please select your desired \nType and Trend",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              //fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    else if (newList.length == 0) {
      return Expanded(
        child: Center(
          child: Text("NO DATA",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
          child: ListView.builder(
            itemCount: newList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  color:   _typeChosen[1] ? ((index % 2 == 0) ? Colors.brown[100] : Colors.white10) : ((index % 2 == 0) ? Colors.lightGreen[200] : Colors.white10),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    title: new Text(df4.format(DateTime.fromMillisecondsSinceEpoch(newList[index]["time"] * 1000)).toString()),
                    //title: new Text(DateTime.now().month.toString()),
                    subtitle: new Text(newList[index]["weight"].toString() + "kg"),
                  )
              );
            },
          )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            title: Text("History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          centerTitle: true,
          backgroundColor: Colors.green[900],
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: (){
                _scaffoldKey.currentState.openEndDrawer();
              },
            )
          ],
        ),

        endDrawer: Container(
          width: size.width * 0.5,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Drawer Header'),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text("asds"),
                  ),


                // ListView.builder(
                //     itemCount: 3,
                //     itemBuilder: (BuildContext context, int index) {
                //       return ListTile(
                //         title: Text(_typeList[index]),
                //       );
                //       },)

              ],
            ),
          ),
        )
        ,
        body: Container(
          alignment: Alignment.center,
          color: Colors.white,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                     DropdownButton<String>(
                       value: _selectedType,
                       //dropdownColor: Colors.green[100],
                       items: _typeList.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String newValue) {

                         setState(() {
                           for (int i = 0; i < _typeList.length; i++) {
                             String currType = _typeList[i];
                             if (newValue == currType) {
                               _typeChosen[i] = true;
                             } else {
                               _typeChosen[i] = false;
                             }
                           }
                           _selectedType = newValue;
                         });
                      },
                    ),

                    SizedBox(
                      height: 10,
                      width: 50,
                    ),

                    DropdownButton<String>(
                      value: _selectedTrend,
                      items: _trendList.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (String newValue) {
                        setState(() {
                          for (int i = 0; i < _trendList.length; i++) {

                            String currType = _trendList[i];

                            if (newValue == currType) {
                              _trendChosen[i] = true;
                            } else {
                              _trendChosen[i] = false;
                            }
                          }
                          _selectedTrend = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),

              FutureBuilder(
                future: _fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildList();
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              ),


              /*
               * Previous Implementation using Firestore
              StreamBuilder(
                stream: Firestore
                    .instance
                    .collection("houses")
                    .document("House_A")
                    .collection("RawData")
                    .orderBy('timestamp', descending: true)
                    .snapshots(),


                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else return Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color:   _typeChosen[0] ? ((index % 2 == 0) ? Colors.brown[100] : Colors.white10) : ((index % 2 == 0) ? Colors.lightGreenAccent : Colors.white10),
                            child: ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding:  EdgeInsets.fromLTRB(10,0,0,0),
                                    child: Text((index+1).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              title: Text(snapshot.data.documents[index]['timestamp2']),
                              subtitle: Text("Mass Thrown: " + snapshot.data.documents[index]['mass'].toString() + " kg"),
                            ),
                          );
                        }
                    )
                  );
                },
              )
              */


            ],
          )
        )
    );
  }
}