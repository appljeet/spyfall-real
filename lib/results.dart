import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

import 'gameScreen.dart';
import 'homePage.dart';

class results extends StatefulWidget {
  final String lobbyCode;

  //possible choices are spy, people, or noOne
  final String whoWon;

  final String mostVotes;

  final String spyName;

  const results({Key key, @required this.lobbyCode, @required this.whoWon, @required this.mostVotes, @required this.spyName}) : super(key: key);

  @override
  resultsState createState() => resultsState();
}


class resultsState extends State<results> with SingleTickerProviderStateMixin{

  String username;

  var colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Horizon',
  );

  String susOrNot = 'not sus';

  @override
  void initState() {
    super.initState();

    //delete the most voted guys doc
    FirebaseFirestore.instance.collection(widget.lobbyCode).doc(widget.mostVotes)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));


    //check if dude with the most votes is spy
    if(widget.spyName==widget.mostVotes){
      susOrNot= 'sus';
    }

    readUsername();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.whoWon=='noOne'){
      return Scaffold(
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xb2da2525),
                    Color(0xff215bf3),
                  ],
                  stops: [
                    0,
                    1,
                  ],
                ),
                backgroundBlendMode: BlendMode.srcOver,
              ),
              child: PlasmaRenderer(
                type: PlasmaType.infinity,
                particles: 10,
                color: Color(0x44e45a23),
                blur: 0.1,
                size: 1,
                speed: 1,
                offset: 0,
                blendMode: BlendMode.plus,
                variation1: 0,
                variation2: 0,
                variation3: 0,
                rotation: -0.0,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(widget.mostVotes + ' has the most votes',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.mostVotes + ' was',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      ColorizeAnimatedText(
                        susOrNot,
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      TypewriterAnimatedText( widget.mostVotes + ' is out 😔',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100),textAlign: TextAlign.center),
                    ],
                    isRepeatingAnimation: false,
                    onFinished: (){

                      //show the guy with most votes a voted out alert
                      if(widget.mostVotes==username){
                        return showDialog(
                            context: context,
                            builder: (context){
                              return AlertDialog(
                                title: Text('You\'ve Been Voted Out'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: new Text('LEAVE', style: TextStyle(color: Colors.redAccent)),
                                    onPressed: (){

                                      Navigator.push(context,MaterialPageRoute(builder: (context) => homePage()));

                                    },
                                  )
                                ],
                              );
                            }
                        );
                      }

                      //restart game for everyone else
                      return Navigator.push(context,MaterialPageRoute(builder: (context) => gameScreen(lobbyCode: widget.lobbyCode)));
                    },

                  ),
                )

              ],
            ),
          ],
        ),
      );
    }else if(widget.mostVotes == widget.spyName && widget.whoWon=='spy'){
      //if spy was chosen and he won

      return Scaffold(
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xb2da2525),
                    Color(0xff215bf3),
                  ],
                  stops: [
                    0,
                    1,
                  ],
                ),
                backgroundBlendMode: BlendMode.srcOver,
              ),
              child: PlasmaRenderer(
                type: PlasmaType.infinity,
                particles: 10,
                color: Color(0x44e45a23),
                blur: 0.1,
                size: 1,
                speed: 1,
                offset: 0,
                blendMode: BlendMode.plus,
                variation1: 0,
                variation2: 0,
                variation3: 0,
                rotation: -0.0,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(widget.mostVotes + ' has the most votes',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.mostVotes + ' was',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      ColorizeAnimatedText(
                        susOrNot,
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      TypewriterAnimatedText( 'but...',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.mostVotes + ' voted right',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),

                      TypewriterAnimatedText( 'So the SPY wins',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                    ],
                    isRepeatingAnimation: false,
                    onFinished: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => homePage()));
                    },
                  ),
                )

              ],
            ),
          ],
        ),
      );
    }else if(widget.whoWon=='spy'){


      //if spy was not chosen and he won

      return Scaffold(
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xb2da2525),
                    Color(0xff215bf3),
                  ],
                  stops: [
                    0,
                    1,
                  ],
                ),
                backgroundBlendMode: BlendMode.srcOver,
              ),
              child: PlasmaRenderer(
                type: PlasmaType.infinity,
                particles: 10,
                color: Color(0x44e45a23),
                blur: 0.1,
                size: 1,
                speed: 1,
                offset: 0,
                blendMode: BlendMode.plus,
                variation1: 0,
                variation2: 0,
                variation3: 0,
                rotation: -0.0,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(widget.mostVotes + ' has the most votes',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.mostVotes + ' was',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      ColorizeAnimatedText(
                        susOrNot,
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      TypewriterAnimatedText( widget.mostVotes + ' is out 😔',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100),textAlign: TextAlign.center),
                      TypewriterAnimatedText( 'but...',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.spyName + ' was the spy',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( 'and he voted right',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( 'So the SPY wins',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                    ],
                    isRepeatingAnimation: false,
                    onFinished: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => homePage()));
                    },
                  ),
                )

              ],
            ),
          ],
        ),
      );

    }else {


      //people chose right and spy chose wrong

      return Scaffold(
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xb2da2525),
                    Color(0xff215bf3),
                  ],
                  stops: [
                    0,
                    1,
                  ],
                ),
                backgroundBlendMode: BlendMode.srcOver,
              ),
              child: PlasmaRenderer(
                type: PlasmaType.infinity,
                particles: 10,
                color: Color(0x44e45a23),
                blur: 0.1,
                size: 1,
                speed: 1,
                offset: 0,
                blendMode: BlendMode.plus,
                variation1: 0,
                variation2: 0,
                variation3: 0,
                rotation: -0.0,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(widget.mostVotes + ' has the most votes',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      TypewriterAnimatedText( widget.mostVotes + ' was',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                      ColorizeAnimatedText(
                        susOrNot,
                        textStyle: colorizeTextStyle,
                        colors: colorizeColors,
                      ),
                      TypewriterAnimatedText( 'The People Win',textStyle: TextStyle(fontSize: 30,color: Colors.white),speed: const Duration(milliseconds: 100)),
                    ],
                    isRepeatingAnimation: false,
                    onFinished: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => homePage()));
                    },
                  ),
                )

              ],
            ),
          ],
        ),
      );

    }
  }



  void readUsername() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username');
    });
  }


}