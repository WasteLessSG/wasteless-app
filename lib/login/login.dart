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
  bool _obscureText = true;

  @override
  void initState() {
    _obscureText = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        body: SingleChildScrollView(
            child: Center(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: size.height *0.17 ,
                  ),

                Text("WasteLess",
              textAlign: TextAlign.center,
              style: TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          SizedBox(
            height: size.height *0.03 ,
          ),



          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.lightGreen[200],
              borderRadius: BorderRadius.circular(29),
            ),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value.trim(),
              cursorColor: Color.fromRGBO(32, 95, 38, 1) ,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.email,
                  color: Color.fromRGBO(32, 95, 38, 1) ,
                ),
                hintText: 'Enter your email',
                border: InputBorder.none,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.lightGreen[200],
              borderRadius: BorderRadius.circular(29),
            ),

            child: TextField(
              autocorrect: false,
              obscureText: _obscureText,
              onChanged: (value) => password = value,
              cursorColor: Color.fromRGBO(32, 95, 38, 1) ,
              decoration: InputDecoration(
                icon: Icon(Icons.lock, color: Color.fromRGBO(32, 95, 38, 1),),
                hintText: "Enter your password",
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    _obscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Color.fromRGBO(32, 95, 38, 1) ,
                  ),
                  onPressed: () {
                    // Update the state i.e. toogle the state of passwordVisible variable
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              ),
            ),


          LoginButton(
            title: "LOGIN",
            callback: signIn,
          ),


                ], ),
            )
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

class LoginButton extends StatelessWidget {
  final String title;
  final VoidCallback callback;

  const LoginButton({Key key, this.title, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Container(
      margin: EdgeInsets.symmetric(vertical: 10),
    width: size.width * 0.8,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(29),
    child: FlatButton(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    color: Color.fromRGBO(32, 95, 38, 1) ,
    onPressed: callback,
    child: Text(
    title,
    style: TextStyle(color: Colors.lightGreen),
    ),
    ),
    ),
    ));
  }
}
