import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E88E5),  // Light Blue
            Color.fromARGB(255, 0, 0, 0),  // Dark Blue
          ],
        ),
      ), child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome to Temply',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 50),
        Center(child: Lottie.asset('assets/animations/Animation1.json' ,
            width: 300, height: 300, fit: BoxFit.cover)),
      ],
    ));
  }
}
