import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'Widgets/Display.dart';
import 'Widgets/Buttons.dart';
import '../Logics/CalculatorLogics/CoreLogics.dart';

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final CalculatorLogic _logic = CalculatorLogic();

  void _handleButtonPress(String value) {
    setState(() {
      switch (value) {
        case 'AC':
          _logic.clearDisplay();
          break;
        case 'Del':
          _logic.deleteLastChar();
          break;
        case '=':
          _logic.calculateResult();
          break;
        case '+':
          _logic.setOperator('add');
          break;
        case '−':
          _logic.setOperator('subtract');
          break;
        case '×':
          _logic.setOperator('multiply');
          break;
        case '÷':
          _logic.setOperator('divide');
          break;
        case '%':
          _logic.setOperator('percent');
          break;
        default:
          _logic.updateDisplay(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calculator",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[600],
      ),
      body: Column(
        children: [
          CalculatorDisplay(displayText: _logic.displayText),
          Expanded(
            child: Container(
              child: CalculatorButtons(onButtonPressed: _handleButtonPress),
            ),
          ),
        ],
      ),
    );
  }
}