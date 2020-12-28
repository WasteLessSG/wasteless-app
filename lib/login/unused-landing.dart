import 'package:flutter/material.dart';
import 'package:LessApp/login/unused-register.dart';
import 'package:LessApp/login/login.dart';

class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[




                   Text(
                   "Less.",
                   style: TextStyle(
                     fontSize: 120,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                     fontFamily: 'Helvectica',
                   ),
                 ),



                SizedBox(
                  height: 40,
                ),

                PageButton(
                  title: "Log in",
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                ),
                PageButton(
                  title: "Register",
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                ),
              ],
            )));
  }
}

class PageButton extends StatelessWidget {
  final String title;
  final VoidCallback callback;

  const PageButton({Key key, this.title, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Material(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(50.0),
        child: MaterialButton(
          minWidth: 300,
          onPressed: callback,
          height: 45,
          child: Text(title,
            style: TextStyle(
              color: Colors.black,
              //fontWeight: FontWeight.bold,
              fontSize: 30,
            ),),
        ),
      ),
    );
  }
}
