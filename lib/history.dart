import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:WasteLess/wasteless-data.dart';
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

    int numOfDays ;
    var now = new DateTime.now();
    switch (DateFormat('E').format(DateTime.now())) {

      case 'Mon' : {
        numOfDays = 0;
        break;
      }
      case 'Tue' : {
        numOfDays = 1;
        break;
      }
      case 'Wed' : {
        numOfDays = 2;
        break;
      }
      case 'Thu' : {
        numOfDays = 3;
        break;
      }
      case 'Fri' : {
        numOfDays = 4;
        break;
      }
      case 'Sat' : {
        numOfDays = 5;
        break;
      }
      case 'Sun' : {
        numOfDays = 6;
        break;
      }

    }
    var prevMonth = new DateTime(now.year, now.month, 1);
    var prevWeek = new DateTime(now.year, now.month, now.day - numOfDays);


    String currentType;
    String currentTypeNum;
    String timeRangeStartValue;
    String timeRangeEndValue = (now.millisecondsSinceEpoch * 1000).toString();

    if (_typeChosen[1]) {
      currentType = "general";
      currentTypeNum = "1";
    } else {
      currentType = "all";
      //TODO: Fix once end pt for all trash is up
      currentTypeNum = "4";
    }

    if (_selectedTrend == "All Time") {
      //TODO: AFTER TESTING, CHANGE THIS VALUE. should at least be 1609926000
      timeRangeStartValue = "0";
    } else if (_selectedTrend == "Month") {
      timeRangeStartValue = (prevMonth.millisecondsSinceEpoch ~/ 1000).toString();
    } else {
      timeRangeStartValue = (prevWeek.millisecondsSinceEpoch ~/ 1000).toString();
    }



    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${user.uid.toString()}?aggregateBy=day&timeRangeStart=${timeRangeStartValue}&timeRangeEnd=${timeRangeEndValue}&type=${currentTypeNum}";
    print(link);
    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
      print(list);
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
                  color:   _typeChosen[1] ? ((index % 2 == 0) ? Colors.brown[50] : Colors.white10) : ((index % 2 == 0) ? Colors.lightGreen[50] : Colors.white10),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.fromLTRB(20,10.0,20,10),
                    title: new Text(df4.format(DateTime.fromMillisecondsSinceEpoch(newList[index]["time"] * 1000)).toString(),
                    style: TextStyle(
                      fontSize: 25,
                    ),),
                    //title: new Text(DateTime.now().month.toString()),
                   trailing: new Text((newList[index]["weight"] /1000000).toString() + "kg",
                     style: TextStyle(
                       fontSize: 25,
                       fontWeight: FontWeight.bold
                     ),),
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
            title: Text((_selectedType == "Select Type" ? "": _selectedType +" ")+"History",
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
                  SizedBox(
                    height:size.height * 0.15,
                    child:  DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                      ),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("You Selected",
                              style: TextStyle(
                                fontSize: 20,
                                color:Colors.white30,
                              ),),

                          ],
                        ),

                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedType,
                        items: _typeList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),),
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
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTrend,
                      items: _trendList.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),),
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
                  ),
                  )
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
            ],
          )
        )
    );
  }
}