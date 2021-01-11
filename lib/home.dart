import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:WasteLess/history.dart';
import 'package:WasteLess/dashboard-new.dart';
import 'package:WasteLess/settings.dart';

class HomePage extends StatefulWidget{

  final FirebaseUser user;
  HomePage(this.user);

  @override
  HomePageState createState() => new HomePageState(this.user);
}
class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  FirebaseUser user;

  HomePageState(this.user);

  TabController controller;

  @override
  void initState() {
    super.initState();
    print(user.uid);
    controller = new TabController(vsync: this, length: 3, initialIndex: 1);
  }



  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(user.uid);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(

          bottomNavigationBar: new TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.green,
            controller: controller ,
            tabs: <Tab> [
              new Tab(icon: Icon(Icons.account_box),) ,
              new Tab(icon: Icon(Icons.home),) ,
              new Tab(icon: Icon(Icons.settings),) ,

            ],

          ),



          body: new TabBarView(

              physics: NeverScrollableScrollPhysics(),
              controller: controller,
              children: <Widget>[
                new HistoryPage(user),
                new DashboardPage(user),
                new SettingsPage(user),

            ])
      ),
    );
  }



}



