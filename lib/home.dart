import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LessApp/personal-stats.dart';
import 'package:LessApp/debug.dart';
import 'package:LessApp/leaderboard.dart';
import 'package:LessApp/history.dart';
import 'package:LessApp/dashboard.dart';
import 'package:LessApp/settings.dart';
import 'package:LessApp/styles.dart';

class HomePage extends StatefulWidget{

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {

  int _selectedIndex = 2;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  List<Widget> _widgetOptions = <Widget>[
    new HistoryPage(),
    new PersonalStatsPage(),
    new DashboardPage(),
    new LeaderboardPage(),
    new SettingsPage()
    //new DebugPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            title: Text('Stats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Summary'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            title: Text('Leaderboard'),
          ),


          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Setting'),
          ),


        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}





