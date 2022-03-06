import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'widgets/progress_bar.dart';
import 'widgets/time_state.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  PaintScreen({this.data, this.screenFrom});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  // instantiation
  var a;
  bool isjoin;
  GlobalKey globalKey = GlobalKey();
  ui.Image image;
  Uint8List imgbyte = Uint8List.fromList([0, 2, 5, 7, 42, 255]);

  DrawingPainter drawingPainter;

  List<DrawingPoint> drawingPoints = [];

  Offset point = const Offset(0, 0);
  var isLoadingSave = true;

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
  List<dynamic> colors = [
    Colors.red[700],
    Colors.black,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.green,
  ];

  bool isJoin = false;
  bool isShowFinalLeaderboard = false;
  void sendOffset(double x, double y, double width, double scrheight,
      double scrwidth, String color, bool end, bool clear) {
    var messageJson = {
      "dx": x,
      "dy": y,
      "width": width,
      "scrheight": scrheight,
      "scrwidth": scrwidth,
      "color": color,
      "end": end,
      "clear": clear,
      "romName": widget.data['name']
      // "id": socket.id
    };
    _socket.emit('coordinates', messageJson);
  }

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

      if (pointdata['romName'] == widget.data['name']) {
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
                        //double.parse('${pointdata["dx"]}'),
                        // double.parse('${pointdata["dy"]}')scrwidth
                        double.parse(
                            '${double.parse('${pointdata["dx"]}') * MediaQuery.of(context).size.width / double.parse('${pointdata["scrwidth"]}')}'),
                        double.parse(
                            '${double.parse('${pointdata["dy"]}') * MediaQuery.of(context).size.height / double.parse('${pointdata["scrheight"]}')}')),
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
        }
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
        /* for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
            });
          });
        }*/
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
            _scrollController.position.maxScrollExtent + 70,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      _socket.on('change-turn', (data) {
        setState(() {
          dataOfRoom = data;
          renderTextBlank(data['word']);
          isTextInputReadOnly = false;
        });
        /*showDialog(
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
            });*/
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
    /*if (dataOfRoom['isJoin'] == null) print("object");
    else print("notnull")
    isJoin = dataOfRoom['isJoin'];*/
  }

  @override
  void dispose() {
    _socket.dispose();

    super.dispose();
  }

  Timer _timer;
  int _start = 0;

  var test = false;
  startTimer() {
    if (!test) {
      test = true;
      _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) {
          if (_start == 10) {
            setState(() {
              if (dataOfRoom['turn']['nickname'] == widget.data['nickname']) {
                _socket.emit('change-turn', dataOfRoom['name']);
              }

              timer.cancel();
              test = false;
              _start = 0;
              drawingPoints = [];
            });
          } else {
            setState(() {
              _start++;
            });
          }
        },
      );
    }
    return ProgressBar(
      value: 10 - _start,
      totalvalue: 10,
    );
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
                      dataOfRoom['turn']['nickname'] != widget.data['nickname']
                          ? Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 10),
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: textBlankWidget,
                                  ),

                                  ElevatedButton(onPressed: () {
                                    _socket.emit(
                                        'change-turn', dataOfRoom['name']);
                                  }),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  startTimer(),

                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                    child: Container(
                                      width: width * 0.95,
                                      height: height * 0.45,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
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
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Displaying messages
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {},
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            child: ListView.builder(
                                                controller: _scrollController,
                                                shrinkWrap: true,
                                                itemCount: messages.length,
                                                itemBuilder: (context, index) {
                                                  var msg =
                                                      messages[index].values;
                                                  print(msg);
                                                  return ListTile(
                                                    title: Text(
                                                      msg.elementAt(0),
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 19,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                      msg.elementAt(1),
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16),
                                                    ),
                                                  );
                                                })),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: (Alignment.bottomCenter),
                                    child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: TextField(
                                          readOnly: isTextInputReadOnly,
                                          controller: controller,
                                          onSubmitted: (value) {
                                            print(value.trim());
                                            if (value.trim().isNotEmpty) {
                                              Map map = {
                                                'username':
                                                    widget.data['nickname'],
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
                                                    horizontal: 16,
                                                    vertical: 14),
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
                          //drawer screen
                          : Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Center(
                                      child: Text(dataOfRoom['word'],
                                          style: TextStyle(fontSize: 30))),
                                  Flexible(
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  msg.elementAt(1),
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16),
                                                ),
                                              );
                                            })),
                                  ),
                                  /*  ChangeNotifierProvider<TimeState>(
                                    create: (context) => TimeState(),
                                    child: Column(
                                      children: [
                                        Consumer<TimeState>(
                                          builder: (context, value, child) =>
                                              ProgressBar(
                                            value: 10 - value.time,
                                            totalvalue: 10,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Consumer<TimeState>(
                                            builder: (context, value, child) =>
                                                timetest(value)
                                                    ? ElevatedButton(
                                                        onPressed: () {
                                                          Timer.periodic(
                                                              Duration(
                                                                  seconds: 1),
                                                              (timer) {
                                                            value.time += 1;
                                                            if (value.time ==
                                                                10) {
                                                              timer.cancel();
                                                            }
                                                          });
                                                        },
                                                        child: Text("zz"))
                                                    : ElevatedButton(
                                                        onPressed: () {},
                                                        child: Text("aaa"))),
                                      ],
                                    ),
                                  ),*/

                                  /* ProgressBar(
                                    value: 10 - _start,
                                    totalvalue: 10,
                                  ),
                                  startTimer()
                                      ? ElevatedButton(
                                          onPressed: () {}, child: Text("aaa"))
                                      : ElevatedButton(
                                          onPressed: () {}, child: Text("bbb")),*/
                                  startTimer(),
                                  RepaintBoundary(
                                    // key: globalKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(1, 8, 1, 1),
                                      child: Container(
                                        width: width * 0.95,
                                        height: height * 0.45, //0.72,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white,
                                                spreadRadius: 1.0,
                                              )
                                            ]),
                                        child: GestureDetector(
                                          onPanStart: (details) {
                                            sendOffset(
                                              details.localPosition.dx,
                                              details.localPosition.dy,
                                              strokeWidth,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              MediaQuery.of(context).size.width,
                                              selectedColor.toString(),
                                              false,
                                              false,
                                            );

                                            setState(() {
                                              drawingPoints.add(
                                                DrawingPoint(
                                                  details.localPosition,
                                                  Paint()
                                                    ..color = selectedColor
                                                    ..isAntiAlias = true
                                                    ..strokeWidth = strokeWidth
                                                    ..strokeCap =
                                                        StrokeCap.round,
                                                ),
                                              );
                                            });
                                          },
                                          onPanUpdate: (details) {
                                            //  a = drawingPoints.length;

                                            sendOffset(
                                              details.localPosition.dx,
                                              details.localPosition.dy,
                                              strokeWidth,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              MediaQuery.of(context).size.width,
                                              selectedColor.toString(),
                                              false,
                                              false,
                                            );
                                            setState(() {
                                              drawingPoints.add(
                                                DrawingPoint(
                                                  details.localPosition,
                                                  Paint()
                                                    ..color = selectedColor
                                                    ..isAntiAlias = true
                                                    ..strokeWidth = strokeWidth
                                                    ..strokeCap =
                                                        StrokeCap.round,
                                                ),
                                              );
                                            });
                                            // generateImage();
                                          },
                                          onPanEnd: (details) {
                                            setState(() {
                                              sendOffset(
                                                null,
                                                null,
                                                strokeWidth,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                selectedColor.toString(),
                                                true,
                                                false,
                                              );

                                              drawingPoints.add(null);
                                            });
                                            //generateImage();
                                          },
                                          child: Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                              child: CustomPaint(
                                                painter: drawingPainter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //generate image

                                  Container(
                                    height: height * 0.10,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Slider(
                                          min: 1,
                                          max: 10,
                                          value: strokeWidth,
                                          onChanged: (val) =>
                                              setState(() => strokeWidth = val),
                                        ),
                                        FloatingActionButton(
                                            tooltip: "Erase",
                                            onPressed: () => setState(() {
                                                  selectedColor = Colors.white;
                                                }),
                                            child: Icon(
                                                FluentIcons.eraser_20_filled)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        FloatingActionButton(
                                            heroTag: "clear",
                                            child: Icon(Icons.delete),
                                            tooltip: "Clear",
                                            onPressed: () {
                                              setState(() {
                                                drawingPoints = [];
                                                //clean screen
                                                image = null;
                                                sendOffset(
                                                  null,
                                                  null,
                                                  strokeWidth,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  selectedColor.toString(),
                                                  false,
                                                  true,
                                                );
                                              });
                                            }),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        isLoadingSave
                                            ? FloatingActionButton(
                                                child: Icon(Icons.save),
                                                onPressed: () async {
                                                  await save();
                                                })
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator())
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      /* bottomNavigationBar: isDrowing == true
            ? BottomAppBar(
                child: Container(
                  color: Colors.orange[400],
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      colors.length,
                      (index) => _buildColorChose(colors[index]),
                    ),
                  ),
                ),
              )
            : null*/
    );
  }

  Widget _buildColorChose(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        height: isSelected ? 47 : 40,
        width: isSelected ? 47 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  Future<void> save() async {
    setState(() {
      isLoadingSave = false;
    });
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    image = await boundary.toImage(pixelRatio: 8.0);

    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    imgbyte = pngBytes;
    if (!(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }

    final saved = await ImageGallerySaver.saveImage(
      Uint8List.fromList(pngBytes),
      quality: 100,
      name: DateTime.now().toIso8601String() + ".png",
      isReturnImagePathOfIOS: true,
    );
    print(saved);

    if (saved['isSuccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.black26,
          content: const Text(
            "Drawing Saved",
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          duration: Duration(seconds: 1)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.black26,
          content: const Text(
            "Error",
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          duration: Duration(seconds: 1)));
    }
    setState(() {
      isLoadingSave = true;
    }); //generateImage();
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  // ui.Image image;

  DrawingPainter(this.drawingPoints /*, this.image*/);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
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
