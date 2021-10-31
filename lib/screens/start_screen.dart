// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  late final VoidCallback? navigateToStart;

  StartScreen({
    Key? key,
    this.navigateToStart
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Cool stopwatcher"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "Welcome to the most cool StopWatcher App!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.teal.shade900,
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 6
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text("Start"),
              onPressed: navigateToStart
            )
          ],
        )
      )
    );
  }
}