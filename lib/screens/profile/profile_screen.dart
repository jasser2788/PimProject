import 'package:esprit/screens/profile/components/body.dart';
import 'package:flutter/material.dart';
import 'package:esprit/components/coustom_bottom_nav_bar.dart';
import 'package:esprit/enums.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Bodys(),
      bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.profile),
    );
  }
}
