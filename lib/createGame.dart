
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gameScreen.dart';

class createGame extends StatefulWidget {

  @override
  createGameState createState() => createGameState();
}


class createGameState extends State<createGame>{
  String username='no u';
  String location;

  @override
  void initState() {
    // read username
    readUsername();
    chooseLocation();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height/20),
              child: Text(
                "Code: "+ username,
                style: TextStyle(color: Colors.white, fontSize: 45),
              ),
            ),

            Expanded(
              flex: 10,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection(username).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {


                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
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
              child: Container(
                width: MediaQuery.of(context).size.width,

                child: FlatButton(
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                    color: Colors.green,
                    onPressed: (){

                      FirebaseFirestore.instance
                          .collection('locations')
                          .doc(location)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                            if (documentSnapshot.exists) {

                              Map map = documentSnapshot.data();
                              //put map in list
                              List roles = map['roles'];
                              roles.shuffle();

                              print(roles);

                              assignRoles(roles);
                              //give roles to everyone


                              //write gameStarted to fb
                              FirebaseFirestore.instance.collection(username).doc(username).update({
                                'gameStarted': 'true',
                                'location' : location,
                              }).catchError((error) => print("Failed to add user: $error"));

                              //take player to game screen

                              Navigator.push(context,MaterialPageRoute(builder: (context) => gameScreen(lobbyCode: username)));
                            } else {
                              print('Document does not exist on the database');
                            }
                      });

                    },
                    child: Text('Start',style: TextStyle(fontSize: 25,color: Colors.white),)
                ),
              ),
            )

          ],
        ),
      )
    );
  }

  void readUsername() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString('username');
    });
  }

  void chooseLocation() async{
    List<String> locationList = [];

    await FirebaseFirestore.instance
        .collection('locations')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        locationList.add(doc['locationName'].toString());
      });
    });

    locationList.shuffle();
    location=locationList.last;
  }

  void assignRoles(List roles) async{

    int index = 0;
    int players = 0;

    //get number of players
    await FirebaseFirestore.instance
        .collection(username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        players++;
      });
    });

    //trim roles array if applicable and assign one index as spy
    while(roles.length!=players-1){
     roles.removeLast();
    }
    roles.add('spy');

    //shuffle roles so that the last guys isn't always the spy
    roles.shuffle();

    await FirebaseFirestore.instance
        .collection(username)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        //update roles for each user

        FirebaseFirestore.instance.collection(username).doc(doc['username']).update({
          'role': roles[index],
        }).catchError((error) => print("Failed to update role: $error"));

        index++;
      });
    });
  }

}