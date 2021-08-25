import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'gameScreen.dart';

class joinGame extends StatefulWidget {
  final String lobbyCode;
  joinGame({Key key, @required this.lobbyCode}) : super(key: key);

  @override
  joinGameState createState() => joinGameState();
}



class joinGameState extends State<joinGame>{
  List<String> usernameArray = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/20),
              child: Text(
                "The Lobby",
                style: TextStyle(color: Colors.white, fontSize: 45),
              ),
            ),

            Expanded(
              flex: 10,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection(widget.lobbyCode).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {


                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }


                  //find index of matchmaker
                  var map = snapshot.data.docs.asMap();
                  int index;
                  for(int i=0;i<map.length;i++){
                    if(map[i]['username'].toString()==widget.lobbyCode){
                      index = i;
                      break;
                    }
                  }

                  //read gameStarted of lobbyCode aka matchmaker
                  if(map[index]['gameStarted']=='true'){
                    //move the player onto the actual game screen
                    Navigator.push(context,MaterialPageRoute(builder: (context) => gameScreen(lobbyCode: widget.lobbyCode)));
                  }



                  return new ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return new Container(
                        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10, 0, MediaQuery.of(context).size.width/10, MediaQuery.of(context).size.height/20),
                        width: MediaQuery.of(context).size.width/10,
                        child: new ButtonTheme(
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                          height: 50,
                          child: new RaisedButton(
                            child: Text(data['username'],style: TextStyle(color: Colors.green, fontSize: 25, fontWeight: FontWeight.bold),),
                            color: Colors.white,
                            onPressed:(){}
                          ),


                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            Expanded(
              flex: 2,
              child: Text("Tell the matchmaker to start the game!", style: TextStyle(color: Colors.white, fontSize: 25,),textAlign: TextAlign.center,),
            )
          ],
        )
      )
    );
  }


}