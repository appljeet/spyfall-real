import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'homePage.dart';

void main() {
  runApp(
      MaterialApp(
        theme: ThemeData(
            unselectedWidgetColor:Colors.black
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
        initialRoute: '/',
        routes: {
          '/homePage': (context) => homePage(),
        },
      )
  );
}


class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //use to debug fb initialization
  bool _initialized = false;
  bool _error = false;


  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;

      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  bool visible = true;

  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, takeToHome);
  }

  startTime2() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, makeInvisible);
  }

  void makeInvisible(){
    setState(() {
      visible=false;
    });
  }

  void takeToHome(){
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => homePage()));
    // Navigator.of(context).pushReplacementNamed('/homePage');
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    startTime();
    startTime2();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Hero(tag: 'title', child: Image.asset('images/spyicon.png',scale: 3,),),

            AnimatedOpacity(

              opacity: visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),

              child: Text("SPYFALL", style: TextStyle(color: Colors.white,fontSize: 50,decoration: TextDecoration.none, fontWeight: FontWeight.normal),),
            )
          ],
        ),
      ),
    );
  }
}
