import 'package:charity_help/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

import '../main.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();
    slides.add(Slide(
        title: 'Witaj w charity.help',
        styleTitle: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        description: 'Zobacz jak to działa',
        backgroundColor: Colors.blue,
        pathImage: 'assets/logo.png'));
    slides.add(Slide(
        title: 'Zaloguj się',
        styleTitle: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        description: 'Aby korzystać z aplikacji, zaloguj się',
        backgroundColor: Colors.pink,
        pathImage: 'assets/fingerprint.png'));
    slides.add(Slide(
        title: 'Znadź zbiórkę dobroczynną',
        styleTitle: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        description:
            'Wybierz tą, która ci odpowiada - na przykład tą, która jest najbliżej twojego miejsca zamieszkania',
        backgroundColor: Colors.teal,
        pathImage: 'assets/social-care.png'));
    slides.add(Slide(
        title: 'Przekaż żywność lub rzeczy codziennego użytku',
        maxLineTitle: 100,
        styleTitle: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        description:
            'Gdy posiadasz coś, czego już nie potrzebujesz, przekaż to organizacji charytatywnej',
        backgroundColor: Colors.green,
        pathImage: 'assets/vegetables.png'));
    slides.add(Slide(
        title: 'Pamiętaj, dobro powraca!',
        styleTitle: TextStyle(
            fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
        description:
            'Pomoc potrzebującym z krajów trzeciego świata lub z lokalnej społeczności przyczyni się do stawania się lepszym człowiekiem',
        backgroundColor: Colors.blue,
        pathImage: 'assets/like.png'));
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  Future<void> _login() async {
    try {
      var user = await _handleSignIn();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IntroSlider(
            slides: this.slides,
            namePrevBtn: 'Wstecz',
            nameNextBtn: 'Dalej',
            nameDoneBtn: 'Zacznij',
            nameSkipBtn: 'Pomiń',
            onDonePress: () {
              _login();
            }));
  }
}
