import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'widgets/progress_bar.dart';

class FreeDraw extends StatefulWidget {
  const FreeDraw({Key key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<FreeDraw> {
  GlobalKey globalKey = GlobalKey();
  ui.Image image;

  Uint8List imgbyte = Uint8List.fromList([0, 2, 5, 7, 42, 255]);

  DrawingPainter drawingPainter;

  var imgBytes = ByteData(160);
  var isLoadingSave = true;
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];

  Offset testoffset = const Offset(150, 360);
  Color selectedColor = Colors.black;
  double strokeWidth = 3;
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    drawingPainter = DrawingPainter(drawingPoints, image);
    print(MediaQuery.of(context).size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.orange[400]),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  /* Flexible(
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
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
                  ), */
                  RepaintBoundary(
                    key: globalKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(1, 8, 1, 1),
                      child: Container(
                        width: width * 0.95,
                        height: height * 0.72, //0.72,
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
                          min: 1,
                          max: 10,
                          value: strokeWidth,
                          onChanged: (val) => setState(() => strokeWidth = val),
                        ),
                        FloatingActionButton(
                            tooltip: "Erase",
                            onPressed: () => setState(() {
                                  selectedColor = Colors.white;
                                }),
                            child: Icon(FluentIcons.eraser_20_filled)),
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
                            : const Center(child: CircularProgressIndicator())
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    setState(() {
      isLoadingSave = false;
    });
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint(this.offset, this.paint);
}
