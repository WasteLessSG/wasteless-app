import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:LessApp/styles.dart';
import 'package:intl/intl.dart';

class FullPersonalStatsPage extends StatefulWidget{
  @override
  FullPersonalStatsPageState createState() => new FullPersonalStatsPageState();
}

class FullPersonalStatsPageState extends  State<FullPersonalStatsPage> {

  NumberFormat nf = NumberFormat("###.00", "en_US");

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

        //Styles.CommonHeader("Personal Statistics", FontWeight.bold, Colors.white),),
        body: Container(
            color: Colors.white,
            child: StreamBuilder(
              stream:  Firestore
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
                } else  return ListView.separated(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context,int index){
                    return ListTile(
                      tileColor: Colors.lightGreen[200],
                      title: Text(snapshot.data.documents[index]['timestamp2']),
                      subtitle: Text("Mass Thrown: " + snapshot.data.documents[index]['mass'].toString() + " kg"),
                    );

                    /* Original Code
                    return Container(
                      color: Colors.white, //is the background color. need to change to ListView.builder version
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
                    */
                    }, //itemBuilder

                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                );
              },
            ))
    );
  }
}