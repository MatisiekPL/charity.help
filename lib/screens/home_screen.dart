import 'package:charity_help/fragments/home_fragment.dart';
import 'package:charity_help/fragments/profile_fragment.dart';
import 'package:flutter/material.dart';

import '../store.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _navigate(0);
  }

  void _navigate(index) {
    switch (index) {
      case 0:
        Store.fragment.add(HomeFragment());
        break;
      case 1:
        Store.fragment.add(ProfileFragment());
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Zbiórki')),
      ),
      body: StreamBuilder(
        stream: Store.fragment,
        builder: (context, snap) {
          return snap.hasData ? snap.data : Container();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), title: Text('Zbiórki')),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text('Profil'))
        ],
        onTap: (index) {
          _navigate(index);
        },
      ),
    );
  }
}
