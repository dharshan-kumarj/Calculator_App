import 'package:flutter/cupertino.dart';
import 'Static/CalculatorMain.dart';
import 'Static/Widgets/Calculator/Display.dart';
import 'Static/Widgets/Calculator/Buttons.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../Logics/CalculatorLogics/CoreLogics.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Calculator(),
    );
  }
}
