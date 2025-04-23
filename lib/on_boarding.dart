import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/Intro_Screens/intro_page1.dart';
import 'package:flutter_at_akira_menai/Intro_Screens/intro_page2.dart';
import 'package:flutter_at_akira_menai/Intro_Screens/intro_page3.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged:
                (value) => setState(() {
                  isLastPage = value == 2;
                }),
            controller: _controller,
            children: [IntroPage1(), IntroPage2(), IntroPage3()],
          ),
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _controller.jumpToPage(2);
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.white,
                    dotColor: Color.fromARGB(168, 255, 255, 255),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 4,
                  ),
                ),
                isLastPage
                    ? TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignUpPage(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeThroughTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ), // Optional: adjust duration
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "done",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                    : TextButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        "next",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
