import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Sentimental.dart';



// A screen that allows users to take a picture using a given camera.
class Preliminary extends StatefulWidget {

  @override
  PreliminaryState createState() => PreliminaryState();
}

class PreliminaryState extends State<Preliminary> {
  String predictURL = "http://replica-alpha.herokuapp.com/predict";
  Future<void> _initializeControllerFuture;
  int _radioMCQ = 0;
  var result = new List(6);
  var count = 0;
  final databaseReference = Firestore.instance;
  var list = [];
  var sumResult = 0.0;
  bool ready = false;
  bool primaryAnalysis = false;
  var data;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.


   _getList();
    loadSharedPref();
  }

  Future<void> loadSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    primaryAnalysis = prefs.getBool('primaryAnalysis') ?? false;
  }


  Future<void> _getList() async {
    count = 0;
    await databaseReference
        .collection('questions').limit(6)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        list.add(f.data['quest']);
        count++;
      });
    });
    setState(() {
      ready = true;
    });
  }


  void _handleRadioValueChange1(int value) async{
    setState(() {
      _radioMCQ = value;
    });
    result[_index] = value;



  }

  int _index = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preliminary')),
      backgroundColor: Colors.lightBlue,
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: Container(
        color: Colors.white,
        child: ready ?  Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height, // card height
                    child: PageView.builder(
                      itemCount: 6,
                      controller: PageController(viewportFraction: 1),
                      onPageChanged: (int index) =>
                          setState(() {
                            _index = index;
                            _radioMCQ = -1;
                            if (result[_index] != 0) {
                              setState(() {
                                _radioMCQ = result[_index];
                              });
                            }
                          }),
                      itemBuilder: (_, i) {
                        return Transform.scale(
                          scale: i == _index ? 1 : 0.9,
                          child: Card(
                            color: Colors.blue[100],
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 12.0),
                                      child: Text('${list[i]}', style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Divider(thickness: 1,color: Colors.white,),
                                    GestureDetector(
                                      onTap:() => _handleRadioValueChange1(1),
                                      child: Row(
                                        children: <Widget>[
                                          new Radio(
                                            value: 1,
                                            groupValue: _radioMCQ,
                                            onChanged: _handleRadioValueChange1,
                                          ),
                                          new Text(
                                            'Strongly Agree',
                                            style: new TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () => _handleRadioValueChange1(2),
                                      child: Row(
                                        children: <Widget>[
                                          new Radio(
                                            value: 2,
                                            groupValue: _radioMCQ,
                                            onChanged: _handleRadioValueChange1,
                                          ),
                                          new Text(
                                            'Agree',
                                            style: new TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _handleRadioValueChange1(4),
                                      child: Row(
                                        children: <Widget>[
                                          new Radio(
                                            value: 4,
                                            groupValue: _radioMCQ,
                                            onChanged: _handleRadioValueChange1,
                                          ),
                                          new Text(
                                            'Undecided',
                                            style: new TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _handleRadioValueChange1(7),
                                      child: Row(
                                        children: <Widget>[
                                          new Radio(
                                            value: 7,
                                            groupValue: _radioMCQ,
                                            onChanged: _handleRadioValueChange1,
                                          ),
                                          new Text(
                                            'Disagree',
                                            style: new TextStyle(fontSize: 16.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    if (i == 5) Center(
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                      ),
                                        color: Colors.white,
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Next',style: TextStyle(color: Colors.blue[900],fontSize: 20.0),),
                                        onPressed: () async {

                                          for (int i = 0; i < 6; i++) {
                                            sumResult += result[i];
                                          }
                                          sumResult /= 42.0;
                                          print('akchy');
                                          //http.Response response = await http.get(predictURL);
                                          //data = response.body;
                                          //print('xperion $data');
                                          //var decodedData = jsonDecode(data);
                                          //print( '${decodedData['Query']} mxyzptlk');

                                          bool primeAnalysis = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Sentimental(
                                                    previousSum: sumResult,
                                                  ),
                                            ),
                                          ) ?? false;

                                          if (primeAnalysis == true) {
                                            Navigator.pop(context, true);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ) :
              Container(
                color: Colors.blue[100],
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 25),
                      child: Text("Loading",style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.0
                      ),),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
