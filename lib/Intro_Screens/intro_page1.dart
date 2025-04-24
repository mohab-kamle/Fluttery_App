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
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 80, 162, 255),  // Light Blue
            Color.fromARGB(255, 28, 56, 89),
            Colors.black  // Dark Blue
          ],
        )
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
        const SizedBox(height: 50),
        const Text(
          'Your Ultimate Task Management App',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ));
  }
}
