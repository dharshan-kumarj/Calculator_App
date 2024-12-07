import 'package:flutter/material.dart';

class CalculatorDisplay extends StatelessWidget {
  final String displayText;

  const CalculatorDisplay({Key? key, required this.displayText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.purple.shade600,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 48,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}