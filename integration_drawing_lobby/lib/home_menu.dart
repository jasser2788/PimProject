import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'free_draw.dart';
import 'home_screen.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({Key});

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logot.PNG', width: 500, height: 200),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange[600]),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2.5, 50))),
              child: const Text(
                "Play",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FreeDraw(),
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange[600]),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2.5, 50))),
              child: const Text(
                "Free draw",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange[600]),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2.5, 50))),
              child: const Text(
                "Market",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {},
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange[600]),
                  textStyle:
                      MaterialStateProperty.all(TextStyle(color: Colors.white)),
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width / 2.5, 50))),
              child: const Text(
                "Settings",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
