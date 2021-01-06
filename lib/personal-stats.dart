import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:LessApp/massEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:LessApp/styles.dart';
import 'package:LessApp/dashboard.dart';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:LessApp/wasteless-data.dart';

class PersonalStatsPage extends StatefulWidget{
  final FirebaseUser user;
  PersonalStatsPage(this.user);
  @override
  PersonalStatsPageState createState() => new PersonalStatsPageState(this.user);
}

class PersonalStatsPageState extends State<PersonalStatsPage>{
  FirebaseUser user;
  PersonalStatsPageState(this.user);

  final now = DateTime.now();
  String selectedTime = "week";
  String selectedType = "general";
  List<bool> isSelectedTrend = [true, false, false];
  List<bool> isSelectedType = [false, true, false];

  List<bool> isSelectedTypeAll = [true, false];
  List<String> title = ["Personal Trash Stats", "Personal Recycling Stats"];

  List<Color> colorPalette = [Colors.lightGreen[200], Colors.brown[100]];
  List<charts.Series<MassEntry, String>> _seriesBarData;
  List<charts.Series<formattedWeekEntry, String>> _weekSeriesBarData;
  List<charts.Series<MassEntry, DateTime>> _timeChartData;
  List<MassEntry> myData, massEntryDay;
  static int pageCounter = 15001;

  double personalWeekAverageGeneral = 0.00;
  double areaWeekAverageGeneral = 0.00;

  double personalWeekAverageAll = 0.00;
  double areaWeekAverageAll = 0.00;
  double personalWeekAveragePlastic = 0.00;
  double areaWeekAveragePlastic = 0.00;
  double personalWeekAveragePaper = 0.00;
  double areaWeekAveragePaper = 0.00;


