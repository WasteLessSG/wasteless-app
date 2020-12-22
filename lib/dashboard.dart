import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:csv_reader/csv_reader.dart';
import 'package:LessApp/styles.dart';
import 'dart:math';

class DashboardPage extends StatefulWidget{
  @override
  DashboardPageState createState() => new DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  String selectedState = "rubbishOverflow";
  double sizeRelativeVisual = 1.0;

  // Uncomment below after tip URL is settled
  /*
  var tipsCSV = CSV.from(url :'URL_TO_FILE_OR_RAW_TEXT', delimiter: ",", title:true );
  final _random = new Random();
  int tipNumber() => 41 + _random.nextInt(62 - 41);
  */

  // For determining container sizes

  GlobalKey _keyVisual = GlobalKey();

  _getVisualSize() {
    final RenderBox visual = _keyVisual.currentContext.findRenderObject();
    final sizeVisual = visual.size.width;
    double width = MediaQuery.of(context).size.width;
    sizeRelativeVisual = sizeVisual/width;
  }

  // Initialise PageControllers

  int _previousPage = 0;
  bool _isController1 = false;
  bool _isController2 = false;

  PageController _controller1;
  PageController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = PageController(
      initialPage: 0,
      viewportFraction: 1
    )
    ..addListener(_onController1Scroll)
    ;
    _controller2 = PageController(
      initialPage: 0,
      viewportFraction: 1
    )
    ..addListener(_onController2Scroll)
    ;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getVisualSize());
  }

  void resetMoveInfo(){
    _isController1 = false;
    _isController2 = false;
  }

  // Link PageControllers

  void _onController1Scroll() {
    if (_isController2)
      return;

    _isController1 = true;
    if (_controller1.page.toInt() == _controller1.page) {
      _previousPage = _controller1.page.toInt();
      resetMoveInfo();
    }

    _controller2.position
    // ignore: deprecated_member_use
        .jumpToWithoutSettling(_controller1.position.pixels * sizeRelativeVisual);
  }

  void _onController2Scroll() {
    if (_isController1)
      return;

    _isController2 = true;
    if (_controller2.page.toInt() == _controller2.page) {
      _previousPage = _controller2.page.toInt();
      resetMoveInfo();
    }

    _controller1.position
    // ignore: deprecated_member_use
        .jumpToWithoutSettling(_controller2.position.pixels / sizeRelativeVisual);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  // End of PageController initialisation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          //tipLightBulb(context),
        ]
      ),

      // BODY OF THE APP

      body: Center(
        child: Column(
            children: <Widget>[

              // The first expanded is for SUMMARY STATISTICS

              Expanded(
                  child: PageView(
                    controller: _controller1,
                    children: [
                      Column(
                          children: <Widget>[
                            // This first expanded contains USER WEEKLY TOTAL
                            Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("Your waste this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      Expanded(
                                          child: Text("0.67kg",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                      )
                                    ]
                                )
                            ),
                            // This second expanded contains TEMBUSU WEEKLY TOTAL AVERAGE
                            Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Expanded(
                                          child: Text("Tembusu average this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      Expanded(
                                          child: Text("0.51kg",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                      )
                                    ]
                                )
                            )
                          ]
                      ),
                      Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),

                            // This first expanded contains USER WEEKLY TOTAL
                            Expanded(
                                child: Column(
                                    children: <Widget>[

                                      Expanded(
                                          child: Text("Your recyclables this week:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                      ),
                                      Expanded(
                                          child: Text("0.41kg",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                      )
                                    ]
                                )
                            ),
                            // This second expanded contains TEMBUSU WEEKLY TOTAL AVERAGE
                            Expanded(
                                child: Column(
                                    children: <Widget>[

                                      Expanded(
                                          child: Text("Tembusu average this week:",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.center)
                                      ),
                                      Expanded(
                                          child: Text("0.20kg",
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center)
                                      )
                                    ]
                                )
                            ),
                          ]
                      ),
                    ],
                  )

              ),

              // The second expanded is for the CHANGING VISUAL

              Expanded(
                  child: Container(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipOval(
                          child: PageView(
                            controller: _controller2,
                            children: [
                              trashBin(context, selectedState),
                              Image.asset('assets/recyclingIsland.png'),
                            ],
                            key: _keyVisual,
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Color(0xffCBC76C),
                            width: 5
                        ),
                        color: Color(0xffE4E5A3),
                      )
                  )
              ),

              // The third expanded is for the LIGHT BULB TIP

              Expanded(
                  child: Column(
                      children: <Widget>[
                        // This container is for the dots
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: selectionDots(context, selectedState)
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        Text("Daily Tip: \nAn apple a day keeps the doctor away",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),

                      ]
                  )
              ),
              // End of content

            ]
        ),
      ),

      // End of appBody

    );
  }

  // Beginning of dynamic widgets



  // trashBin

  Widget trashBin(BuildContext context, selectedState) {
    if (this.selectedState == "rubbishEmpty") {
      return Image.asset('assets/rubbishEmptyIsland.png');
    } else if (this.selectedState == 'rubbishFilled') {
      return Image.asset('assets/rubbishFilledIsland.png');
    } else if (this.selectedState == 'rubbishOverflow') {
      return Image.asset('assets/rubbishOverflowIsland.png');
    }
  }
  // End of trashBin



  // selectionDots

  Widget selectionDots(BuildContext context, selectedState) {
    return SmoothPageIndicator(
        controller: _controller2,  // PageController
        count:  2,
        effect:  WormEffect(),  // your preferred effect
        onDotClicked: (index){

        }
    );
  }

  // End of selectionDots



  // tipLightBulb

  Widget tipLightBulb(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.lightbulb_outline, color: Colors.black),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              elevation: 16,
              child: Container(
                height: 400.0,
                width: 360.0,
                child: Center(
                  child:
                    Text("Daily Tip: \nAn apple a day keeps the doctor away", textAlign: TextAlign.center)
                  // Uncomment below once the CSV URL is settled
                  // Text(tipsCSV[tipNumber()][2].toString(), textAlign: TextAlign.center)
                )
              ),
            );
          },
        );
      },
    );
  }

  // End of tipLightBulb

  // End of dynamic widgets

}
