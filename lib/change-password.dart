import 'package:WasteLess/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/**
 * Initialises change password page located at settings
 */
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

  bool _obscureOldPassword = true;
  bool _obscureNewPassword1 = true;
  bool _obscureNewPassword2 = true;

  @override
  void initState() {
    _obscureOldPassword = true;
    _obscureNewPassword1 = true;
    _obscureNewPassword2 = true;

    super.initState();
  }

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
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              TextField(
                autocorrect: false,
                obscureText: _obscureOldPassword,
                onChanged: (value) => oldPassword = value,
                decoration: InputDecoration(

                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your old password",
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(32, 95, 38, 1),
                      )
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _obscureOldPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color.fromRGBO(32, 95, 38, 1) ,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autocorrect: false,
                obscureText: _obscureNewPassword1,
                onChanged: (value) => newPassword = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your new password",
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(32, 95, 38, 1),
                      )
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _obscureNewPassword1
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color.fromRGBO(32, 95, 38, 1) ,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _obscureNewPassword1 = !_obscureNewPassword1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                autocorrect: false,
                obscureText: _obscureNewPassword2,
                onChanged: (value) => newPassword2 = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  hintText: "Enter your new password again",
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(32, 95, 38, 1),
                      )
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _obscureNewPassword2
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color.fromRGBO(32, 95, 38, 1) ,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        _obscureNewPassword2 = !_obscureNewPassword2;
                      });
                    },
                  ),
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
