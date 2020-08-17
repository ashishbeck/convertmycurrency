import 'package:currencyconverter/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
//  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
////    systemNavigationBarColor: Colors.white, // navigation bar color
////    statusBarColor: Colors.pink, // status bar color
//  ));
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
//        appBarTheme: AppBarTheme(color: Colors.white, elevation: 0, brightness: Brightness.light),
        scaffoldBackgroundColor: Colors.white,
        primaryColorBrightness: Brightness.light,
        primarySwatch: Colors.pink,
        accentColor: Colors.lightBlue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: homePage(),
    );
  }
}
