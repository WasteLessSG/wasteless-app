import 'package:WasteLess/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:WasteLess/wasteless-data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ChangeName extends StatefulWidget {

  final FirebaseUser user;
  ChangeName(this.user);

  @override
  ChangeNameState createState() => new ChangeNameState(this.user);
}

class ChangeNameState extends State<ChangeName> {

  String newName;
  FirebaseUser user;
  ChangeNameState(this.user);
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
        title: Text("Change Display Name",
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
                  hintText: "Enter a new display name",
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



              LoginButton(
                title: "Confirm Name Change",
                callback: changeDisplayName,
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeDisplayName() async {
   newName = nameController.text;


    if (newName == null) {
      _showAlertDialog("Error", "Please enter a new name");
    } else
      try {

        String link = "https://yt7s7vt6bi.execute-api.ap-southeast-1.amazonaws.com/dev/user/${user.uid.toString()}?username=${newName}";


        final response = await http.put(link, headers: {"x-api-key": WasteLessData.userKey});
        if (response.statusCode == 200) {
          _showAlertDialog("Name Changed Successfully!", "Display name is now " + newName);
          nameController.clear();
        } else {
          throw Exception('Failed to load data');
        }

      } catch (e) {
       _showAlertDialog("Error", e.message);
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
