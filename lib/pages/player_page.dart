import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/utils.dart';
import 'game_page.dart';

class PlayerListWidget extends StatefulWidget {
  PlayerListWidget({super.key});

  @override
  _PlayerListWidgetState createState() => _PlayerListWidgetState();
}

class _PlayerListWidgetState extends State<PlayerListWidget> {
  final TextEditingController message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
  Map<String, dynamic>? userMap;

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isloading = true;
    });

    await _firestore
        .collection("users")
        .where("email", isEqualTo: message.text)
        .get()
        .then((value) {
      if (value.docs[0].data()["email"] == _auth.currentUser!.email) {
        setState(() {
          isloading = false;
        });
      } else {
        setState(() {
          userMap = value.docs[0].data();
          print(userMap);
          isloading = false;
        });
        print(userMap);
      }
    });
  }

  void challengePlayer(String uid) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    if (userMap!['status'] != "Offline" &&
        userMap!['challengestatus'] == true) {
      _firestore.collection("users").doc(uid).update({
        "challengestatus": false,
      });
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GameRoom(
                roomID: uid,
              )));
    } else {
      Utils.showSnackBar(
          "Player is either offline or the room is not available");
    }
  }

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Player List"),
        ),
        body: isloading
            ? Center(
                child: Container(
                height: 50,
                child: CircularProgressIndicator(),
              ))
            : Column(
                children: [
                  TextField(
                    controller: message,
                    decoration: const InputDecoration(
                      labelText: "Search User",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onSearch(),
                    child: const Text('Search'),
                  ),
                  userMap != null
                      ? ListTile(
                          onTap: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(userMap?['email']),
                              content: Text(userMap?['status']),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      challengePlayer(userMap?['email']),
                                  child: const Text('Join Player Room'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ),
                          title: Text(userMap?['email']),
                          subtitle: Text(userMap?['status']),
                        )
                      : Container(),
                ],
              ),
      );
}
