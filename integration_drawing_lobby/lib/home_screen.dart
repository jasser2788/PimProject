import 'package:PIM_Mokhtar/widgets/time_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Create/Join a room to play!",
            style: TextStyle(color: Colors.deepPurple, fontSize: 24),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRoomScreen(),
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.brown),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2.5, 50))),
                child: const Text(
                  "Create",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinRoomScreen(),
                  ),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.amber),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2.5, 50))),
                child: const Text(
                  "Join",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
