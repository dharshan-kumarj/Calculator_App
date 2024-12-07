import 'package:flutter/material.dart';

class CalculatorLogic {
  String displayText = '0';
  String currentInput = '';
  List<double> operands = [];
  List<String> operators = [];
  bool isNewCalculation = true;

  void updateDisplay(String value) {
    if (isNewCalculation) {
      currentInput = '';
      isNewCalculation = false;
    }

    if (currentInput.isEmpty && value == '0') {
      displayText = '0';
    } else {
      if (currentInput.isEmpty && value == '00') {
        currentInput = '0';
      } else {
        currentInput += value;
      }
      displayText = currentInput;
    }
  }

  void clearDisplay() {
    displayText = '0';
    currentInput = '';
    operands.clear();
    operators.clear();
    isNewCalculation = true;
  }

  void setOperator(String operator) {
    if (currentInput.isNotEmpty) {
      operands.add(double.parse(currentInput));
      currentInput = '';
    }

    if (operands.isEmpty && displayText != '0') {
      operands.add(double.parse(displayText));
    }

    operators.add(operator);
  }

  void calculateResult() {
    if (currentInput.isNotEmpty) {
      operands.add(double.parse(currentInput));
    }

    if (operands.isEmpty) return;

    while (operators.length < operands.length - 1) {
      operators.add(operators.last);
    }

    double result = operands[0];

    for (int i = 0; i < operators.length; i++) {
      switch (operators[i]) {
        case 'add':
          result += operands[i + 1];
          break;
        case 'subtract':
          result -= operands[i + 1];
          break;
        case 'multiply':
          result *= operands[i + 1];
          break;
        case 'divide':
          result = _safeDivision(result, operands[i + 1]);
          break;
        case 'percent':
          result *= (operands[i + 1] / 100);
          break;
      }
    }

    displayText = _formatResult(result);
    currentInput = '';
    operands = [result];
    operators.clear();
    isNewCalculation = true;
  }

  void deleteLastChar() {
    if (currentInput.isNotEmpty) {
      currentInput = currentInput.substring(0, currentInput.length - 1);
      displayText = currentInput.isEmpty ? '0' : currentInput;
    }
  }

  double _safeDivision(double a, double b) {
    if (b == 0) {
      return 0;
    }
    return a / b;
  }

  String _formatResult(double result) {
    String formatted = result.toString();
    if (formatted.contains('.')) {
      formatted = formatted.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return formatted;
  }
}