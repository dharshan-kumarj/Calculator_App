import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'Widgets/Calculator/Display.dart';
import 'Widgets/Calculator/Buttons.dart';
import '../Logics/Authentication/AuthLogics.dart';
import 'Widgets/Dashboard/DashBoard.dart';

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State {
  final AuthLogic _logic = AuthLogic();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    if (await _logic.isFirstTime()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialPasswordSetupDialog();
      });
    }
  }

  void _showInitialPasswordSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please set up a 4-digit password for your calculator.'),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: 'Enter 4-digit password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_passwordController.text.length == 4) {
                  bool success = await _logic.savePassword(_passwordController.text);
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password set successfully!')),
                    );
                  }
                  _passwordController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a 4-digit password')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter a new 4-digit password.'),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: 'Enter new 4-digit password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_passwordController.text.length == 4) {
                  bool success = await _logic.savePassword(_passwordController.text);
                  if (success) {
                    _logic.resetPasswordUpdateMode();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password updated successfully!')),
                    );
                  }
                  _passwordController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a 4-digit password')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
          _handleEquals();
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

  void _handleEquals() {
    // Check if this might be a password update trigger
    if (_logic.isPasswordUpdateTrigger()) {
      _logic.enablePasswordUpdateMode();
      _showPasswordUpdateDialog();
      return;
    }

    // Check if this might be a password verification attempt
    if (_logic.isPasswordAttempt()) {
      _verifyPassword();
    } else {
      // Normal calculation
      _logic.calculateResult();
    }
  }

  Future<void> _verifyPassword() async {
    String attempt = _logic.displayText;
    bool isValid = await _logic.validatePassword(attempt);

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password verified successfully!')),
      );

      // Navigate to the dashboard page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      // If invalid password, treat it as a normal number
      _logic.calculateResult();
    }
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

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}