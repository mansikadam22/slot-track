import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';

import '../Screens/home_page.dart';
import '../Screens/slot_page.dart';
import '../Screens/history_page.dart';
import '../Screens/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final Color primaryBlue = const Color(0xFF1E88E5);
  final Color lightBlue = const Color(0xFFBBDEFB);

  // -------- CHANGE TAB FUNCTION --------
  void changeTab(int index) {
    setState(() {
      _page = index;
    });

    final navBar = _bottomNavigationKey.currentState;
    navBar?.setPage(index);
  }

  // -------- WIDGET OPTIONS --------
  List<Widget> get _widgetOptions => [
    HomePage(changeTab: changeTab), // <-- FIXED
    Slotpage(),
    const HistoryReportsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions[_page]),

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.local_parking, size: 30, color: Colors.white),
          Icon(Icons.analytics_outlined, size: 30, color: Colors.white),
          Icon(Icons.account_circle_outlined, size: 30, color: Colors.white),
        ],

        color: primaryBlue,
        buttonBackgroundColor: lightBlue,
        backgroundColor: Colors.transparent,

        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),

        onTap: (index) {
          setState(() => _page = index);
        },
      ),
    );
  }
}
