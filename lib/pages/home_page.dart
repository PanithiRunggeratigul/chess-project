import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'player_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_page.dart';
import 'about_us_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  void logout() async {
    await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
      "status": "Offline",
    });
    FirebaseAuth.instance.signOut();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Signed in as",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              user.email!,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              icon: Icon(Icons.account_tree, size: 32),
              label: Text(
                "Create Room",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                String? roomID = _auth.currentUser!.email;
                _firestore
                    .collection("users")
                    .doc(_auth.currentUser!.uid)
                    .update({
                  "challengestatus": true,
                });
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GameRoom(
                          roomID: roomID!,
                        )));
                child:
                const Text('Create Room');
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              icon: Icon(Icons.play_arrow, size: 32),
              label: Text(
                "Play",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlayerListWidget()),
                );
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              icon: Icon(Icons.person, size: 32),
              label: Text(
                "About Us",
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsWidget()),
                );
              },
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                icon: Icon(Icons.arrow_back, size: 32),
                label: Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  logout();
                })
          ],
        ),
      ),
    );
  }
}
