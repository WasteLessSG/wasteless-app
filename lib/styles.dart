import 'package:LessApp/personal-stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:LessApp/debug.dart';
import 'package:intl/intl.dart';

class Styles {

  static AppBar MainStatsPageHeader(String string, FontWeight fw, Color chosenColor) {
    return AppBar(
      title: Text(string,
        style: TextStyle(
          fontWeight: fw,
          color: chosenColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      // actions: <Widget>[
      //   PopupMenuButton(
      //     icon: Icon(
      //       Icons.menu,
      //       color: Colors.black,),
      //     itemBuilder: (context) => [
      //       PopupMenuItem(
      //         child: Text("Log Out"),
      //         value: 1,
      //       ),
      //     ],
      //
      //     onCanceled: () {
      //       print("You have canceled the menu.");
      //     },
      //     onSelected: (value) {},
      //   )
      // ],
    );
  }

  static AppBar CommonHeader(String string, FontWeight fw, Color headerColor) {
    return AppBar(
      title: Text(string,
        style: TextStyle(
          fontWeight: fw,
          color: headerColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  static Text formatNumber(double doub) {
    NumberFormat nf = NumberFormat("###.00", "en_US"); //remove arithmetic float point issue
    return Text(nf.format(doub) + " kg",
      style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold
      ), );
  }

}