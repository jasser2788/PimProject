import 'package:esprit/screens/splash/splash_screen.dart';
import 'package:esprit/src/screens/after_launch_screen/after_launch_screen_view.dart';
import 'package:esprit/src/screens/register/register_view.dart';
import 'package:esprit/src/screens/settings/settings_view.dart';
import 'package:esprit/src/widgets/custom_page_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit/theme.dart';
import 'package:esprit/routes.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    )); // change status bar color

    // FlutterStatusbarcolor.setStatusBarColor(Colors.white);

    return Provider(
      create: (BuildContext context) {},
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Welcome',
        theme: theme(),
        initialRoute: '/',
        routes: routes,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return PageRouteBuilder(
                  pageBuilder: (_, a1, a2) => AfterLaunchScreen(),
                  settings: settings);
            case '/splash':
              return CustomPageRoute.build(
                  builder: (_) => SplashScreen(), settings: settings);
            case '/register':
              return CustomPageRoute.build(
                  builder: (_) => RegisterScreen(), settings: settings);

            case '/settings':
              return CustomPageRoute.build(
                  builder: (_) => SettingsScreen(), settings: settings);
            default:
              return CustomPageRoute.build(
                  builder: (_) => AfterLaunchScreen(), settings: settings);
          }
        },
      ),
    );
  }
}
