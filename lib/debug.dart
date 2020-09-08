import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class DebugPage extends StatefulWidget {
  @override
  DebugPageState createState() => new DebugPageState();
}

class DebugPageState extends State<DebugPage> {
  String massValue,houseValue;
  TextEditingController massController = TextEditingController();
  static var houseNames = [
    "House_A",
    "House_B",
    "House_C",
  ];


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text("Add New Mass Entry",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,),),
          centerTitle:true,
    ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
                children: <Widget>[

                  Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(10,0,10,0),
                        child: Text("Note: This page will not be in actual deployed app.",
                          style: TextStyle(
                            color: Colors.red,
                          ),),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10,0,10,0),
                      child: DropdownButton(
                          items: houseNames.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem,
                                style: TextStyle(
                                  fontSize: 20,
                                ),),
                            );
                          }).toList(),
                          hint: Text("Select Household"),
                          value: houseValue,
                          onChanged: (newValue) {
                            setState(() {
                              debugPrint('Selected $newValue');
                              houseValue = newValue;
                            });
                          }
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: massController,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        debugPrint('Something changed in Mass Text Field');
                      },
                      decoration: InputDecoration(
                          labelText: 'Insert Weight',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(10,0,10,0),
                    child: RaisedButton(
                      color: Colors.black,
                      textColor: Colors.white,
                      child: Text(
                        'Submit',
                        textScaleFactor: 1.5,
                        style: TextStyle( fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          debugPrint("Send button clicked");
                          submit();
                        });
                      },
                    ),
                  )


                ],
        )));
  }

  void submit() async{

      final DocumentReference currentAllTime = Firestore.instance
          .collection("houses")
          .document(houseValue);

      currentAllTime.get().then( (data) {
        double allTime = data['alltime'].toDouble();
        finalSubmission(allTime);




      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error Status AllTime', 'Problem Saving Question ');
      } );


  }
  void finalSubmission(double allTimeMass ) async{




    if (massController.text.isNotEmpty && houseValue != null && isFloat(massController.text)){
      Firestore.instance.collection("houses")
          .document(houseValue)
          .collection("RawData")
          .document(DateTime.now().toIso8601String().toString())
          .setData({
        'mass': massController.text,
        'timestamp2': DateFormat('d MMM y').format(DateTime.now()).toString(),
        'timestamp' :DateTime.now().toIso8601String().toString(),
      }).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error', 'Problem saving data to raw database');
      } );
      //update all time counter
      Firestore.instance.collection("houses")
          .document(houseValue)
          .setData({
        'alltime': allTimeMass + double.parse(massController.text),
      }).then((response) {
        print("updated all time counter");

      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error', 'Problem Saving Data to all time leaderboard');
      } );



      _showAlertDialog(
          'Success!', 'Succesfully Sent Data to Database');
    } else { // Failure
      _showAlertDialog(
          'Error Status', 'Problem Sending Data, Make Sure all fields are filled correctly');
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
    );}



}