  NumberFormat nf = NumberFormat("#00.00", "en_US");
  final df3 = DateFormat.yMMMd();
  final dfFilter = DateFormat("yyyy-MM-dd");
  int userID = 1234;
  List list = List();
  Map map = Map();
  AsyncMemoizer _memoizer;
  bool isSelected = false;

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
  }

  /*
  _fetchData(String party, String type) async {

    setState(() {
      if (isSelectedTypeAll[0]) {
        selectedType = "general";
      } else {
        if (PersonalStatsPageState.pageCounter % 3 == 0) {
          selectedType = "plastic";
        } else if (PersonalStatsPageState.pageCounter % 3 == 1) {
          selectedType = "all";
        } else {
          selectedType = "plastic";
        }
      }
    });

    return this._memoizer.runOnce(() async {

      String link;

      if (party == "self") {
        link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${WasteLessData.userID.toString()}?aggregateBy=day&timeRangeStart=0&timeRangeEnd=1608364825&type=${type}";
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

    setState(() {
      if (isSelectedTypeAll[0]) {
        selectedType = "general";
      } else {
        if (PersonalStatsPageState.pageCounter % 3 == 0) {
          selectedType = "plastic";
        } else if (PersonalStatsPageState.pageCounter % 3 == 1) {
          selectedType = "all";
        } else {
          selectedType = "plastic";
        }
      }
    });


    String timeRangeStartValue;
    String timeRangeEndValue = (now.millisecondsSinceEpoch * 1000).toString();

    if (selectedTime == "allTime") {
      //TODO: AFTER TESTING, CHANGE THIS VALUE. should at least be 1609926000
      timeRangeStartValue = "0"; //6th Jan, 2021, 5.53pm
    } else if (selectedTime == "month") {
      timeRangeStartValue = (prevMonth.millisecondsSinceEpoch * 1000).toString();
    } else {
      timeRangeStartValue = (prevWeek.millisecondsSinceEpoch * 1000).toString();
    }

    String link;

    if (party == "self") {
      link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste/${user.uid.toString()}?aggregateBy=day&timeRangeStart=${timeRangeStartValue}&timeRangeEnd=${timeRangeEndValue}&type=${type}";
    } else {
      link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/waste?aggregateBy=day&timeRangeStart=${timeRangeStartValue}&timeRangeEnd=${timeRangeEndValue}&type=${type}";
    }

    final response = await http.get(link, headers: {"x-api-key": WasteLessData.userKey});
    if (response.statusCode == 200) {
      map = json.decode(response.body) as Map;
      list = map["data"];
    } else {
      throw Exception('Failed to load data');
    }

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
            for (int i = 0; i < isSelectedTypeAll.length; i++) {
              if (isSelectedTypeAll[i]) {
                isSelectedTypeAll[i] = false;
              } else {
                isSelectedTypeAll[i] = true;
              }
            }
            isSelected = value;
          });
        }
    );
  }



  _generateData(myData) {
    _seriesBarData = List<charts.Series<MassEntry, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (MassEntry massEntry, _) => massEntry.timestamp,
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }
  _generateDailyData(myData) {
    _seriesBarData = List<charts.Series<MassEntry, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (MassEntry massEntry, _) => DateFormat.Hm().format(massEntry.dateTimeValue),
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }
  _generateComDayData(myData) {
    _seriesBarData = List<charts.Series<MassEntry, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (MassEntry massEntry, _) => massEntry.day,
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        seriesColor: charts.ColorUtil.fromDartColor(isSelectedTypeAll[0] ? Colors.brown : Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }

  _generateWeeklyData(myData) {
    _weekSeriesBarData = List<charts.Series<formattedWeekEntry, String>>();
    _weekSeriesBarData.add(
      charts.Series(
        domainFn: (formattedWeekEntry e, _) => e.day,
        measureFn: (formattedWeekEntry e, _) => e.mass,
        seriesColor: charts.ColorUtil.fromDartColor(isSelectedTypeAll[0] ? Colors.brown : Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }
  _generateTimeChartData(myData) {
    _timeChartData = List<charts.Series<MassEntry, DateTime>>();

    _timeChartData.add(
      charts.Series(
        domainFn: (MassEntry massEntry, _) => massEntry.dateTimeValue,
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        colorFn: (_, __) => isSelectedTypeAll[0] ? charts.MaterialPalette.deepOrange.shadeDefault: charts.MaterialPalette.green.shadeDefault,
        areaColorFn: (MassEntry massEntry, _) => isSelectedTypeAll[0] ? charts.MaterialPalette.deepOrange.shadeDefault.lighter : charts.MaterialPalette.green.shadeDefault.lighter,
        // seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }

  static Text getPersonalWeekTotal(String house) {

    StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('houses')
            .document(house)
            .collection("RawData")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Styles.formatNumber(0.00);
          }
          else {
            print(snapshot.toString());
            List<MassEntry> weekData = snapshot.data.documents
                .map((documentSnapshot) =>
                MassEntry.fromMap(documentSnapshot.data))
                .toList()
                .where((i) =>
                DateTime.parse(i.timestamp).isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                    .subtract(Duration(days: 6))))
                .toList();
            double weeklyMass = weekData.fold(0, (previousValue, element) => previousValue + element.mass);
            debugPrint(weeklyMass.toString());
            return Styles.formatNumber(38.2);
          }
        }
    );
  }

  Widget trendAverageBar() {
    if (isSelectedTrend[0]) {
      return Container(
        decoration: BoxDecoration(
          color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
          //Colors.lightGreen[200],
          borderRadius: BorderRadius.circular(5),
        ),
        height: 50,
        width: MediaQuery.of(context).size.width/1.05,
        padding: EdgeInsets.all(7),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            Container(
              child: Text("Personal\nWeek Average: ",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatsInfo("self", selectedTime, selectedTime, Colors.purple),

            Container(
              child: Text("Tembusu\nWeek Average: ",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatsInfo("self", selectedTime, selectedTime, Colors.teal.shade900),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
          //Colors.lightGreen[200],
          borderRadius: BorderRadius.circular(5),
        ),
        height: 50,
        width: MediaQuery.of(context).size.width/1.05,
        padding: EdgeInsets.all(7),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            Container(
              child: Text("Personal\nMonth Average: ",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatsInfo("self", selectedTime, selectedType, Colors.purple),

            Container(
              child: Text("Tembusu\nMonth Average: ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatsInfo("self", selectedTime, selectedType, Colors.teal.shade900),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    bool paperVisible = PersonalStatsPageState.pageCounter % 3 == 0;
    bool allVisible = PersonalStatsPageState.pageCounter % 3 == 1;
    bool plasticVisible = PersonalStatsPageState.pageCounter % 3 == 2;

    String currentTitle;
    if (isSelectedTypeAll[0]) {
      currentTitle = title[0];
    } else {
      currentTitle = title[1];
    }

    return Scaffold(
      //appBar: Styles.MainStatsPageHeader(title[0], FontWeight.bold, Colors.black),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title:

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(currentTitle,
              style: TextStyle(
                color: Colors.white,
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width / 10,
            ),

            _buildSwitch(),
          ],
        ),

        /*
        ButtonTheme(
          minWidth: MediaQuery.of(context).size.width/1.05,
          height: 10.0,
          child: RaisedButton(
            elevation: 10.0,
            color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
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
                for (int i = 0; i < isSelectedTypeAll.length; i++) {
                  if (isSelectedTypeAll[i]) {
                    isSelectedTypeAll[i] = false;
                  } else {
                    isSelectedTypeAll[i] = true;
                  }
                }
              });
            },
          ),
        ),
        */



        backgroundColor: Colors.green[900],
        elevation: 0,

      ),


      body: Container(
        alignment: Alignment.center,
        color: Colors.white,

        child: Column(
          children: <Widget>[

            /*
            Container(
                decoration: BoxDecoration(
                  color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
                  borderRadius: BorderRadius.circular(5),
                ),
                height: 40,
                width: MediaQuery.of(context).size.width/1.05,
                padding: EdgeInsets.all(7),
                child:

                Center(
                  child: ToggleButtons(
                    renderBorder: false,
                    children: <Widget>[
                      Text("  General  ",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text("  Recyclables  ",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    onPressed: (int index) {
                      setState(() {
                        switch(index){
                          case 0: {selectedType = "general";}
                          break;
                          case 1: {selectedType = "recyclables";}
                          break;
                        }

                        for (int buttonIndex = 0; buttonIndex < isSelectedTypeAll.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelectedTypeAll[buttonIndex] = true;
                          } else {
                            isSelectedTypeAll[buttonIndex] = false;
                          }
                        }
                      });
                    },
                    isSelected: isSelectedTypeAll,
                  ),
                )
            ),

            */

            isSelectedTypeAll[1] ? SizedBox(
              height: 10,
            ) : new Container(),

            //type selection
            isSelectedTypeAll[1] ? Container(
                decoration: BoxDecoration(
                  color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
            //Colors.lightGreen[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                height: 40,
                width: MediaQuery.of(context).size.width/1.05,
                padding: EdgeInsets.all(7),
                child: Center(
                  child: Row(
                    children: <Widget>[

                      FlatButton(
                        child: Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            PersonalStatsPageState.pageCounter--;
                          });
                        },
                      ),

                      allVisible ? Text("               All                ",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ) : new Container(),

                      paperVisible ? Text("              Paper            ",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ) : new Container(),

                      plasticVisible ? Text("            Plastic            ",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ) : new Container(),

                      FlatButton(
                        child: Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            PersonalStatsPageState.pageCounter++;
                          });
                        },
                      ),

                    ],
                  ),
                )
            ) : new Container(),

            SizedBox(
              height: 10,
            ),

            //trend selection
            Container(
              decoration: BoxDecoration(
                color: isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
                borderRadius: BorderRadius.circular(5),
              ),
              height: 40,
              width: MediaQuery.of(context).size.width/1.05,
              padding: EdgeInsets.all(7),
              child: Center(
                child: ToggleButtons(
                  renderBorder: false,

                  children: <Widget>[
                    Text("  Week  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("  Month  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("  All Time  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      switch(index){
                        case 0: {selectedTime = "week";}
                        break;
                        case 1: {selectedTime = "month";}
                        break;
                        case 2: {selectedTime = "allTime";}
                        break;
                      }

                      for (int buttonIndex = 0; buttonIndex < isSelectedTrend.length; buttonIndex++) {
                        if (buttonIndex == index) {
                          isSelectedTrend[buttonIndex] = true;
                        } else {
                          isSelectedTrend[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: isSelectedTrend,
                ),
              )
            ),

            SizedBox(
              height: 10,
            ),

            //today trash textbox
            Container(
              decoration: BoxDecoration(
                color:  isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
                borderRadius: BorderRadius.circular(5),
              ),
              height: 90,
              width: MediaQuery.of(context).size.width/1.05,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Text("Today you threw away",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),

                  SizedBox(
                      height:5
                  ),

                  _buildStatsDailyInfo("self"),

              /*
              //for week's worth of trash thrown
              StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('houses')
                      .document("House_A")
                      .collection("RawData")
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      //return Styles.formatNumber(0.00);
                      return new Container();
                    }
                    else {
                      List<MassEntry> weekData = snapshot.data.documents
                          .map((documentSnapshot) =>
                          MassEntry.fromMap(documentSnapshot.data))
                          .toList()
                          .where((i) =>
                          DateTime.parse(i.timestamp).isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                              .subtract(Duration(days: 6))))
                          .toList();
                      double weeklyMass = weekData.fold(0, (previousValue, element) => previousValue + element.mass);
                      //debugPrint(weeklyMass.toString());
                      //return Styles.formatNumber(weeklyMass);
                      setState(() {
                        personalWeekAverage = weeklyMass / 7;
                      });
                      return new Container();
                    }
                  }
              ),
                  */

                  /*
                  //for amount thrown today by user
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('houses')
                        .document("House_A")
                        .collection("RawData")
                        .where("timestamp2", isEqualTo: DateFormat('d MMM y').format(DateTime.now()).toString() )
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      } else if (snapshot.data.documents.length == 0) {
                        return Text("0.00 kg",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold
                          ),);
                      } else {
                        List<MassEntry> massEntry = snapshot.data.documents
                            .map((documentSnapshot) => MassEntry.fromMap(documentSnapshot.data))
                            .toList();

                        //to change the average value for each person.
                        List<MassEntry> weekData = snapshot.data.documents
                            .map((documentSnapshot) =>
                            MassEntry.fromMap(documentSnapshot.data))
                            .toList()
                            .where((i) =>
                            DateTime.parse(i.timestamp).isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                                .subtract(Duration(days: 6))))
                            .toList();

                        //print(jsonEncode(massEntry).toString());
                        double todayMass = massEntry.fold(0, (previousValue, element) => previousValue + element.mass);
                        double weeklyMass = weekData.fold(0, (previousValue, element) => previousValue + element.mass);
                        personalWeekAverageGeneral = weeklyMass / 7.0;
                        //return getPersonalWeekTotal("House_A");
                        return Styles.formatNumber(todayMass);
                      }
                    },
                  )
                  */

                ],
              ),
            ),

            SizedBox(
                height: 10,
            ),

            (isSelectedTrend[0] || isSelectedTrend[1] ) ? trendAverageBar() : new Container(),

            //build the graph
            FutureBuilder(
              future: _fetchData("self", selectedType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildBody(context);
                } else {
                  return CircularProgressIndicator();
                }
              }
            ),
             //_buildBody(context),

    ]
    )));
  }//, String time


  MassEntry massEntryGenerator(int time, int weight) {

    final df4 = new DateFormat('d MMM yyyy');
    final df5 = new DateFormat('MMM');

    double mass = double.parse(weight.toString());
    DateTime dateTimeValue = DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String timestamp = dateTimeValue.toIso8601String();
    String shortenedTime = df4.format(dateTimeValue).toString();
    String day = dateTimeValue.day.toString();
    String month = df5.format(dateTimeValue).toString();
    String year = dateTimeValue.year.toString();

    return MassEntry(mass, timestamp, shortenedTime, dateTimeValue, day, month, year);
  }

  Widget _buildBody(BuildContext context) {

    //_fetchData("self", selectedType);
    //WasteLessData data = new WasteLessData();
    //List retrievedList = data.getListPersonalStats("self", selectedType);
    //this.list = retrievedList;

    List<MassEntry> nextList = list.map((entry) => massEntryGenerator(entry["time"], entry["weight"])).toList();
    return _chooseChart(context, nextList, selectedTime);
  }

  Widget _chooseChart(BuildContext context, List<MassEntry> massdata, String time) {

    switch(time){
      case "week":{

        myData = massdata.where((i)=> DateTime.parse(i.timestamp).isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
            .toList();
        _generateWeeklyData(formatWeekdays(combineDays(myData)));
        print(DateTime.now().weekday.toString());

        return Expanded(
          child: charts.BarChart(_weekSeriesBarData,
            animate: true, behaviors: [
              new charts.RangeAnnotation([
                new charts.LineAnnotationSegment(
                    personalWeekAverageGeneral, charts.RangeAnnotationAxisType.measure,
                    color: charts.MaterialPalette.purple.shadeDefault),

                new charts.LineAnnotationSegment(
                    areaWeekAverageGeneral, charts.RangeAnnotationAxisType.measure,
                    color: charts.MaterialPalette.teal.shadeDefault),
              ])
            ],
          ),
        );
      }
      break;

      case "month": {
        myData = massdata.where((i)=> (i.dateTimeValue.month == DateTime.now().month)
        && (i.dateTimeValue.year == DateTime.now().year))
            .toList();
        _generateComDayData(fillInDays(combineDays(myData)));
        return Expanded(
          child: charts.BarChart(_seriesBarData,
            animate: true,
          ),
        );
      }
      break;

      case "allTime":{
        myData = massdata;
        _generateTimeChartData(fillInDays(combineDays(myData)));
        return Expanded(
          child: charts.TimeSeriesChart(_timeChartData,
            animate: true,
            defaultRenderer:
            new charts.LineRendererConfig(includeArea: true, stacked: true),
          ),
        );
      }
      break;

      default: {
        //same as today
        myData = massdata.where((i)=> i.shortenedTime == DateFormat('d MMM y').format(DateTime.now()).toString())
            .toList();
        _generateData(myData);
        return Expanded(
          child: charts.BarChart(_seriesBarData,
            animate: true,),
        );
      }
      break;
    }
  }





  /*
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('houses')
          .document("House_A")
          .collection("RawData")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          List<MassEntry> massEntryRaw = snapshot.data.documents
              .map((documentSnapshot) => MassEntry.fromMap(documentSnapshot.data))
              .toList();
          return _chooseChart(context, massEntryRaw, selectedTime);
          //return _chooseChart(context, massEntryRaw, time);
        }
      },
    );
  }
  */


  List<MassEntry> combineDays(List<MassEntry> rawdata){
    List<MassEntry> output = [];
    if (rawdata.isEmpty) {
      return rawdata;
    }

    for (var i = 0; i < rawdata.length; i++) {

      if (output.where((element) =>
          element.shortenedTime
              == rawdata[i].shortenedTime).isEmpty){
        output.add(rawdata[i]);
      }
      else {
         var x = output.where((element) =>
         element.shortenedTime
             == rawdata[i].shortenedTime).toList()[0];
         var index = output.indexOf(x);
         output[index].mass = output[index].mass + rawdata[i].mass;
      }

    }
    return output;
  }
  
  List<MassEntry> fillInDays(List<MassEntry> rawdata) {
    if (rawdata.isEmpty) {
      return rawdata;
    }

    var now = new DateTime.now();
    final firstEntryDate = rawdata[0].dateTimeValue;
    var timeFromFirstEntryInSeconds = now.difference(firstEntryDate);
    var daysFromStart = timeFromFirstEntryInSeconds.inDays;
    int iteratorIndicator = 0;

    for (var i = 1; i<daysFromStart; i++) {
      var iteratedDateTime = rawdata[0].dateTimeValue.add(Duration(days:i));
      var iteratedShortenedTime = DateFormat('d MMM y').format(iteratedDateTime);
      if (rawdata.firstWhere((e) => e.shortenedTime == iteratedShortenedTime, orElse: () => null) == null) {
        var iteratedMassEntry = new MassEntry(
          0.0,
          iteratedDateTime.toString(),
          iteratedShortenedTime,
          iteratedDateTime,
          DateFormat('d').format(iteratedDateTime).toString(),
          DateFormat('MMM').format(iteratedDateTime).toString(),
          DateFormat('y').format(iteratedDateTime).toString(),
        );
        iteratorIndicator += 1;
        rawdata.insert(iteratorIndicator, iteratedMassEntry);
      } else {
        iteratorIndicator += 1;
      }
    }
    return rawdata;
  }

  List<formattedWeekEntry> formatWeekdays(List<MassEntry> rawdata){
    List<formattedWeekEntry> output = [
      formattedWeekEntry(0,"MON"),
      formattedWeekEntry(0,"TUE"),
      formattedWeekEntry(0,"WED"),
      formattedWeekEntry(0,"THU"),
      formattedWeekEntry(0,"FRI"),
      formattedWeekEntry(0,"SAT"),
      formattedWeekEntry(0,"SUN"),
    ];

    int currentTime = DateTime.now().weekday;

    for ( var i = currentTime; i > 0; i--){
      var x = rawdata.where((element) =>
      element.dateTimeValue.weekday == i);

      if (x.isNotEmpty){
        output[i-1].mass = rawdata[rawdata.indexOf(x.toList()[0])].mass;
      }
    }
    return output;
  }

  Widget _buildStatsDailyInfo(String party) {

    setState(() {
      if (isSelectedTypeAll[0]) {
        selectedType = "general";
      } else {
        if (PersonalStatsPageState.pageCounter % 3 == 0) {
          selectedType = "plastic";
        } else if (PersonalStatsPageState.pageCounter % 3 == 1) {
          selectedType = "all";
        } else {
          selectedType = "plastic";
        }
      }
    });

    //WasteLessData data = new WasteLessData();
    //List retrievedList = data.getListDashboard(party, selectedType);
    //this.list = retrievedList;

    var now = new DateTime.now();

    List newList = list.map((entry) => massEntryGenerator(entry["time"], entry["weight"])).where((i)=> i.shortenedTime == DateFormat('d MMM y').format(DateTime.now()).toString())
        .toList();

    double totalValue = newList.fold(0, (current, entry) => current + entry["weight"]);

    return Expanded(
        child: Text(nf.format(totalValue) + "kg",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        )
    );
  }

  Widget _buildStatsInfo(String party, String trend, String type, Color color) {

    var now = new DateTime.now();

    setState(() {
      if (isSelectedTypeAll[0]) {
        selectedType = "general";
      } else {
        if (PersonalStatsPageState.pageCounter % 3 == 0) {
          selectedType = "plastic";
        } else if (PersonalStatsPageState.pageCounter % 3 == 1) {
          selectedType = "all";
        } else {
          selectedType = "plastic";
        }
      }
    });

    List newList;
    double averageValue;

    switch(trend) {

      case "week": {
        newList = list.where((entry) => DateTime.parse(dfFilter.format(DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000)).toString())
            .isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
            .toList();
        averageValue = newList.fold(0, (current, entry) => current + entry["weight"]) / 7.0;
      }
      break;

      //for month data
      default: {
        newList = list.where((entry)=> (DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000).month == DateTime.now().month)
        && (DateTime.fromMillisecondsSinceEpoch(entry["time"] * 1000).year == DateTime.now().year))
            .toList();
        averageValue = newList.fold(0, (current, entry) => current + entry["weight"]) / 31.0;
      }
    }

    setState(() {
      if (type == "general") {
        if (party == "self") {
          personalWeekAverageGeneral = averageValue;
        } else {
          areaWeekAverageGeneral = averageValue;
        }
      } else if (type == "all") {
        if (party == "self") {
          personalWeekAverageAll = averageValue;
        } else {
          areaWeekAverageAll = averageValue;
        }
      } else if (type == "paper") {
        if (party == "self") {
          personalWeekAveragePaper = averageValue;
        } else {
          areaWeekAveragePaper = averageValue;
        }
      } else {
        if (party == "self") {
          personalWeekAveragePlastic = averageValue;
        } else {
          areaWeekAveragePlastic = averageValue;
        }
      }
    });

    return Expanded(
        child: Text(nf.format(averageValue) + "kg",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        )
    );
  }




}


