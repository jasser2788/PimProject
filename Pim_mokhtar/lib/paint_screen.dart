import 'dart:async';

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({required this.data, required this.screenFrom});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];



  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;

  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data['nickname']);
  }



  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('-', style: TextStyle(fontSize: 30)));
    }
  }

  // Socket io client connection
  void connect() {
    _socket = IO.io('http://192.168.1.102:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    // listen to socket
    _socket.onConnect((data) {
      print('connected!');
      _socket.on('updateRoom', (roomData) {
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {

        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],

            });
          });
        }
      });

      _socket.on(
          'notCorrectGame',
          (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false));



      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);

        });

        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextInputReadOnly = false;
                });
                Navigator.of(context).pop();

              });
              return AlertDialog(
                  title: Center(child: Text('Word was $oldWord')));
            });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });





      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],

            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _socket.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {




    return Scaffold(
      key: scaffoldKey,

      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true

                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [



                                 Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: textBlankWidget,
                                  ),
                                 Center(
                                    child: Text(dataOfRoom['word'],
                                        style: TextStyle(fontSize: 30))),
                            // Displaying messages
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      var msg = messages[index].values;
                                      print(msg);
                                      return ListTile(
                                        title: Text(
                                          msg.elementAt(0),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          msg.elementAt(1),
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                      );
                                    })),
                          ],
                        ),

                             Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: TextField(
                                      readOnly: isTextInputReadOnly,
                                      controller: controller,
                                      onSubmitted: (value) {
                                        print(value.trim());
                                        if (value.trim().isNotEmpty) {
                                          Map map = {
                                            'username': widget.data['nickname'],
                                            'msg': value.trim(),
                                            'word': dataOfRoom['word'],
                                            'roomName': widget.data['name'],


                                          };
                                          _socket.emit('msg', map);
                                          controller.clear();
                                        }
                                      },
                                      autocorrect: false,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 14),
                                        filled: true,
                                        fillColor: const Color(0xffF5F5FA),
                                        hintText: 'Your Guess',
                                        hintStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      textInputAction: TextInputAction.done,
                                    )),
                              )


                      ],
                    )

              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,

        ),
      ),
    );
  }
}
