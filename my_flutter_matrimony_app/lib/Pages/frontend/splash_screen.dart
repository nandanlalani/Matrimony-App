import 'package:flutter/material.dart';
import 'dart:async';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 3 seconds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 50,
                width: 50,
                child: Image.asset("assets/images/Screenshot 2025-02-17 200933.png",height: 200,width: 200,),),
            Text(
              "Darshan Matrimony",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            // Tagline
            Text(
              "Find your perfect match",
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
