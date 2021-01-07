import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:csv_reader/csv_reader.dart';
import 'package:LessApp/styles.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'package:LessApp/wasteless-data.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:custom_switch/custom_switch.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DashboardPage extends StatefulWidget{

  FirebaseUser user;
  DashboardPage(FirebaseUser user) {
    this.user = user;
  }


  @override
  DashboardPageState createState() => new DashboardPageState(this.user);

}

class DashboardPageState extends State<DashboardPage> {

  FirebaseUser user;
  DashboardPageState(this.user);

  NumberFormat nf = NumberFormat("##0.00", "en_US");

  double wasteThisWeek = 0.00;
  double areaAverageThisWeek = 0.00;

  double recyclablesThisWeek = 0.00;
  double areaAverageRecyclablesThisWeek = 0.00;

  List<bool> titleSelect = [true, false];
  List<String> title = ["Trash Dashboard", "Recycling Dashboard"];
  List<Color> colorPalette = [Colors.lightGreen[200], Colors.brown[100]];

  double sizeRelativeVisual = 1.0;

  final df3 = DateFormat.yMMMd();
  final dfFilter = DateFormat("yyyy-MM-dd");
  List list = List();
  Map map = Map();
  AsyncMemoizer _memoizer;
  bool isSelected = false;
  int isSelectedIndex = 0;

  List<List<dynamic>> dailyMessages = List();

  @override
  void initState() {
    super.initState();
    _memoizer = AsyncMemoizer();
    //loadAsset();
  }


