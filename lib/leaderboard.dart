import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:LessApp/styles.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:LessApp/wasteless-data.dart';

class LeaderboardPage extends StatefulWidget{
  final FirebaseUser user;
  LeaderboardPage(this.user);
  @override
  LeaderboardPageState createState() => new LeaderboardPageState(this.user);
}

class LeaderboardPageState extends  State<LeaderboardPage> {

  FirebaseUser user;
  LeaderboardPageState(this.user);

  NumberFormat nf = NumberFormat("###.00", "en_US");

  String _selectedType = "Select Type";
  String _selectedTrend = "Select Trend";

  List<bool> _typeChosen = [true, false, false];
  List<String> _typeList = ["Select Type", "Trash", "Recyclables"];

  List<bool> _trendChosen = [true, false, false, false];
  List<String> _trendList = ["Select Trend", "Week", "Month", "All Time"];

  List list = List();
  Map map = Map();

  final dfFilter = DateFormat("yyyy-MM-dd");
  final df3 = DateFormat('d MMM yyyy');

  AsyncMemoizer _memoizer;
  @override
  void initState() {
    _memoizer = AsyncMemoizer();
  }


  _fetchData() async {
    return this._memoizer.runOnce(() async {

      String currentType;
      String currentTrend;

      //trash selected
      if (_typeChosen[1]) {
        currentType = "general";
      } else {
        currentType = "all";
      }

      if (_trendChosen[3]) {
        currentTrend = "allTime";
      } else if (_trendChosen[2]) {
        currentTrend = "month";
      } else {
        currentTrend = "allTime";
      }

      //String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard?aggregateBy=week&type=general";
      String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard?type=${currentType}&aggregateBy=${currentTrend}";

      final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});

      if (response.statusCode == 200) {
        map = json.decode(response.body) as Map;
        list = map["data"];
      } else {
        throw Exception('Failed to load data');
      }
    });
  }


  Widget _buildList() {
    var now = new DateTime.now();
    List newList = list;
    print(list);

    /*
     * no need for the manual filtering below since the API has already done it
    switch(_selectedTrend) {

    //month's worth of data
      case "Month": {
        newList = list.where((entry)=> (DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000).month == DateTime.now().month)
        && (DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000).year == DateTime.now().year))
            .toList();
      }
      break;

      //all time data
      case "All Time": {
        newList = list;
      }
      break;

      //week's worth of data
      case "Week": {
        newList = list.where((entry) => DateTime.parse(dfFilter.format(DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000)).toString())
            .isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
            .toList();
      }
      break;

      //if no filter is selected
      default: {
        newList = List();
      }
    }
    */

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
                  contentPadding: EdgeInsets.all(10.0),
                  title: new Text("UserID is: " + newList[index]["userId"].toString()),
                    //title: new Text(df3.format(DateTime.fromMillisecondsSinceEpoch(newList[index]["userId"] * 1000)).toString()),
                    //title: new Text(DateTime.now().month.toString()),
                  subtitle: new Text("${_selectedType} thrown ${_selectedTrend}: " + newList[index]["weight"].toString() + "kg"),
                  ),
              );
            },
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    _fetchData();

    return Scaffold(
      appBar: AppBar(
          title: Text("Community Leaderboard",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
      ),

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

            _buildList(),

            /*
             * Previous implementation using Firestore
            StreamBuilder(
              stream:  Firestore
                  .instance
                  .collection("houses")
                  .orderBy('alltime', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else

                  //  List<MassEntry> massEntryRaw = snapshot.data.documents
                  //               .map((documentSnapshot) => MassEntry.fromMap(documentSnapshot.data))
                  //               .toList();
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context,int index){
                        return Container(
                          color: Colors.white,
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding:  EdgeInsets.fromLTRB(10,0,0,0),
                                  child: Text((index+1).toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,),),
                                )
                              ],
                            ),
                            title: Text(snapshot.data.documents[index].documentID),
                            subtitle: Text("All Time Mass Thrown: " + nf.format(snapshot.data.documents[index]['alltime']).toString() + " kg"),
                          ),
                        );}, //itemBuilder
                    )
                  );
              },
            )
            */







          ],
        ),
      )
    );
  }
}