import 'package:apm_pip/Home.dart';
import 'package:flutter/material.dart';

 void main() { 
 runApp(
   MaterialApp( 
      title: 'Mis Videos',
      home : MyApp(),
      theme: ThemeData.dark(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Home(),
    );
  }
}
