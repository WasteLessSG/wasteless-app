import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FullPersonalStatsPage extends StatefulWidget{
  @override
  FullPersonalStatsPageState createState() => new FullPersonalStatsPageState();
}

class FullPersonalStatsPageState extends  State<FullPersonalStatsPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text("All Time Stats",
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
                } else  return ListView.builder(
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
                              child: Text(index.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,),),
                            )
                          ],
                        ),
                        title: Text("Date: "+snapshot.data.documents[index]['timestamp2']),
                        subtitle: Text("Mass Thrown: " + snapshot.data.documents[index]['mass'].toString() + " kg"),
                      ),
                    );}, //itemBuilder
                );
              },
            ))
    );
  }
}


/*
*
* stream: Firestore.instance
                        .collection('houses')
                        .document("House_A")
                        .collection("RawData")
                        .where("timestamp2", isEqualTo: DateFormat('d MMM y').format(DateTime.now()).toString() )
                        .snapshots(),
*
*
* */