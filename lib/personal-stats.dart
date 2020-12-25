import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:LessApp/massEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:LessApp/styles.dart';
import 'package:LessApp/dashboard.dart';

class PersonalStatsPage extends StatefulWidget{
  @override
  PersonalStatsPageState createState() => new PersonalStatsPageState();
}

class PersonalStatsPageState extends State<PersonalStatsPage>{
  final title = ["Personal Trash Stats", "Personal Recycling Stats"];
  final now = DateTime.now();
  String selectedTime = "week";
  String selectedType = "general";
  List<bool> isSelectedTrend = [true, false, false];
  List<bool> isSelectedType = [false, true, false];
  List<bool> isSelectedTypeAll = [true, false];
  List<Color> colorPalette = [Colors.lightGreen[200], Colors.brown[100]];
  List<charts.Series<MassEntry, String>> _seriesBarData;
  List<charts.Series<formattedWeekEntry, String>> _weekSeriesBarData;
  List<charts.Series<MassEntry, DateTime>> _timeChartData;
  List<MassEntry> myData, massEntryDay;
  static int pageCounter = 15001;
  double personalWeekAverage = 0.00;
  double areaWeekAverage = 0.00;

  NumberFormat nf = NumberFormat("###.00", "en_US");

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

  @override
  Widget build(BuildContext context) {

    bool paperVisible = PersonalStatsPageState.pageCounter % 3 == 0;
    bool allVisible = PersonalStatsPageState.pageCounter % 3 == 1;
    bool plasticVisible = PersonalStatsPageState.pageCounter % 3 == 2;

    return Scaffold(
      appBar: Styles.MainStatsPageHeader(title[0], FontWeight.bold, Colors.black),

      body: Container(
        alignment: Alignment.center,
        color: Colors.white,

        child: Column(
          children: <Widget>[

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
            isSelectedTypeAll[0] ? Container(
              decoration: BoxDecoration(
                color:  isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
                borderRadius: BorderRadius.circular(5),
              ),
              height: 115,
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
                        personalWeekAverage = weeklyMass / 7.0;
                        //return getPersonalWeekTotal("House_A");
                        return Styles.formatNumber(todayMass);
                      }
                    },
                  )

                ],
              ),
            ) : new Container(),

            //today recyclables textbox
            isSelectedTypeAll[1] ? Container(
              decoration: BoxDecoration(
                color:  isSelectedTypeAll[0] ? colorPalette[1]: colorPalette[0],
                borderRadius: BorderRadius.circular(5),
              ),
              height: 115,
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
                      return Styles.formatNumber(0.00);
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
                      return Styles.formatNumber(weeklyMass);
                    }
                  }
              ),
                  */

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
                        //print(jsonEncode(massEntry).toString());
                        double todayMass = massEntry.fold(0, (previousValue, element) => previousValue + element.mass);
                        //return getPersonalWeekTotal("House_A");
                        return Styles.formatNumber(todayMass);
                      }
                    },
                  )
                ],
              ),
            ) : new Container(),


            //build the graph
            isSelectedTypeAll[0] ? _buildBody(context) : new Container(),
    ]
    )));
  }//, String time

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

  /*
  //new graph with data filtered to include type of trash thrown also
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
          return _chooseChart(context, massEntryRaw, selectedTime, selectedType);
          //return _chooseChart(context, massEntryRaw, time);
        }
      },
    );
  }
  */

  List<MassEntry> combineDays(List<MassEntry> rawdata){
    List<MassEntry> output = [];

    for ( var i = 0; i <rawdata.length; i++){
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
      formattedWeekEntry(0,"SUN")
    ];
    int currentTime = DateTime.now().weekday;
    for ( var i = currentTime; i >0; i--){
      var x = rawdata.where((element) =>
      element.dateTimeValue.weekday == i);
      if (x.isNotEmpty){
        output[i-1].mass = rawdata[rawdata.indexOf(x.toList()[0])].mass;
      }
      
    }



    return output;
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
                    personalWeekAverage, charts.RangeAnnotationAxisType.measure,
                    //startLabel: "Your week average: " + nf.format(personalWeekAverage) + "kg",
                    endLabel: "Your week average: " + nf.format(personalWeekAverage) + "kg",
                    color: charts.MaterialPalette.gray.shade400),
                //TODO: NEED TO ADD TEMBUSU'S WEEKLY AVERAGE. SIMILAR IMPLEMENTATION TO ABOVE.
              ])
            ],
          ),
        );
      }
      break;

      case "month":{
        myData = massdata.where((i)=> i.dateTimeValue.month == DateTime.now().month )
            .toList();
        // myData = massdata.where((i)=> DateTime.parse(i.timestamp).isAfter(DateTime.now().subtract(Duration(days: 30)))  )
        //     .toList();
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



}


