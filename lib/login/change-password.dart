import 'package:LessApp/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {

  final FirebaseUser user;
  ChangePassword(this.user);


  @override
  ChangePasswordState createState() => new ChangePasswordState(this.user);
}

class ChangePasswordState extends State<ChangePassword> {

  String oldPassword, newPassword, newPassword2;
  FirebaseUser user;
  ChangePasswordState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Change Password",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              TextField(
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => oldPassword = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your old password",
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => newPassword = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your new password",
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => newPassword2 = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your new password again",
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              LoginButton(
                title: "Confirm",
                callback: changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changePassword() async {



    if (oldPassword == null) {
      _showAlertDialog("Error", "Please enter your old password");
    } else if (oldPassword != null && newPassword == null) {
      _showAlertDialog("Error", "Please enter your new password");
    }  else if (newPassword.length < 6 || newPassword == null) {
      _showAlertDialog(
          "Error", "Your password needs to be longer than 6 characters");
    }  else if (newPassword == oldPassword) {
      _showAlertDialog(
          "Error", "Your new password is the same as the old password");
    } else if (newPassword != newPassword2) {
      _showAlertDialog(
          "Error", "Your passwords do not match");
    } else
      try {
        FirebaseUser _user = await FirebaseAuth.instance.currentUser();
         AuthResult authResult = await _user.reauthenticateWithCredential(
            EmailAuthProvider.getCredential(
            email: user.email,
            password: oldPassword,
            ));

        authResult.user.updatePassword(newPassword).then((_){
          print("Successfully changed password");
        }).catchError((error){
          print("Password can't be changed" + error.toString());
          _showAlertDialog(
              'Error', 'Problem Initializing User');
        });

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (context) =>
                new Login()),
                (route) => false);
        _showAlertDialog("Status", "Password Changed Successfully");
      } catch (e) {
      if(e.message == 'The password is invalid or the user does not have a password.'){
        _showAlertDialog("Error", 'Your old password is incorrect.');
      } else _showAlertDialog("Error", e.message);
      }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

}
