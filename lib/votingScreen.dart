
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loadingScreen.dart';

class votingScreen extends StatefulWidget {
  final String role;
  final List locations;
  final String rightLocation;
  final String lobbyCode;
  votingScreen({Key key, @required this.role, @required this.locations, @required this.rightLocation, @required this.lobbyCode}) : super(key: key);

  @override
  votingScreenState createState() => votingScreenState();
}


class votingScreenState extends State<votingScreen>{
  String username;
  int index = 0;
  int value=-1;

  List <String> playersList=[];

  Color buttonColor = Colors.green;
  String buttonText = 'Vote';

  @override
  void initState() {
    getPlayers();
    getUsername();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if(widget.role=='spy'){
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Center(child:Text('What\'s the Location?',style: TextStyle(color: Colors.white, fontSize: 30),),),

              Container(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/30),),

              Expanded(
                  flex: 8,
                  child:ListView.builder(
                    itemCount: widget.locations.length,
                    itemBuilder: (context, index) {
                      return new Container(
                        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10, 0, MediaQuery.of(context).size.width/10, MediaQuery.of(context).size.height/20),
                        width: MediaQuery.of(context).size.width/10,
                        child: new ButtonTheme(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                          height: 50,
                          child: new FlatButton(
                              child: Row(

                                children: [
                                  Radio(
                                    value: index,
                                    groupValue: value,
                                    activeColor: Colors.red,
                                    onChanged: (val) {
                                      value=val;
                                      print(value);
                                      setState(() {

                                      });
                                    },
                                  ),
                                  Text(widget.locations[index],style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),),

                                ],
                              ),
                              color: Colors.white,
                              onPressed:(){}
                          ),


                        ),
                      );
                    },
                  )
              ),

              Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width,

                  child: FlatButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                      color: buttonColor,
                      onPressed: (){

                        if(value!=-1){
                          //change color and text
                          buttonColor= Colors.grey;
                          buttonText = 'Voted';
                          setState(() {

                          });


                          //check if dude voted right, if so, right spy vote true to matchmaker, else write false
                          if(widget.locations[value]==widget.rightLocation){
                            //write spyVotedRight to fb
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(widget.lobbyCode).update({
                              'spyVotedRight': 'true',
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));

                            //tell fb that this current player voted
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(username).update({
                              'voted': 'true',
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));

                            return Navigator.push(context,MaterialPageRoute(builder: (context) => loadingScreen(lobbyCode: widget.lobbyCode,)));

                          }else{
                            //write spyVotedRight to fb
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(widget.lobbyCode).update({
                              'spyVotedRight': 'false',
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));

                            //tell fb that this current player voted
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(username).update({
                              'voted': 'true',
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));

                            return Navigator.push(context,MaterialPageRoute(builder: (context) => loadingScreen(lobbyCode: widget.lobbyCode,)));

                          }
                        }else{
                          return showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text('Choose a Location'),
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: new Text('OK', style: TextStyle(color: Colors.redAccent),),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }
                          );
                        }

                      },
                      child: Center(child: Text(buttonText,style: TextStyle(fontSize: 25,color: Colors.white),),)
                  ),
                ),
              )

            ],
          )
        ),
      );
    }else{

      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(
              children: [
                Center(child:Text('Who\'s the Spy?',style: TextStyle(color: Colors.white, fontSize: 30),),),

                Container(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/30),),

                Expanded(
                    flex: 8,
                    child:ListView.builder(
                      itemCount: playersList.length,
                      itemBuilder: (context, index) {
                        return new Container(
                          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10, 0, MediaQuery.of(context).size.width/10, MediaQuery.of(context).size.height/20),
                          width: MediaQuery.of(context).size.width/10,
                          child: new ButtonTheme(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                            height: 50,
                            child: new FlatButton(
                                child: Row(

                                  children: [
                                    Radio(
                                      value: index,
                                      groupValue: value,
                                      activeColor: Colors.red,
                                      onChanged: (val) {
                                        value=val;
                                        print(value);
                                        setState(() {

                                        });
                                      },
                                    ),
                                    Text(playersList[index],style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),),

                                  ],
                                ),
                                color: Colors.white,
                                onPressed:(){}
                            ),


                          ),
                        );
                      },
                    )
                ),

                Expanded(
                  flex: 2,
                  child: Container(
                    width: MediaQuery.of(context).size.width,

                    child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                        color: buttonColor,
                        onPressed: (){

                          if(value!=-1){
                            //change color and text
                            buttonColor= Colors.grey;
                            buttonText = 'Voted';
                            setState(() {

                            });
                            //write to fb the vote of this person
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(playersList[value]).update({
                              'votes': FieldValue.increment(1),
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));


                            //tell fb that this current player voted
                            FirebaseFirestore.instance.collection(widget.lobbyCode).doc(username).update({
                              'voted': 'true',
                            }).then((value) => print("Value Updated")).catchError((error) => print(error));

                            //take player to next screen
                            return Navigator.push(context,MaterialPageRoute(builder: (context) => loadingScreen(lobbyCode: widget.lobbyCode,)));
                          }else{
                            return showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    title: Text('Choose a Person'),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text('OK', style: TextStyle(color: Colors.redAccent),),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                }
                            );
                          }
                        },
                        child: Center(child: Text(buttonText,style: TextStyle(fontSize: 25,color: Colors.white),),)
                    ),
                  ),
                )

              ],
            )
        ),
      );




    }

  }


  void getUsername() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username');
    });
  }

  void getPlayers() async {
    await FirebaseFirestore.instance
        .collection(widget.lobbyCode)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        playersList.add(doc['username']);
      });
    });
    setState(() {

    });
  }

}