import 'package:LessApp/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LessApp/home.dart';


class Login extends StatefulWidget {

  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {
  String email, password;
//Firebase doesnt support custom usernames, username must be in form of email
//final GlobalKey<FormState> _formkey = GlobalKey<FormState> ();




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,


            children: <Widget>[
              SizedBox(height:  MediaQuery.of(context).size.height *0.08),
              Text("WasteLess",
               textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text("Email",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value.trim(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your email",
                  border: const OutlineInputBorder(),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Text("Password",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextField(
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => password = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your password",
                  border: const OutlineInputBorder(),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              PageButton(
                title: "LOGIN",
                callback: signIn,
              ),

            ], ),
        ),
      ),
    );
  }

  Future<void> signIn() async{
    try {
      FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> new HomePage(user)));
    } catch (e) {
      _showAlertDialog("ERROR",e.message);
    }

  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
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
