import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int value;
  final int totalvalue;
  final VoidCallback onStart;
  const ProgressBar({Key key, this.value, this.totalvalue, this.onStart});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;
    double ratio = value / totalvalue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /*Icon(Icons.timer),
        SizedBox(
          width: 5,
        ),*/
        Stack(
          children: [
            Container(
              width: width,
              height: 10,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5)),
            ),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(5),
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                width: width * ratio,
                height: 10,
                decoration: BoxDecoration(
                    color: ratio < 0.22
                        ? Colors.red
                        : ratio < 0.66
                            ? Colors.amber
                            : Colors.lightGreen,
                    borderRadius: BorderRadius.circular(5)),
              ),
            )
          ],
        )
      ],
    );
  }
}
