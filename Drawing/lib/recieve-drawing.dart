import 'dart:convert';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'main.dart';

class RecieveDrawing extends StatefulWidget {
  @override
  _RecieveDrawingState createState() => _RecieveDrawingState();
}

class _RecieveDrawingState extends State<RecieveDrawing> {
  // instantiation
  ui.Image image;

  DrawingPainter drawingPainter;

  double strokeWidth = 5;

  Offset point = const Offset(0, 0);
  IO.Socket socket;
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];

  //final customPaint = CustomPaint();
  List<DrawingPoint> drawingPoints = [];
  void setUpSocketListner() {
    socket.on('receive', (data) {
      //convert color to double
      String valueString =
          data["color"].split('(0x')[1].split(')')[0]; // kind of hacky..
      int value = int.parse(valueString, radix: 16);
      Color color = new Color(value);
      double widht = double.parse('${data["width"]}');
      /*print((data["dx"] * MediaQuery.of(context).size.height) /
          data["scrheight"]);*/

      if (this.mounted) {
        setState(() {
          //   print(data["color"]);
          if (data["clear"] == true) {
            setState(() {
              image = null;
              drawingPoints = [];
            });
          } else {
            if (data["end"] == false) {
              drawingPoints.add(
                DrawingPoint(
                  point.translate(
                      double.parse(
                          '${double.parse('${data["dx"]}') * MediaQuery.of(context).size.height / double.parse('${data["scrheight"]}')}'),
                      double.parse(
                              '${double.parse('${data["dy"]}') * MediaQuery.of(context).size.width / double.parse('${data["scrwidth"]}')}') *
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
              // generateImage();
            }
          }
        });
      } //  print(data["id"]);
    });
  }

  @override
  void initState() {
    socket = IO.io(
        //'http://10.0.2.2:3000',
        'http://192.168.1.5:3000',
        // 'http://192.168.43.171:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            //.setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    socket.connect();
    setUpSocketListner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    drawingPainter = DrawingPainter(drawingPoints, image);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(color: Colors.orange[400]),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Container(
                    width: width * 0.95,
                    height: height * 0.35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            spreadRadius: 1.0,
                          )
                        ]),
                    child: Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        child: CustomPaint(
                          painter: drawingPainter,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    //height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          // var msg = messages[index].values;
                          print("msg");
                          return ListTile(
                            title: Text(
                              "msg.elementAt(0)",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "msg.elementAt(1)",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                          );
                        })),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void generateImage() async {
    print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    ui.PictureRecorder recorder = ui.PictureRecorder();
    //drawingPoints = [];
    Canvas canvas = new Canvas(recorder);
    //canvas.drawImage(image, offset, paint)

    drawingPainter.paint(canvas, MediaQuery.of(context).size);

    final picture = recorder.endRecording();
    final img = await picture.toImage(MediaQuery.of(context).size.width.toInt(),
        MediaQuery.of(context).size.height.toInt());
    //  final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    drawingPoints = [];
    image = img;
    //canvas.drawImage(img, Offset.zero, Paint());
    setState(() {
      // imgBytes = pngBytes;
    });
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  ui.Image image;

  DrawingPainter(this.drawingPoints, this.image);

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
