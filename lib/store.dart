import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class Store {
  static FirebaseUser user;
  static BehaviorSubject<Widget> fragment = new BehaviorSubject();
  static dynamic selectedEvent;
  static Position position;
}
