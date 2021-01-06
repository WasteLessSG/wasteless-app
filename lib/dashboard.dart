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

  List<List<dynamic>> dailyMessages = List();

  @override
  void initState() {
    super.initState();
    _memoizer = AsyncMemoizer();
    //loadAsset();
  }

  /*
   * previous initialize statement where it supports swiping panels for body
  @override
  void initState() {
    super.initState();
    _memoizer = AsyncMemoizer();
    _controller1 = PageController(
        initialPage: 0,
        viewportFraction: 1
    )

      ..addListener(_onController1Scroll);

    _controller2 = PageController(
        initialPage: 0,
        viewportFraction: 1
    )
      ..addListener(_onController2Scroll);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getVisualSize());
  }


  loadAsset() async {
    final myData = await rootBundle.loadString("assets/dailyMessages.csv");
    print('csv in string'+myData);
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    dailyMessages = csvTable;
    print('next line  supposed converted');
    print(dailyMessages);
  }
  */

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
    double recWeekAvg = 14.39; //based on https://www.channelnewsasia.com/news/singapore/singapore-generated-less-waste-2019-recycling-rate-fell-nea-12643286

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

    String welcomeMessage_trash = "Welcome " + this.user.uid + ",\nYour waste this week thus far is:";
    String welcomeMessage_rec = "Welcome " + this.user.uid + ",\nYour recyclables this week thus far is:";
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

  // Uncomment below after tip URL is settled
  /*
  var tipsCSV = CSV.from(url :'URL_TO_FILE_OR_RAW_TEXT', delimiter: ",", title:true );
  final _random = new Random();
  int tipNumber() => 41 + _random.nextInt(62 - 41);
  */

  // For determining container sizes

  /*
  GlobalKey _keyVisual = GlobalKey();

  _getVisualSize() {
    final RenderBox visual = _keyVisual.currentContext.findRenderObject();
    final sizeVisual = visual.size.width;
    double width = MediaQuery.of(context).size.width;
    sizeRelativeVisual = sizeVisual/width;
  }

  // Initialise PageControllers

  int _previousPage = 0;
  bool _isController1 = false;
  bool _isController2 = false;

  PageController _controller1;
  PageController _controller2;


  @override
  void initState() {
    super.initState();
    _controller1 = PageController(
      initialPage: 0,
      viewportFraction: 1
    )

    ..addListener(_onController1Scroll);

    _controller2 = PageController(
      initialPage: 0,
      viewportFraction: 1
    )
    ..addListener(_onController2Scroll);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getVisualSize());
  }


  void resetMoveInfo(){
    _isController1 = false;
    _isController2 = false;
  }

  // Link PageControllers

  void _onController1Scroll() {
    if (_isController2)
      return;

    _isController1 = true;

    if (_controller1.page.toInt() == _controller1.page) {
      _previousPage = _controller1.page.toInt();
      resetMoveInfo();
    }

    _controller2.position
    // ignore: deprecated_member_use
        .jumpToWithoutSettling(_controller1.position.pixels * sizeRelativeVisual);
  }

  void _onController2Scroll() {
    if (_isController1)
      return;

    _isController2 = true;

    if (_controller2.page.toInt() == _controller2.page) {
      _previousPage = _controller2.page.toInt();
      resetMoveInfo();
    }

    _controller1.position
    // ignore: deprecated_member_use
        .jumpToWithoutSettling(_controller2.position.pixels / sizeRelativeVisual);
  }


  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
  // End of PageController initialisation


  // selectionDots
  Widget selectionDots(BuildContext context, selectedState) {
    return SmoothPageIndicator(
        controller: _controller2,  // PageController
        count:  2,
        effect:  WormEffect(),  // your preferred effect
        onDotClicked: (index){

        }
    );
  }
  // End of selectionDots
  */

  @override
  Widget build(BuildContext context) {

    String currentTitle, currentType;
    if (titleSelect[0]) {
      currentTitle = title[0];
      currentType = "general";
    } else {
      currentTitle = title[1];
      currentType = "all";
    }



    return Scaffold(
      /*
       * previous plain appBar
      appBar: AppBar(
        title: Text("Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          //tipLightBulb(context),
        ]
      ),
      */
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Dashboard",
              style: TextStyle(
                color: Colors.black,
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
            ),

            _buildSwitch(),
          ],
        ),



        /*
        title: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width/1.05,
          height: 10.0,
          child: RaisedButton(
            elevation: 10.0,
            color: titleSelect[0] ? colorPalette[1]: colorPalette[0],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              //side: BorderSide(color: Colors.white),
            ),
            padding: EdgeInsets.all(10.0),


            child: Text(currentTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            onPressed: () {
              setState(() {
                for (int i = 0; i < titleSelect.length; i++) {
                  if (titleSelect[i]) {
                    titleSelect[i] = false;
                  } else {
                    titleSelect[i] = true;
                  }
                }
              });
            },
          ),
        ),
        */



        backgroundColor: Colors.lightGreen[200],
        elevation: 0,

      ),

      body: Container(
        alignment: Alignment.center,

        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 20,
            ),

            _buildPersonalText(currentType),


            SizedBox(
              height: MediaQuery.of(context).size.height / 20,
            ),

            FutureBuilder(
                future: _fetchData("self", currentType),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildNationalText(currentType);
                  } else {
                    return CircularProgressIndicator();
                  }
                }
            ),


            //_buildNationalText(currentType),

            SizedBox(
              height: MediaQuery.of(context).size.height / 20,
            ),
            _buildGraphic(),

            SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),

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
      ),


      /*
       * swiping version
      // BODY OF THE APP
      body: Center(
        child: Column(

            children: <Widget>[

              // The first expanded is for SUMMARY STATISTICS
              Expanded(
                  child: PageView(

                    controller: _controller1,
                    children: [

                      //General waste page
                      Column(
                          children: <Widget>[
                            // This first expanded contains USER WEEKLY TOTAL
                            Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("Your waste this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      _buildStats("self", "general"),
                                    ]
                                )
                            ),

                            // This second expanded contains TEMBUSU WEEKLY TOTAL AVERAGE
                            Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("Tembusu average this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      _buildStats("tembusu", "general"),
                                    ]
                                )
                            ),
                          ]
                      ),

                      //Recyclables waste page
                      Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),

                            // This first expanded contains USER WEEKLY TOTAL
                            Expanded(
                                child: Column(
                                    children: <Widget>[

                                      Expanded(
                                          child: Text("Your recyclables this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      _buildStats("self", "all"),
                                    ]
                                )
                            ),

                            // This second expanded contains TEMBUSU WEEKLY TOTAL AVERAGE
                            Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("Tembusu average this week:",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.center)
                                      ),
                                      _buildStats("tembusu", "all"),
                                    ]
                                )
                            ),
                          ]
                      ),
                    ],
                  )

              ),

              // The second expanded is for the CHANGING VISUAL
              Expanded(
                  child: Container(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipOval(
                          child: PageView(
                            controller: _controller2,
                            children: [
                              trashBin(stateSelector(this.wasteThisWeek, this.areaAverageThisWeek)),
                              Image.asset('assets/recyclingIsland.png'),
                            ],
                            key: _keyVisual,
                          ),
                        ),
                      ),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white,
                            //color: Color(0xffCBC76C),
                            width: 5
                        ),
                        color: Colors.white,
                        //color: Color(0xffE4E5A3),
                      )
                  )
              ),

              // The third expanded is for the LIGHT BULB TIP
              Expanded(
                  child: Column(
                      children: <Widget>[
                        // This container is for the dots
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: selectionDots(context, stateSelector(this.wasteThisWeek, this.areaAverageThisWeek))
                        ),
                        SizedBox(
                          height: 15,
                        ),

                  Container(
                      alignment: Alignment.center,
                      padding: new EdgeInsets.only(
                          top:10,
                          right: 20.0,
                          left: 20.0),
                      child: new Container(
                        height: MediaQuery.of(context).size.height *.18,
                        width: MediaQuery.of(context).size.width,
                        child: new Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.green,
                          child:  Text("\nDaily Tip: \nAn apple a day keeps the doctor away",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),

                        ),
                      ),
                  )


                      ]
                  )
              ),
              // End of content

            ]
        ),
      ),
      */

      // End of appBody

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
