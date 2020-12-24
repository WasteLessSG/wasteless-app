import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:LessApp/styles.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget{
  @override
  HistoryPageState createState() => new HistoryPageState();
}

class HistoryPageState extends  State<HistoryPage> {

  NumberFormat nf = NumberFormat("###.00", "en_US");
  String _selectedType = "General";
  String _selectedTrend = "Week";

  List<bool> _typeChosen = [true, false];
  List<String> _typeList = ["General", "Recyclables"];

  List<bool> _trendChosen = [true, false, false];
  List<String> _trendList = ["Week", "Month", "All Time"];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text("History",
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
            ],
          )
        )
    );
  }
}