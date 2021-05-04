import 'package:WasteLess/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

/**
 * Intialises feedback page under settings
 */
class FeedbackPage extends StatefulWidget {

  final FirebaseUser user;
  FeedbackPage(this.user);

  @override
  FeedbackPageState createState() => new FeedbackPageState(this.user);
}

class FeedbackPageState extends State<FeedbackPage> {
  bool anon = false;
  FirebaseUser user;
  FeedbackPageState(this.user);
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    feedbackController.dispose();
    super.dispose();
  }

  /**
   * scaffold for feedback page.
   */
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
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              print('current focus: ' + currentFocus.toString() );

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Column(

              children: <Widget>[
                SizedBox(
                  height: 15,
                ),

                TextField(
                  autocorrect: false,
                  controller: feedbackController,
                  keyboardType: TextInputType.multiline,
                  minLines: 7,
                  maxLines: 7,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    hintText: "We want to provide the best experience possible! To help us, please take a moment to leave your feedback here. Thank you! ",
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(32, 95, 38, 1),
                        )
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor:  Color.fromRGBO(32, 95, 38, 1),
                    title: Text('Send anonymously'),
                    value: anon,
                    onChanged: (value) {
                      setState(() {
                        anon = !anon;
                        print(anon);
                      });
                    }),

                SizedBox(
                  height: 20,
                ),

                LoginButton(
                  title: "Send Feedback",
                  callback: sendFeedback,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /**
   * async function to send feedback to google docs
   */
  Future<void> sendFeedback() async {
    String feedbackText = feedbackController.text;
    print(feedbackText);
    print(feedbackText == null);

    if (feedbackText == null || feedbackText == '') {
      _showAlertDialog("Error", "Please enter feedback before submitting");
    } else
      try {


        String link = 'https://docs.google.com/forms/d/e/1FAIpQLSdxMh-4_5I_xIgercMPkK4RqT3dfortK1qUSizCyuJmQknx8Q/formResponse';

        final response = await http.post(link,
            headers:{
                  "Content-Type": "application/x-www-form-urlencoded"
                  },
            body: {"entry.1843475341": !anon ? user.uid.toString() : 'Anon',
              'entry.1026244037': feedbackText,
            },

                );
        if (response.statusCode == 200) {
          _showAlertDialog("Success", "Feedback Sent!" );
          feedbackController.clear();


        } else {
          throw Exception('Failed to send feedback');
        }

      } catch (e) {
        _showAlertDialog("Error", e.message);
      }
  }

  /**
   * helper method for alert popup after feedback is sent successfully
   */
  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

}
