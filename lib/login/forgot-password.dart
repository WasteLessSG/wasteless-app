import 'package:WasteLess/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ForgotPasswordPage extends StatefulWidget {

  @override
  ForgotPasswordPageState createState() => new ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    print(size.height);
    return  Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor:  Color.fromRGBO(0, 81, 40, 1),
          elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                }),

          ),
          backgroundColor: Color.fromRGBO(0, 81, 40, 1),
        body: SingleChildScrollView(
            child: Center(
              child: Column(

                children: <Widget>[
                  SizedBox(
                    height: size.height * 0.1,
                  ),

                  Container(

                    height: size.height * 0.35,
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                        SizedBox(
                          height: size.height * 0.040,
                        ),

                        RichText(text: TextSpan(
                            text: "WasteLess ",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Beta 0.5",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.italic,
                                ),
                              )

                            ]),
                        ),


                        SizedBox(
                          height: size.height * 0.03,
                        ),


                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[200],
                            borderRadius: BorderRadius.circular(29),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => email = value.trim(),
                            cursorColor: Color.fromRGBO(32, 95, 38, 1),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.email,
                                color: Color.fromRGBO(32, 95, 38, 1),
                              ),
                              hintText: 'Enter your email',
                              border: InputBorder.none,
                            ),
                          ),
                        ),


                        LoginButton(
                          title: "RESET PASSWORD",
                          callback: resetPassword,
                        ),


                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height *0.2 ,
                  ),

                  Image.asset('assets/tembusuLogo.png'),


                ],),
            )
        ),
      );
  }

  Future<void> resetPassword() async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => new Login()));
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text("Success"),
                content: Text("Reset password email sent."),
              ));
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text("ERROR"),
                content: Text(e.message),
              ));
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
          // margin: EdgeInsets.symmetric(vertical: 10),
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