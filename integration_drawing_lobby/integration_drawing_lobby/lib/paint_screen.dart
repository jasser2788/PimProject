import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({this.data, this.screenFrom});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  // instantiation
  DrawingPainter drawingPainter;

  List<DrawingPoint> drawingPoints = [];

  Offset point = const Offset(0, 0);
  IO.Socket _socket;
  Map dataOfRoom = {};
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];

  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;

  bool isShowFinalLeaderboard = false;
  void setUpSocketListner() {
    _socket.on('receive', (pointdata) {
      //convert color to double
      String valueString =
          pointdata["color"].split('(0x')[1].split(')')[0]; // kind of hacky..
      int value = int.parse(valueString, radix: 16);
      Color color = new Color(value);
      double widht = double.parse('${pointdata["width"]}');
      /*print((data["dx"] * MediaQuery.of(context).size.height) /
          data["scrheight"]);*/

      if (this.mounted) {
        setState(() {
          //   print(data["color"]);
          if (pointdata["clear"] == true) {
            setState(() {
              // image = null;
              drawingPoints = [];
            });
          } else {
            if (pointdata["end"] == false) {
              drawingPoints.add(
                DrawingPoint(
                  point.translate(
                      double.parse(
                          '${double.parse('${pointdata["dx"]}') * MediaQuery.of(context).size.height / double.parse('${pointdata["scrheight"]}')}'),
                      double.parse(
                              '${double.parse('${pointdata["dy"]}') * MediaQuery.of(context).size.width / double.parse('${pointdata["scrwidth"]}')}') *
                          0.47),
                  Paint()
                    ..color = color
                    ..isAntiAlias = true
                    ..strokeWidth = widht
                    ..strokeCap = StrokeCap.round,
                ),
              );
            } else {
              drawingPoints.add(null);

              // drawingPoints.add(null);
              // generateImage();
            }
          }
        });
      } //  print(data["id"]);
    });
  }

  @override
  void initState() {
    super.initState();

    connect();
    print(widget.data['nickname']);
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
  }

  // Socket io client connection
  void connect() {
    _socket = IO.io('http://192.168.1.5:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();
    setUpSocketListner();

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

        //chay
        if (roomData['isJoin'] != true) {}
        //chay
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
            });
          });
        }
      });
      //chay
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
//chay
      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
//chay
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
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    drawingPainter = DrawingPainter(drawingPoints /*, image*/);

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
              ? Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.orange[400]),
                      ),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                              child: Center(
                                  child: Text(dataOfRoom['word'],
                                      style: TextStyle(fontSize: 30))),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: textBlankWidget,
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                              child: Container(
                                width: width * 0.95,
                                height: height * 0.35,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white,
                                        spreadRadius: 1.0,
                                      )
                                    ]),
                                child: Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0)),
                                    child: CustomPaint(
                                      painter: drawingPainter,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Displaying messages
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
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
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
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
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
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
                  ),
                )
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  // ui.Image image;

  DrawingPainter(this.drawingPoints /*, this.image*/);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    // if (image != null) canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    //canvas.scale(1, 0.47);

    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
            drawingPoints[i].paint);
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i].offset);

        canvas.drawPoints(
            PointMode.points, offsetsList, drawingPoints[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}
