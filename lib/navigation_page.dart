import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/Pomodoro_page.dart';
import 'package:flutter_at_akira_menai/user_profile.dart';
import 'package:flutter_at_akira_menai/tasks_page.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final PageController _pageController = PageController();
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    const Placeholder(), // Replace with your HomeScreen()
    const Taskspage(),
    const PomodoroPage(), // Replace with your PomodoroPage
    const UserProfile(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => currentPageIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: GNav(
              selectedIndex: currentPageIndex,
              onTabChange: (index) {
                setState(() => currentPageIndex = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                );
              },
              tabBorderRadius: 30,
              rippleColor: Colors.grey.shade800,
              backgroundColor: AppColors.primaryLight,
              color: Colors.white,
              activeColor: Colors.white,
              tabActiveBorder: Border.all(color: Colors.white, width: 1),
              gap: 8,
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.task, text: 'Tasks'),
                GButton(icon: Icons.alarm, text: 'Pomodoro'),
                GButton(icon: Icons.person, text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
