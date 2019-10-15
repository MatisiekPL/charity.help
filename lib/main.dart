import 'package:charity_help/screens/home_screen.dart';
import 'package:charity_help/screens/intro_screen.dart';
import 'package:charity_help/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(App());

final GoogleSignIn googleSignIn = GoogleSignIn();
final FirebaseAuth auth = FirebaseAuth.instance;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: FutureBuilder(
          future: auth.currentUser(),
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) return IntroScreen();
            Store.user = snap.data;
            return HomeScreen();
          },
        ));
  }
}
