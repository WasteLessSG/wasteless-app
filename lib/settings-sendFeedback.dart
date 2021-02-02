import 'package:WasteLess/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:WasteLess/wasteless-data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class sendFeedback extends StatefulWidget {

  final FirebaseUser user;
  sendFeedback(this.user);

  @override
  FeedbackState createState() => new FeedbackState(this.user);
}

class FeedbackState extends State<sendFeedback> {

  String newName;
  FirebaseUser user;
  FeedbackState(this.user);
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Feedback",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[900],
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

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),


              TextField(
                autocorrect: false,
                controller: nameController,
                // onChanged: (value) => newName = value,
                //inputFormatters: [ FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")), ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Please enter your feedback here!",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 200.0
                  ),

                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(32, 95, 38, 1),
                      )
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              SizedBox(
                height: 20,
              ),

              //TODO: change this callback to the google forms API
              /*
              LoginButton(
                title: "Confirm feedback submission",
                callback: changeDisplayName,
              ),
              */
            ],
          ),
        ),
      ),
    );
  }

}
