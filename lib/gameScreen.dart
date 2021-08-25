
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spyfall/votingScreen.dart';

class gameScreen extends StatefulWidget {
  final String lobbyCode;
  gameScreen({Key key, @required this.lobbyCode}) : super(key: key);

  @override
  gameScreenState createState() => gameScreenState();
}


class gameScreenState extends State<gameScreen>{
  String rightLocation;
  String role;
  int index = 0;

  List <Color> buttonColors= [Colors.green,Colors.red];

  List <String> buttonText= ['Reveal Role', 'Role'];

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 300;
  final input = new TextEditingController();

  List <String> locations=[];

  @override
  void initState() {
    //update buttonText[1] with role
    getRole();
    getLocations();
    resetVotes();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            CountdownTimer(
              endTime: endTime,
              widgetBuilder: (_, CurrentRemainingTime time) {

                if (time == null) {
                  //navigate to voting screen
                  Future.delayed(Duration.zero, () async {
                    return Navigator.push(context,MaterialPageRoute(builder: (context) => votingScreen(role: role, locations: locations,rightLocation: rightLocation,lobbyCode: widget.lobbyCode,)));
                  });
                }else{
                  //prevents timer from showing null
                  int timeMin=time.min;

                  if(time.min==null){
                    timeMin=0;
                  }
                  return Center(
                    child: Text(
                        ''+ timeMin.toString() + " MINS ${time.sec} SECS",style: TextStyle(color:Colors.white,fontSize: 35,fontWeight: FontWeight.bold)
                    ),
                  );
                }
                return Text('',style: TextStyle(color: Colors.white),);

              },
            ),

            Container(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/20),),


            Center(child: Text('Locations',style: TextStyle(color: Colors.white,fontSize: 30,fontWeight: FontWeight.bold),),),

            Container(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/30),),

            Expanded(
              flex: 8,
              child:ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return new Container(
                    padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10, 0, MediaQuery.of(context).size.width/10, MediaQuery.of(context).size.height/20),
                    width: MediaQuery.of(context).size.width/10,
                    child: new ButtonTheme(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                      height: 50,
                      child: new RaisedButton(
                          child: Text(locations[index],style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),),
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
                    color: buttonColors[index],
                    onPressed: (){
                      //change color and text
                      if(index==1){
                        index=0;
                      }else{
                        index++;
                      }
                      setState(() {

                      });
                    },
                    child: Center(child: Text(buttonText[index],textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color: Colors.white),),),
                ),
              ),
            )


          ],
        ),
      ),
    );
  }



  void getRole() async {

    //get current location
    String currentLocation='lol';
    await FirebaseFirestore.instance
        .collection(widget.lobbyCode)
        .doc(widget.lobbyCode)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          Map map = documentSnapshot.data();
          currentLocation = map['location'];
          rightLocation = currentLocation;
    });

    String username;
    final prefs = await SharedPreferences.getInstance();


    username = prefs.getString('username');

    await FirebaseFirestore.instance
        .collection(widget.lobbyCode)
        .doc(username)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
          Map map = documentSnapshot.data();
          buttonText[1]= map['role'];
          role= map['role'];
          setState(() {
          });
          print(buttonText);
      });

    //give location with role if not spy
    if(buttonText[1]!= 'spy'){
      buttonText[1] = 'Role: ' + buttonText[1] + '\nLocation: ' + currentLocation;
      setState(() {

      });
    }

  }

  void getLocations() async {
    await FirebaseFirestore.instance
        .collection('locations')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        //stick each locationName into array
        locations.add(doc['locationName']);
        setState(() {

        });
      });
    });
  }

  void resetVotes() async {

    await FirebaseFirestore.instance
        .collection(widget.lobbyCode)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {

        //write 0 to votes and set voted to false for everyone
        FirebaseFirestore.instance.collection(widget.lobbyCode).doc(doc['username']).update({
          'votes': 0,
          'voted' : 'false',
        }).catchError((error) => print("Failed to add user: $error"));

      });
    });
  }

}