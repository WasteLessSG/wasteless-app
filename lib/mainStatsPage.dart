import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:LessApp/massentry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MainStatsPage extends StatefulWidget{
  @override
  MainStatsPageState createState() => new MainStatsPageState();
}

class MainStatsPageState extends State<MainStatsPage>{

  List<charts.Series<MassEntry, String>> _seriesBarData;
  List<MassEntry> mydata;
  _generateData(mydata) {
    _seriesBarData = List<charts.Series<MassEntry, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (MassEntry massEntry, _) => massEntry.timestamp.toString(),
        measureFn: (MassEntry massEntry, _) => massEntry.mass,
        seriesColor: charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Mass',
        data: mydata
//        ,
//        labelAccessorFn: (MassEntry row, _) => "${row.timestamp}",
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
        actions: <Widget>[IconButton(
          icon: Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {},
        ),]
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
                  Text("100kg",
                    style: TextStyle(
                      fontSize: 50,
                        fontWeight: FontWeight.bold
                    ),),


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
              child: Row(
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

                        child: Text("14.0 Kg",
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

                        child: Text("14.0 Kg",
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
                child:Text("Waste Over Time",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),)
              ),
            ),
            _buildBody(context),
    ]
    )));
  }
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(

      stream: Firestore.instance
          .collection('houses')
          .document("House_A")
          .collection("RawData")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          List<MassEntry> massEntry = snapshot.data.documents
              .map((documentSnapshot) => MassEntry.fromMap(documentSnapshot.data))
              .toList();
          return _buildChart(context, massEntry);
        }
      },
    );
  }
  Widget _buildChart(BuildContext context, List<MassEntry> massdata) {
    mydata = massdata;
    _generateData(mydata);
    return Expanded(
      child: charts.BarChart(_seriesBarData,
        animate: false,),
    );
  }






}




//,
//behaviors: [
//new charts.DatumLegend(
//entryTextStyle: charts.TextStyleSpec(
//color: charts.MaterialPalette.purple.shadeDefault,
//fontFamily: 'Georgia',
//fontSize: 18),
//)
//],