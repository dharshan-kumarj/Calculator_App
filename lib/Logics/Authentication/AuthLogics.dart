import 'package:shared_preferences/shared_preferences.dart';

class AuthLogic {
  String displayText = '0';
  double? _firstOperand;
  String? _currentOperator;
  bool _resetDisplay = false;
  bool _isPasswordUpdateMode = false;

  // Password Management
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('is_setup_complete');
  }

  Future<void> markSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_setup_complete', true);
  }

  Future<bool> savePassword(String password) async {
    if (password.length != 4) return false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_setup_complete', true);
    return await prefs.setString('calculator_password', password);
  }

  Future<bool> validatePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString('calculator_password');
    return password == savedPassword;
  }

  // Check if input might be a password attempt or password update
  bool isPasswordAttempt() {
    // Check if the display shows exactly 4 digits and no operators
    return displayText.length == 4 && 
           RegExp(r'^\d{4}$').hasMatch(displayText) &&
           _firstOperand == null &&
           _currentOperator == null;
  }

  // New method to check if password update is triggered
  bool isPasswordUpdateTrigger() {
    return displayText == '1312';
  }

  // Method to enable password update mode
  void enablePasswordUpdateMode() {
    _isPasswordUpdateMode = true;
  }

  // Method to check if in password update mode
  bool isPasswordUpdateMode() {
    return _isPasswordUpdateMode;
  }

  // Method to reset password update mode
  void resetPasswordUpdateMode() {
    _isPasswordUpdateMode = false;
  }

  // Calculator Logic Methods
  void updateDisplay(String value) {
    if (_resetDisplay) {
      displayText = '0';
      _resetDisplay = false;
    }

    if (displayText == '0') {
      displayText = value;
    } else {
      displayText += value;
    }
  }

  void setOperator(String operator) {
    _firstOperand = double.parse(displayText);
    _currentOperator = operator;
    _resetDisplay = true;
  }

  void calculateResult() {
    if (_firstOperand == null || _currentOperator == null) return;

    double secondOperand = double.parse(displayText);
    double result = 0;

    switch (_currentOperator) {
      case 'add':
        result = _firstOperand! + secondOperand;
        break;
      case 'subtract':
        result = _firstOperand! - secondOperand;
        break;
      case 'multiply':
        result = _firstOperand! * secondOperand;
        break;
      case 'divide':
        result = _firstOperand! / secondOperand;
        break;
      case 'percent':
        result = _firstOperand! * (secondOperand / 100);
        break;
    }

    displayText = result.toString();
    _firstOperand = null;
    _currentOperator = null;
    _resetDisplay = true;
  }

  void clearDisplay() {
    displayText = '0';
    _firstOperand = null;
    _currentOperator = null;
  }

  void deleteLastChar() {
    if (displayText.length > 1) {
      displayText = displayText.substring(0, displayText.length - 1);
    } else {
      displayText = '0';
    }
  }
}