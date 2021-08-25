import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spyfall/results.dart';

class loadingScreen extends StatefulWidget {
  final String lobbyCode;

  const loadingScreen({Key key, @required this.lobbyCode}) : super(key: key);

  @override
  loadingScreenState createState() => loadingScreenState();
}


class loadingScreenState extends State<loadingScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(widget.lobbyCode).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {


          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }


          int index;
          int mostVotes=0;
          int indexOfMostVoted;
          int spyIndex;
          //check if everyone's voted
          int numberVoted=0;
          var map = snapshot.data.docs.asMap();
          for(int i=0; i<map.length;i++){
            if(map[i]['voted']=='true'){
              numberVoted++;
            }

            if(map[i]['username']==widget.lobbyCode){
              index=i;
            }

            if(map[i]['role']=='spy'){
              spyIndex=i;
            }


            if(map[i]['votes']>mostVotes){
              mostVotes = map[i]['votes'];
              indexOfMostVoted = i;
            }
          }

          //if everyone voted
          if(numberVoted==map.length){
            //evaluate who won, if anyone, and move onto next screen

            //check if spy won, else check if people voted right, else just eliminate the guy with the most votes and restart game
            if(map[index]['spyVotedRight']=='true'){

              WidgetsBinding.instance.addPostFrameCallback((_){
                Navigator.push(context,MaterialPageRoute(builder: (context) => results(lobbyCode: widget.lobbyCode, whoWon: 'spy', mostVotes: map[indexOfMostVoted]['username'], spyName: map[spyIndex]['username'],)));
              });
              //TODO:show Spy Won screen
              //check if people voted the spy
            }else if(map[indexOfMostVoted]['role']=='spy'){
              //TODO: show The People Won
              WidgetsBinding.instance.addPostFrameCallback((_){
                Navigator.push(context,MaterialPageRoute(builder: (context) => results(lobbyCode: widget.lobbyCode, whoWon: 'people', mostVotes: map[indexOfMostVoted]['username'],spyName: map[spyIndex]['username'])));
              });
            }else{
              print(map[indexOfMostVoted]['username'] + ' got voted out');

              //set the guys stillIn to false
              FirebaseFirestore.instance.collection(widget.lobbyCode).doc(map[indexOfMostVoted]['username']).update({
                'stillIn': 'false',
              }).catchError((error) => print("Failed to add user: $error"));

              //TODO: show who got voted out and restart the game
              WidgetsBinding.instance.addPostFrameCallback((_){
                Navigator.push(context,MaterialPageRoute(builder: (context) => results(lobbyCode: widget.lobbyCode, whoWon: 'noOne', mostVotes: map[indexOfMostVoted]['username'],spyName: map[spyIndex]['username'])));
              });
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //loading symbol and text
              Center(
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),),
              ),

              Container(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.width/10),),

              Text('Waiting for everyone to Vote',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
            ],
          );

        }
        ),
      ),
    );
  }

}

