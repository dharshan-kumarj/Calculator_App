import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CalculatorButtons extends StatelessWidget {
  final Function(String) onButtonPressed;

  const CalculatorButtons({Key? key, required this.onButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('AC'),
              _buildButton('%'),
              _buildButton('Del', backgroundColor: Colors.purple[600]),
              _buildButton('÷')
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('−')
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('×')
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('+')
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('00'),
              _buildButton('0'),
              _buildButton('.'),
              _buildButton('=', backgroundColor: Colors.purple[600])
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton(
    String label, {
    Color? backgroundColor,
  }) {
    return FloatingActionButton(
      onPressed: () => onButtonPressed(label),
      backgroundColor: backgroundColor,
      child: Text(label),
    );
  }
}