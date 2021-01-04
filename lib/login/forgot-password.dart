import 'package:flutter/material.dart';
import 'package:LessApp/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ForgotPasswordPage extends StatefulWidget{

  @override
  ForgotPasswordPageState createState() => new ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage>{
  String email, password;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            }),

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




                LoginButton(
                  title: "RESET PASSWORD",
                  callback: resetPassword,
                ),


              ], ),
          )
      ),
    );
  }
  Future<void> resetPassword() async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      await firebaseAuth.sendPasswordResetEmail(email:email);
      Navigator.push(context, MaterialPageRoute(builder: (context)=> new Login()));
      showDialog(
          context: context,
          builder: (_) =>AlertDialog(
            title: Text("Success"),
            content: Text("Reset password email sent."),
          ));
    } catch (e) {

      showDialog(
          context: context,
          builder: (_) =>AlertDialog(
            title: Text("ERROR"),
            content: Text(e.message),
      ));






  }


}
}