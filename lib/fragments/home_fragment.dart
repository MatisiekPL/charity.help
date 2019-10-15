import 'package:charity_help/screens/event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import '../store.dart';

class HomeFragment extends StatefulWidget {
  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
        builder: (context, AsyncSnapshot<Position> snap) {
          if (!snap.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          Store.position = snap.data;
          return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('events').snapshots(),
              builder: (context, query) {
                if (query.hasError) return new Text('Error: ${query.error}');
                switch (query.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return FlutterMap(
                      options: MapOptions(
                        center: LatLng(snap.data.latitude, snap.data.longitude),
                        zoom: 14.0,
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        ),
                        MarkerLayerOptions(
                            markers: ([]..addAll(query.data.documents
                                .map((doc) => Marker(
                                      width: 32.0,
                                      height: 32.0,
                                      point: LatLng(doc['location'].latitude,
                                          doc['location'].longitude),
                                      builder: (ctx) => GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          Store.selectedEvent = doc.documentID;
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventScreen()));
                                        },
                                        child: Container(
                                            child: Image(
                                                image: AssetImage(
                                                    "assets/marker.png"))),
                                      ),
                                    ))
                                .toList()))
                              ..addAll([
                                Marker(
                                  width: 32.0,
                                  height: 32.0,
                                  point: LatLng(
                                      snap.data.latitude, snap.data.longitude),
                                  builder: (ctx) => GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                        child: Image(
                                            image: AssetImage(
                                                "assets/navigation_arrow.png"))),
                                  ),
                                )
                              ])),
                      ],
                    );
                }
              });
        });
  }
}
