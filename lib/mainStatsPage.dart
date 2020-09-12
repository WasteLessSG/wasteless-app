
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:LessApp/massEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class MainStatsPage extends StatefulWidget{
  @override
  MainStatsPageState createState() => new MainStatsPageState();
}

class MainStatsPageState extends State<MainStatsPage>{
  final now = DateTime.now();
  String selectedTime = "today";
  List<bool> isSelected = [true, false, false, false];
  List<charts.Series<MassEntry, String>> _seriesBarData;
  List<charts.Series<formattedWeekEntry, String>> _weekSeriesBarData;
  List<charts.Series<MassEntry, DateTime>> _timeChartData;
  List<MassEntry> myData, massEntryDay;
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
        domainFn: (MassEntry massEntry, _) => massEntry.shortenedTime.substring(0,massEntry.shortenedTime.length-5),
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
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
        seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
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
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        areaColorFn: (MassEntry massEntry, _) => charts.MaterialPalette.green.shadeDefault.lighter,
        // seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Mass',
        data: myData,

      ),
    );
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Home",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Log Out"),
                value: 1,
              ),
            ],

            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {},
          )

        ],
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          children: <Widget>[

            Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen[200],
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
                  ),),
                  SizedBox(
                    height:5
                  ),
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
                        return Text("0kg",
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
                        return Text( todayMass.toString() + " kg",
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold
                          ),);
                      }
                    },
                  )

                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width/1.05,
              height: 35,
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Colors.lightGreen[200],
                  borderRadius: BorderRadius.circular(5)
              ),
              child:
              StreamBuilder<QuerySnapshot>(

                stream: Firestore.instance
                    .collection('houses')
                    .document("House_A")
                    .collection("RawData")
                    .snapshots(),
                builder: (context, snapshot) {


                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  // else if (snapshot.data.documents.length == 0) {
                  //   return Text("0kg",
                  //     style: TextStyle(
                  //         fontSize: 50,
                  //         fontWeight: FontWeight.bold
                  //     ),);
                  // }
                  else {
                    List<MassEntry> weekData = snapshot.data.documents
                        .map((documentSnapshot) => MassEntry.fromMap(documentSnapshot.data))
                        .toList()
                        .where((i)=> DateTime.parse(i.timestamp).isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6))))

                        .toList();
                    double weeklyMass = weekData.fold(0, (previousValue, element) => previousValue + element.mass);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: Text("Weekly Target: ",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),),
                            ),
                            Container(

                              child: Text("TBD Kg",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),),
                            ),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: Text("Weekly Total: ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),),
                            ),

                            Container(

                              child: Text(weeklyMass.toString() +" Kg",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),),

                            ),




                          ],
                        ),
                      ],
                    );
                  }
                },
              ),






            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightGreen[200],
                borderRadius: BorderRadius.circular(5),
              ),
              height: 40,
              width: MediaQuery.of(context).size.width/1.05,
              padding: EdgeInsets.all(7),
              child: Center(
                child: ToggleButtons(
                  renderBorder: false,

                  children: <Widget>[
                    Text("  Today  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),),
                    Text("  Week  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),),
                    Text("  Month  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),),
                    Text("  All Time  ",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      switch(index){
                        case 0: {selectedTime = "today";}
                        break;
                        case 1: {selectedTime = "week";}
                        break;
                        case 2: {selectedTime = "month";}
                        break;
                        case 3: {selectedTime = "allTime";}
                        break;
                      }
                      for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                        if (buttonIndex == index) {
                          isSelected[buttonIndex] = true;
                        } else {
                          isSelected[buttonIndex] = false;
                        }
                      }
                    });
                  },
                  isSelected: isSelected,
                ),
              )
            ),
            _buildBody(context),
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
    //TODO: Change all time graph to line chart
    switch(time){
      case "today":{
        myData = massdata.where((i)=> i.shortenedTime == DateFormat('d MMM y').format(DateTime.now()).toString())
            .toList();
        _generateDailyData(myData);
        return Expanded(
          child: charts.BarChart(_seriesBarData,
            animate: true,),
        );
      }
      break;
      case "week":{

        myData = massdata.where((i)=> DateTime.parse(i.timestamp).isAfter(DateTime(now.year, now.month, now.day).subtract(Duration(days: 6)))  )
            .toList();
        _generateWeeklyData(formatWeekdays(combineDays(myData)));
        print(DateTime.now().weekday.toString());
        return Expanded(
          child: charts.BarChart(_weekSeriesBarData,
            animate: true,),
        );
      }

      break;
      case "month":{
        myData = massdata.where((i)=> i.dateTimeValue.month == DateTime.now().month )
            .toList();
        // myData = massdata.where((i)=> DateTime.parse(i.timestamp).isAfter(DateTime.now().subtract(Duration(days: 30)))  )
        //     .toList();
        _generateComDayData(combineDays(myData));
        return Expanded(
          child: charts.BarChart(_seriesBarData,
            animate: true,),
        );
      }
      break;
      case "allTime":{
        myData = massdata;
        _generateTimeChartData(combineDays(myData));
        return Expanded(
          child: charts.TimeSeriesChart(_timeChartData,
              animate: true,
            defaultRenderer:
                new charts.LineRendererConfig(includeArea: true, stacked: true),
          ),
        );
      }
      break;

      default:{
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


