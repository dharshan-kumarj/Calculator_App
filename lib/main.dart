import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

void main() {
  runApp(MaterialApp(
    home: Calculator(),
  ));
}

class Calculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1474108396.
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        centerTitle: true,
        backgroundColor: Colors.purple[600],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 165.0, 40.0, 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      print("AC is clicked");
                    },
                    child: const Text('AC'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("% is clicked");
                    },
                    child: Icon(CupertinoIcons.percent),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("del is clicked");
                    },
                    child: Icon(CupertinoIcons.delete_left),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("div is clicked");
                    },
                    child: Icon(CupertinoIcons.divide),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      print("1 is clicked");
                    },
                    child: const Text('1'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("2 is clicked");
                    },
                    child: const Text('2'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("3 is clicked");
                    },
                    child: const Text('3'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("- is clicked");
                    },
                    child: const Icon(Icons.remove),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      print("4 is clicked");
                    },
                    child: const Text('4'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("5 is clicked");
                    },
                    child: const Text('5'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("6 is clicked");
                    },
                    child: const Text('6'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("X is clicked");
                    },
                    child: Icon(CupertinoIcons.multiply),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      print("7 is clicked");
                    },
                    child: const Text('7'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("8 is clicked");
                    },
                    child: const Text('8'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("9 is clicked");
                    },
                    child: const Text('9'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("add is clicked");
                    },
                    child: Icon(CupertinoIcons.add),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      print("00 is clicked");
                    },
                    child: const Text('00'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("0 is clicked");
                    },
                    child: const Text('0'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print(". is clicked");
                    },
                    child: const Text('.'),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print("equal is clicked");
                    },
                    child: Icon(CupertinoIcons.equal),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
