import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityStatsPage extends StatefulWidget{
  @override
  CommunityStatsPageState createState() => new CommunityStatsPageState();
}

class CommunityStatsPageState extends  State<CommunityStatsPage> {
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
          actions: <Widget>[
            PopupMenuButton(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("All Time"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Month"),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text("Week"),
                  value: 3,
                ),
                PopupMenuItem(
                  child: Text("Today"),
                  value: 4,
                ),
              ],

              onCanceled: () {
                print("You have canceled the menu.");
              },
              onSelected: (value) {},
            )

          ]
      ),
      body: Container(
          color: Colors.white,
        child: StreamBuilder(
          stream:  Firestore
              .instance
              .collection("houses")
              .orderBy('alltime', descending: true)
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
                      title: Text(snapshot.data.documents[index].documentID),
                    subtitle: Text("All Time Mass Thrown: " + snapshot.data.documents[index]['alltime'].toString() + "kg"),
                  ),
                );}, //itemBuilder
            );
          },
        ))
      );
  }
}