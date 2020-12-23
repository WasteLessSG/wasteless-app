import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:LessApp/styles.dart';
import 'package:intl/intl.dart';

class LeaderboardPage extends StatefulWidget{
  @override
  LeaderboardPageState createState() => new LeaderboardPageState();
}

class LeaderboardPageState extends  State<LeaderboardPage> {

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

            //TODO: Update and Filter list below based on Type and Trend selected above.
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

          ],
        ),
      )
    );
  }
}