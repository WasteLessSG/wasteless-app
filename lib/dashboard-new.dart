import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:WasteLess/personal-stats.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:WasteLess/wasteless-data.dart';
import 'package:WasteLess/leaderboard.dart';

/**
 * Initialises dashboard page
 */
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


  final df3 = DateFormat.yMMMd();
  final dfFilter = DateFormat("yyyy-MM-dd");

  /**
   * async operation that retrieves the user's name from firebase based on username and password provided
   */
  Future<String> _fetchName() async{

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/user/${user.uid.toString()}/login";
    print("name future link: " + link);
    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      return json.decode(response.body)["username"].toString();
    } else {
      throw Exception('Failed to load data');
    }
  }


  /**
   * async operation that retrieves the leaderboard data to be displayed in the dashboard.
   * shows a loading circle while data is being fetched, returns user's ranking on the leaderboard.
   */
  Future<String> _fetchLeaderBoardData(String type, String nameOrRank) async{
    String currentTypeNum = type == "general" ? '3': '4';

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/leaderboard/${user.uid.toString()}?type=${currentTypeNum}&aggregateBy=week";
    print(link);

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      Map map = json.decode(response.body) as Map;

      return nameOrRank == "rank" ? map["data"][0]['rank'].toString() : map["data"][0]['username'];

    } else {
      throw Exception('Failed to load data');
    }

  }

  /**
   * returns text for leaderboard tiles to inform user's ranking in general waste leaderboard
   */
  Widget _rankingText(String type) {
    return FutureBuilder(
    future: _fetchLeaderBoardData(type, 'rank'),
    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.done  && snapshot.hasData){
        int initialDay = int.parse(snapshot.data);
        String formattedRankingText;

        if (initialDay == 11 || initialDay == 12 || initialDay == 13) {
        formattedRankingText =  '${initialDay}th';
        } else if (initialDay % 10 == 1) {
          formattedRankingText =  '${initialDay}st';
        } else if (initialDay % 10 == 2) {
          formattedRankingText =  '${initialDay}nd';
        } else if (initialDay % 10 == 3) {
          formattedRankingText ='${initialDay}rd';
        } else {
          formattedRankingText = '${initialDay}th';
        }

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width/20,
                color: type == "general" ? Colors.brown[800] : Colors.green[900],
            ),
            children: <TextSpan>[
              TextSpan(text: formattedRankingText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(text: type == "general" ? " lowest rubbish at Tembusu" : " in recycling at Tembusu"),
            ],
          ),
        );

      } else if (snapshot.connectionState == ConnectionState.waiting ){
        print(snapshot.data);
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        );

      } else {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width/30,
              color: type == "general" ? Colors.brown[800] : Colors.green[900],
            ),
            children: <TextSpan>[
              TextSpan(text: type == "general" ? " No rubbish data this week" : "No recycling data this week",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        );
      }
    });
}



  /**
   * returns the list of data for both leaderboards
   */
  Future<List> _fetchTrashOrRecycleData(String type) async {

    String typeNum = type == "general" ? "3" : "4";
    int numOfDays;
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
    var prevWeek = new DateTime(now.year, now.month, now.day - numOfDays);

    String timeRangeStartValue = (prevWeek.millisecondsSinceEpoch ~/ 1000).toString();
    String timeRangeEndValue = (now.millisecondsSinceEpoch ~/ 1000).toString();

    String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${user.uid.toString()}?aggregateBy=day&timeRangeStart=${timeRangeStartValue}&timeRangeEnd=${timeRangeEndValue}&type=${typeNum}";

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});

    if (response.statusCode == 200) {
      Map map = json.decode(response.body) as Map;
      return map["data"];

    } else {
      throw Exception('Failed to load data');
    }
  }


  /**
   * returns the name of the user
   */
  Widget _returnName() {
    return FutureBuilder(
        future: _fetchName(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return Text( snapshot.data,
                textAlign: TextAlign.left,
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width/8,
          )); } else {
            { return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            );
            }
          }
        }
    );

  }

  /**
   * returns specific amount of waste generated
   */
  Widget _buildStats(String party, String type) {
    return FutureBuilder(
        future: _fetchTrashOrRecycleData(type),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double totalValue = snapshot.data.fold(0, (current, entry) => current + entry["weight"]).toDouble() ;

            return Container(
              alignment: Alignment.center,

              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  nf.format(totalValue /1000000) + "kg",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top:10),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }
        }
    );
  }


  /**
   * scaffold of application
   */
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 15,0),
                            width: size.width * 0.93,
                            child: Text("Welcome Tembusu Resident,",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width/20,
                                color: Colors.black45
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5, 10,10),
                            width: size.width * 0.93,
                            height: size.height * 0.12,
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit:BoxFit.scaleDown,
                                child: _returnName(),
                                ),
                            ),


                          InkWell(
                            onTap:  () => {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => new PersonalStatsPage(user,true)))
                            },
                            child: Ink(
                              padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
                              width: size.width*0.93,
                              height: size.height*0.23,
                              decoration: BoxDecoration(
                                  gradient: new LinearGradient(
                                      colors: [Colors.brown,Colors.brown[200]],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown[200],
                                      blurRadius: 10,

                                    ),
                                  ]
                              ),
                              child: Row(
                                children: <Widget>[

                                  makeTrashBin(),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[

                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child:
                                        Text("This week you threw",
                                            style: TextStyle(
                                              fontSize:   MediaQuery.of(context).size.height * 0.018,
                                            )),
                                      ),


                                      SizedBox(
                                        height: MediaQuery.of(context).size.height / 97,
                                      ),

                                      _buildStats("self", "general"),


                                    ],
                                  )

                                ],

                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height/40,
                          ),

                          InkWell(
                            onTap:  () => {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => new LeaderboardPage(user,"Rubbish")))
                            },
                            child: Ink(
                              padding: EdgeInsets.fromLTRB(15, 0, 15,0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown[200],
                                      blurRadius: 10,
                                    ),
                                  ]
                              ),
                              width: size.width * 0.93,
                              height: size.height*0.07,
                              child: Container(
                                alignment: Alignment.center,
                                child: _rankingText("general"),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height/40,
                          ),

                         InkWell(
                           onTap:  () => {
                             Navigator.push(context, MaterialPageRoute(
                                 builder: (context) => new PersonalStatsPage(user,false)))
                           },

                           child:  Ink(
                             padding: EdgeInsets.fromLTRB(25, 0, 20, 0),
                             width: size.width*0.93,
                             height: size.height*0.23,
                             decoration: BoxDecoration(
                                 gradient: new LinearGradient(
                                     colors: [Colors.green[700],Colors.green[200]],
                                     begin: Alignment.centerRight,
                                     end: Alignment.centerLeft
                                 ),
                                 borderRadius: BorderRadius.all(Radius.circular(20)),
                                 boxShadow: [
                                   BoxShadow(
                                     color: Colors.green[200],
                                     blurRadius: 10,

                                   ),
                                 ]
                             ),
                             child: Row(
                               children: <Widget>[
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: <Widget>[

                                     Container(
                                       alignment: Alignment.centerLeft,
                                       child:
                                         Text("This week you recycled",
                                             style: TextStyle(
                                               fontSize:   MediaQuery.of(context).size.height * 0.018,
                                             )),
                                       ),


                                     SizedBox(
                                       height: MediaQuery.of(context).size.height / 79,
                                     ),
                                     _buildStats("self", "all"),


                                   ],
                                 ),
                                 Spacer(),
                                 Image.asset('assets/recyclingIsland.png',
                                   height: MediaQuery.of(context).size.height * 0.177,
                                   width: MediaQuery.of(context).size.height * 0.177,
                                 ),

                               ],

                             ),
                           ),
                         ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height/40,
                          ),
                          InkWell(
                            onTap:  () => {
                                Navigator.push(context, MaterialPageRoute(
                                builder: (context) => new LeaderboardPage(user,"Recyclables")))
                                },

                            child: Ink(
                              padding: EdgeInsets.fromLTRB(15, 0, 15,0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green[200],
                                      blurRadius: 10,
                                    ),
                                  ]
                              ),
                              width: size.width * 0.93,
                              height: size.height*0.07,
                              child: Container(
                                alignment: Alignment.center,
                                //TODO: FIX BELOW ONCE OUT
                                child: _rankingText("recycling"),
                              ),
                            ),
                          )

                        ],
                      ),
                  ],
                ),
              ),
            ),

      ),
      );
  }

  Widget makeTrashBin() {
    return FutureBuilder(
      future: _fetchTrashOrRecycleData("general"),
      builder: (context,snapshot) {
        if (snapshot.hasData){
          String selectedState;
          double avgPersonWaste = (1.5 * 7)/3.16;
          print("sg avg: " + avgPersonWaste.toString());
          double totalValue = snapshot.data.fold(0, (current, entry) => current + entry["weight"]).toDouble() /1000000 ;

          double percFill = ((totalValue-avgPersonWaste)/avgPersonWaste)*100;
          print("%: " + percFill.toString());
          if (percFill < 50.0) {

            selectedState = "rubbishEmpty";

          } else if (50.0 <= percFill && percFill < 80.0) {

            selectedState = "rubbishFilled";

          } else {
            selectedState = "rubbishOverflow";
          }


          if (selectedState == "rubbishEmpty") {
            return Image.asset('assets/rubbishEmptyIsland.png',
              height: MediaQuery.of(context).size.height * 0.177,
              width: MediaQuery.of(context).size.height * 0.177,
            );
          } else if (selectedState == 'rubbishFilled') {
            return Image.asset('assets/rubbishFilledIsland.png',
              height: MediaQuery.of(context).size.height * 0.177,
              width: MediaQuery.of(context).size.height * 0.177,
            );
          } else if (selectedState == 'rubbishOverflow') {
            return Image.asset('assets/rubbishOverflowIsland.png',
              height: MediaQuery.of(context).size.height * 0.177,
              width: MediaQuery.of(context).size.height * 0.177,
            );
          }
        } else {
          return Padding(
            padding: EdgeInsets.only(top:10),
            child:  CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        }
      }
    );

  }

}