  Widget _buildDailyMessage() {
    var now = DateTime.now();
    return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: titleSelect[0] ? colorPalette[1]: colorPalette[0],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black,
            ),
          ),

          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width / 1.05,

          child: Column(
            children: <Widget>[
              Text("\nDaily Tip",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Text("\n" +
                  // "Daily Message",
                  dailyMessages[now.day][0].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildGraphic() {
    return Container(
      width: MediaQuery.of(context).size.width/2,
      child: Column(
        children: <Widget>[
          titleSelect[0] ? trashBin(stateSelector(this.wasteThisWeek, this.areaAverageThisWeek)) : Image.asset('assets/recyclingIsland.png'),
        ],
      ),
    );
  }

  Widget _buildNationalText(String type) {

    double trashWeekAvg = 10.05;
    double recWeekAvg = 14.39;
    //based on https://www.channelnewsasia.com/news/singapore/singapore-generated-less-waste-2019-recycling-rate-fell-nea-12643286

    var now = new DateTime.now();
    List newList = list.where((entry) => DateTime.parse(dfFilter.format(DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000)).toString())
        .isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
        .toList();

    double personalAverage = newList.fold(0, (current, entry) => current + entry["weight"]) / 7.0;
    double nationalAverage = titleSelect[0] ? trashWeekAvg: recWeekAvg;

    String differenceText = "Until\nNational: ";
    Text currentStatus;
    double percFill = (personalAverage/nationalAverage)*100;

    if(percFill < 50.0) {
      currentStatus = Text("LOW",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    } else if (50.0 < percFill && percFill < 80.0) {
      currentStatus = Text("MEDIUM",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
        ),
      );
    } else {
      currentStatus = Text("HIGH",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: titleSelect[0] ? colorPalette[1]: colorPalette[0],
        borderRadius: BorderRadius.circular(5),
      ),

      height: MediaQuery.of(context).size.height / 10,
      width: MediaQuery.of(context).size.width / 1.05,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(differenceText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(nf.format(nationalAverage - personalAverage).toString() + "kg",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width / 5,
          ),

          Text("Status: ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          currentStatus,
        ],
      ),
    );
  }

  Widget _buildPersonalText(String type) {

    String welcomeMessage_trash = "Welcome " + "Darren" + ",\nYour waste this week thus far is:";
    String welcomeMessage_rec = "Welcome " + "Darren" + ",\nYour recyclables this week thus far is:";
    String welcomeMessage = titleSelect[0] ? welcomeMessage_trash: welcomeMessage_rec;

    return Container(
      decoration: BoxDecoration(
        color: titleSelect[0] ? colorPalette[1]: colorPalette[0],
        borderRadius: BorderRadius.circular(5),
      ),

      height: MediaQuery.of(context).size.height / 6,
      width: MediaQuery.of(context).size.width / 1.05,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 50,
          ),
          Container(
              child: Text(welcomeMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              )
          ),
          _buildStats("self", type),

          /*
          FutureBuilder(
            future: _fetchData("self", type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildStats("self", type);
              } else {
                return CircularProgressIndicator();
              }
            }
          ),
          */
          //_buildStats("self", type),

        ],
      ),
    );
  }

  _buildSwitch() {
    return Switch(
        activeColor: Colors.green,
        inactiveThumbColor: Colors.brown,
        activeTrackColor: Colors.greenAccent,
        inactiveTrackColor: Colors.redAccent,
        value: isSelected,
        onChanged: (value) {
          setState(() {
            for (int i = 0; i < titleSelect.length; i++) {
              if (titleSelect[i]) {
                titleSelect[i] = false;
              } else {
                titleSelect[i] = true;
              }
            }
            isSelected = value;
          });
        }
    );
  }

  _buildToggleSwitch() {
    return ToggleSwitch(
      minWidth: MediaQuery.of(context).size.width / 10,
      minHeight: MediaQuery.of(context).size.height / 30,
      labels: ['G', 'R'],
      //icons: [Octicons.trashcan, FontAwesome.recycle],
      initialLabelIndex: isSelectedIndex,
      cornerRadius: 20.00,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      activeBgColors: [Colors.brown, Colors.green],
      onToggle: (index) {
        setState(() {
          for (int i = 0; i < titleSelect.length; i++) {
            if (titleSelect[i]) {
              titleSelect[i] = false;
            } else {
              titleSelect[i] = true;
            }
          }
          isSelectedIndex = index;
        });
      },
    );
  }

  /*
  _fetchData(String party, String type) async {
    return this._memoizer.runOnce(() async {
      String link;
      if (party == "self") {
        link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${user.uid.toString()}?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
        //link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${WasteLessData.userID.toString()}?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
      } else {
        link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
      }

      final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
      if (response.statusCode == 200) {
        map = json.decode(response.body) as Map;
        list = map["data"];
      } else {
        throw Exception('Failed to load data');
      }
    });
  }
  */

  _fetchData(String party, String type) async {

    var now = new DateTime.now();
    var prevMonth = new DateTime(now.year, now.month - 1, now.day);
    var prevWeek = new DateTime(now.year, now.month, now.day - 6);


    String link;
    if (party == "self") {
      link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/1234?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
      //link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${WasteLessData.userID.toString()}?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
    } else {
      link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
    }

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
    } else {
      throw Exception('Failed to load data');
    }
  }



  Widget _buildStats(String party, String type) {

    //_fetchData(party, type);

    var now = new DateTime.now();
    List newList = list.where((entry) => DateTime.parse(dfFilter.format(DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000)).toString())
        .isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
        .toList();

    double averageValue = newList.fold(0, (current, entry) => current + entry["weight"]) / 7.0;

    if (type == "general") {
      if (party == "self") {
        wasteThisWeek = averageValue;
      } else {
        areaAverageThisWeek = averageValue;
      }
    } else {
      if (party == "self") {
        recyclablesThisWeek = averageValue;
      } else {
        areaAverageRecyclablesThisWeek = averageValue;
      }
    }

    setState(() {
      if (type == "general") {
        if (party == "self") {
          wasteThisWeek = averageValue;
        } else {
          areaAverageThisWeek = averageValue;
        }
      } else {
        if (party == "self") {
          recyclablesThisWeek = averageValue;
        } else {
          areaAverageRecyclablesThisWeek = averageValue;
        }
      }
    });

    return Expanded(
      child: FutureBuilder(
          future: _fetchData("self", type),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(nf.format(averageValue) + "kg",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          }
      ),
    );
  }

  static String stateSelector(double a, double b) {
    if (b == 0) {
      return "rubbishEmpty";
    }

    double percFill = (a/b)*100;
    if (percFill < 50.0) {
      return "rubbishEmpty";
    } else if (50.0 <= percFill && percFill < 80.0) {
      return "rubbishFilled";
    } else {
      return "rubbishOverflow";
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String currentTitle, currentType;
    if (titleSelect[0]) {
      currentTitle = title[0];
      currentType = "general";
    } else {
      currentTitle = title[1];
      currentType = "all";
    }



    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   centerTitle: true,
      //   title:
      //       Text("Dashboard",
      //         style: TextStyle(
      //           color: Colors.white,
      //         ),
      //       ),
      //   backgroundColor:  Colors.green[900],
      //   elevation: 0,
      //
      // ),

      body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Column(

                        children: <Widget>[

                          Container(
                            padding: EdgeInsets.fromLTRB(15, 15, 15,0),
                            width: size.width,
                            child: Text("Welcome,",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black45
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 5, 15,15),
                            width: size.width,
                            child: Text("Ryan",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 65
                              ),
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            width: size.width*0.95,
                            height: 200,
                            decoration: BoxDecoration(
                                gradient: new LinearGradient(
                                    colors: [Colors.brown,Colors.brown[200]],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.brown[100],
                                    blurRadius: 10,
                                    offset: Offset(10.0,10.0),

                                  ),
                                ]
                            ),
                            child: Row(
                              children: <Widget>[

                                Image.asset('assets/rubbishEmptyIsland.png',
                                  height: 150,
                                  width: 150,),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    Text("This week you threw",
                                    style: TextStyle(
                                      fontSize: 19
                                    )),
                                    SizedBox(height:10),
                                    Text("50.0kg",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 50
                                        )),


                                  ],
                                )

                              ],

                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          Container(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            width: size.width*0.95,
                            height: 200,
                            decoration: BoxDecoration(
                                gradient: new LinearGradient(
                                    colors: [Colors.green[700],Colors.green[200]],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green[100],
                                    blurRadius: 10,
                                    offset: Offset(10.0,10.0),

                                  ),
                                ]
                            ),
                            child: Row(

                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    Text("This week you recycled",
                                        style: TextStyle(
                                            fontSize: 19
                                        )),
                                    SizedBox(height:14),
                                    Text("50.0kg",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 50
                                        )),


                                  ],
                                ),
                                Spacer(),
                                Image.asset('assets/recyclingIsland.png',
                                  height: 150,
                                  width: 150,),

                              ],

                            ),
                          ),


                          //_buildNationalText(currentType),

                          // FutureBuilder(
                          //   future: loadAsset(),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState == ConnectionState.done) {
                          //       return
                          //         _buildDailyMessage();
                          //     } else {
                          //       return CircularProgressIndicator();
                          //     }
                          //   }
                          // ),

                        ],
                      ),
                  ],
                ),
              ),
            ),

      ),
      );
  }

  // Beginning of dynamic widgets



  // trashBin
  Widget trashBin(String selectedState) {
    if (selectedState == "rubbishEmpty") {
      return Image.asset('assets/rubbishEmptyIsland.png');
    } else if (selectedState == 'rubbishFilled') {
      return Image.asset('assets/rubbishFilledIsland.png');
    } else if (selectedState == 'rubbishOverflow') {
      return Image.asset('assets/rubbishOverflowIsland.png');
    }
  }
  // End of trashBin

  // tipLightBulb

  Widget tipLightBulb(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.lightbulb_outline, color: Colors.black),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              elevation: 16,
              child: Container(
                  height: 400.0,
                  width: 360.0,
                  child: Center(
                      child:
                      Text("Daily Tip: \nAn apple a day keeps the doctor away", textAlign: TextAlign.center)
                    // Uncomment below once the CSV URL is settled
                    // Text(tipsCSV[tipNumber()][2].toString(), textAlign: TextAlign.center)
                  )
              ),
            );
          },
        );
      },
    );
  }

// End of tipLightBulb

// End of dynamic widgets

}
