import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:drawing_app/recieve-drawing.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DrawingBoard(),
    );
  }
}

class DrawingBoard extends StatefulWidget {
  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  GlobalKey globalKey = GlobalKey();
  ui.Image image;

  Uint8List imgbyte = Uint8List.fromList([0, 2, 5, 7, 42, 255]);

  DrawingPainter drawingPainter;

  var imgBytes = ByteData(160);

  Offset testoffset = const Offset(150, 360);
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<DrawingPoint> drawingPoints = [];
  bool isPoint = false;

  List<dynamic> colors = [
    Colors.red[700],
    Colors.black,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.green,
  ];
  IO.Socket socket;

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
      // "id": socket.id
    };
    socket.emit('coordinates', messageJson);
  }

  /*void setUpSocketListner() {
    socket.on('receive', (data) {
      //  print(data);
    });
  }*/

  @override
  void initState() {
    socket = IO.io(
        // 'http://10.0.2.2:3000',
        'http://192.168.1.5:3000',
        // 'http://192.168.43.171:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            //.setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    socket.connect();

    // setUpSocketListner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    drawingPainter = DrawingPainter(drawingPoints, image);
    print(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RepaintBoundary(
        key: globalKey,
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.orange[400]),
              ),
              Positioned(
                top: 25,
                right: 10,
                child: ElevatedButton(
                  child: Text('>'),
                  onPressed: () => setState(() => Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return RecieveDrawing();
                      }))),
                ),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        width: width * 0.95,
                        height: height * 0.72,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
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
                                MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width,
                                selectedColor.toString(),
                                false,
                                false);

                            setState(() {
                              drawingPoints.add(
                                DrawingPoint(
                                  details.localPosition,
                                  Paint()
                                    ..color = selectedColor
                                    ..isAntiAlias = true
                                    ..strokeWidth = strokeWidth
                                    ..strokeCap = StrokeCap.round,
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
                                MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width,
                                selectedColor.toString(),
                                false,
                                false);
                            setState(() {
                              drawingPoints.add(
                                DrawingPoint(
                                  details.localPosition,
                                  Paint()
                                    ..color = selectedColor
                                    ..isAntiAlias = true
                                    ..strokeWidth = strokeWidth
                                    ..strokeCap = StrokeCap.round,
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
                                  MediaQuery.of(context).size.height,
                                  MediaQuery.of(context).size.width,
                                  selectedColor.toString(),
                                  true,
                                  false);

                              drawingPoints.add(null);
                            });
                            //generateImage();
                          },
                          child: Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              child: CustomPaint(
                                painter: drawingPainter,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //generate image
                    /* imgBytes != null
                                 ? Center(
                                    child: Image.memory(
                                      Uint8List.view(imgBytes.buffer),
                                  width: MediaQuery.of(context).size.height,
                                height: MediaQuery.of(context).size.width,
                                      ))
                                  : Container(),*/

                    Container(
                      height: height * 0.10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                            min: 0,
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
                              child: Icon(FluentIcons.eraser_20_filled)),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: FloatingActionButton(
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
                                        MediaQuery.of(context).size.height,
                                        MediaQuery.of(context).size.width,
                                        selectedColor.toString(),
                                        false,
                                        true);
                                  });
                                }),
                          ),
                          /*ElevatedButton(
                        child: Text('save'),
                        onPressed: () {
                          save();
                        }),*/
                        ],
                      ),

                      /*  Positioned(
                         top: 0,
                            right: 0,
                       child: SizedBox(
                                     width: MediaQuery.of(context).size.width,
                                   height: MediaQuery.of(context).size.height,
                               child: Image.memory(imgbyte),
                              ),
                                   ),*/
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.orange[400],
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              colors.length,
              (index) => _buildColorChose(colors[index]),
            ),
          ),
        ),
      ),
      /* floatingActionButton: AnimatedFloatingActionButton(
        fabButtons: fabOption(),
        colorStartAnimation: Colors.blue,
        colorEndAnimation: Colors.blue,
        animatedIconData: AnimatedIcons.close_menu,
      ),*/
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
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    image = await boundary.toImage(pixelRatio: 8.0);

    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    imgbyte = pngBytes;
    if (!(await Permission.storage.isGranted))
      await Permission.storage.request();

    final saved = await ImageGallerySaver.saveImage(
      Uint8List.fromList(pngBytes),
      quality: 100,
      name: DateTime.now().toIso8601String() + ".png",
      isReturnImagePathOfIOS: true,
    );
    print(saved);
    //generateImage();
  }

  void generateImage() async {
    print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    /*  RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    drawingPoints = [];

    image = await boundary.toImage(pixelRatio: 1.0);*/

    ui.PictureRecorder recorder = ui.PictureRecorder();

    Canvas canvas = new Canvas(recorder);
    var dpr = ui.window.devicePixelRatio;
    //canvas.scale(dpr, dpr);
    drawingPainter.paint(canvas, MediaQuery.of(context).size);
    //canvas.drawColor(Colors.red, BlendMode.color);
    final picture = recorder.endRecording();

    var img = await picture.toImage(
        (MediaQuery.of(context).size.width.toInt() * dpr).ceil(),
        (MediaQuery.of(context).size.height.toInt() * dpr).ceil());
    // recorder.endRecording();

    /* canvas.drawImage(img, Offset.zero, Paint());
    drawingPainter.paint(canvas, MediaQuery.of(context).size);
    recorder.endRecording();*/
    setState(() {
      drawingPoints = [];
      image = img;
      // imgBytes = pngBytes;
    });
  }
}

class DrawingPainter extends CustomPainter {
  List<DrawingPoint> drawingPoints;
  ui.Image image;

  DrawingPainter(this.drawingPoints, this.image);
  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      // canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    }
    // canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
            drawingPoints[i].paint /*..blendMode = BlendMode.clear*/);
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i].offset);

        canvas.drawPoints(
            PointMode.points, offsetsList, drawingPoints[i].paint);
      }
    }
    // canvas.restore();
    print(drawingPoints.length);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint(this.offset, this.paint);
}
