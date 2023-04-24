import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/pages/src/constants.dart';
import 'src/chess_board.dart';
import 'src/chess_board_controller.dart';

class GameRoom extends StatefulWidget {
  final String roomID;

  GameRoom({required this.roomID});

  @override
  _GameRoomState createState() => _GameRoomState();
}

class _GameRoomState extends State<GameRoom> {
  late ChessBoardController controller;
  late Stream gameMoveStream;
  late double width;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var roomID = "";
  late Map<String, dynamic> playerMoves;
  late bool playerTurn;
  late bool currPlayerTurn;
  late int moveCount;

  @override
  void initState() {
    super.initState();
    controller = ChessBoardController();
    roomID = widget.roomID;
    moveCount = 0;
    if (roomID == _auth.currentUser!.email) {
      playerTurn = false;
      currPlayerTurn = playerTurn;
    } else {
      playerTurn = true;
      currPlayerTurn = playerTurn;
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
              _firestore
                  .collection("users")
                  .doc(_auth.currentUser!.uid)
                  .update({
                "challengestatus": false,
              });
            }),
        title: Text(roomID),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: gameMoveStream = FirebaseFirestore.instance
                .collection("gamemoves")
                .doc(widget.roomID)
                .collection("moves")
                .snapshots(),
            builder: (context, snapshot) {
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("gamemoves")
                      .doc(widget.roomID)
                      .collection("moves")
                      .snapshots(),
                  builder: (context, snapshot) {
                    _firestore
                        .collection("gamemoves")
                        .doc(roomID)
                        .collection("moves")
                        .orderBy("timestamp", descending: true)
                        .limit(1)
                        .get()
                        .then((value) {
                      playerMoves = value.docs[0].data();
                      if (playerTurn == currPlayerTurn) {
                        playerTurn = !playerTurn;
                      } else {
                        currPlayerTurn = playerTurn;
                      }
                      try {
                        if (playerMoves["piecetoPromote"] == "") {
                          controller.makeMove(
                              from: playerMoves["moveFrom"],
                              to: playerMoves["moveTo"]);
                        } else {
                          controller.makeMoveWithPromotion(
                              from: playerMoves["moveFrom"],
                              to: playerMoves["moveTo"],
                              pieceToPromoteTo: playerMoves["piecetoPromote"]);
                        }
                        // if (controller.makeMoveWithPromotion(from: from, to: to, pieceToPromoteTo: pieceToPromoteTo))
                      } catch (e) {
                        print(e);
                      }
                      print(playerTurn);
                    });
                    return ListView(
                      children: <Widget>[
                        _buildChessBoard(),
                      ],
                    );
                  });
            }),
      ),
    );
  }

  Widget _buildChessBoard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ChessBoard(
        size: width,
        boardOrientation: playerSide(),
        enableUserMoves: playerTurn,
        onMove: () {
          // var move = controller.game.san_moves().last;
          var move = controller.getLastMove();
          // var movefrom = controller.getLastMove();
          var movefrom = move.split(" ").first;
          var moveto = move.split(" ").last;
          var piecetoPromote = move.split(" ").elementAt(1);
          onOtherMoved(movefrom, moveto, piecetoPromote);
        },
        controller: controller,
      ),
    );
  }

  PlayerColor playerSide() {
    if (_auth.currentUser!.email == roomID) {
      return PlayerColor.white;
    } else {
      return PlayerColor.black;
    }
  }

  void onOtherMoved(
      String moveFrom, String moveTo, String piecetoPromote) async {
    DateTime time = DateTime.now();
    // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(time);
    // print(formattedDate);
    Map<String, dynamic> moves = {
      "moveFrom": moveFrom,
      "moveTo": moveTo,
      "piecetoPromote": piecetoPromote,
      "playermove": _auth.currentUser!.email,
      "timestamp": time,
    };

    await _firestore
        .collection("gamemoves")
        .doc(roomID)
        .collection("moves")
        .add(moves);
  }
}
