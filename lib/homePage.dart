import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'createGame.dart';
import 'joinGame.dart';

class homePage extends StatefulWidget {

  @override
  homePageState createState() => homePageState();
}


class homePageState extends State<homePage>{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username='no u';

  @override
  void initState() {
    //check if username has been created, if not, show prompt
    checkFirstTime();
    //get username
    readUsername();
    super.initState();
  }

  final joinGameCode = new TextEditingController();
  final usernameInput = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Hero(tag: 'title', child: Image.asset('images/spyicon.png',scale: 3,),),),

            Container(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/6, 0, 0),
            ),

            Container(
              width: MediaQuery.of(context).size.width*.6,
              height: MediaQuery.of(context).size.height*.06,
              child: FlatButton(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                color: Colors.pink,
                onPressed: (){
                  //create collection in firebase

                  firestore.collection(username).doc(username).set({
                    'username': username,
                    'gameStarted': 'false',
                    'voted': 'false',
                    'votes': 0,
                    'stillIn': 'true',
                  }).then((value) => print("User Added")).catchError((error) => print("Failed to add user: $error"));

                  Navigator.push(context,MaterialPageRoute(builder: (context) => createGame()));
                  },
                child: Text('Create Game',style: TextStyle(fontSize: 25,color: Colors.white),)
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/15, 0, 0),
            ),

            Container(
              width: MediaQuery.of(context).size.width*.6,
              height: MediaQuery.of(context).size.height*.06,
              child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                  color: Colors.blue,
                  onPressed: (){
                    //show alert that allows user to enter code
                    return showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            title: Text('Enter Game ID'),
                            content: TextField(
                              controller: joinGameCode,
                              decoration: InputDecoration(hintText: "Game ID"),
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text('CANCEL', style: TextStyle(color: Colors.redAccent),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: new Text('JOIN', style: TextStyle(color: Colors.blue)),
                                onPressed: (){

                                  //Write to firebase and move to next screen

                                  firestore.collection(joinGameCode.text).doc(username).set({
                                    'username': username,
                                    'voted': 'false',
                                    'votes': 0,
                                    'stillIn': 'true',
                                  }).then((value) => print("User Added")).catchError((error) => print("Failed to add user: $error"));

                                  Navigator.push(context,MaterialPageRoute(builder: (context) => joinGame(lobbyCode: joinGameCode.text,)));

                                },
                              )
                            ],
                          );
                        }
                    );
                  },
                  child: Text('Join Game',style: TextStyle(fontSize: 25,color: Colors.white),)
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/15, 0, 0),
            ),

            Container(
              width: MediaQuery.of(context).size.width*.6,
              height: MediaQuery.of(context).size.height*.06,
              child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                  color: Colors.green,
                  onPressed: (){},
                  child: Text('How To Play',style: TextStyle(fontSize: 25,color: Colors.white),)
              ),
            ),


          ],
        ),

      )
    );
  }

  void checkFirstTime() async{
    final prefs = await SharedPreferences.getInstance();

    String username = prefs.getString('username') ?? 'tt30ancq8b';

    //if first time
    if(username=='tt30ancq8b'){
      //show alert
      return showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text('Choose a Username'),
              content: TextField(
                controller: usernameInput,
                decoration: InputDecoration(hintText: "Username"),
              ),
              actions: <Widget>[

                FlatButton(
                  child: new Text('SUBMIT', style: TextStyle(color: Colors.blue)),
                  onPressed: (){
                    //write to storage
                    prefs.setString('username', usernameInput.text);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
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

