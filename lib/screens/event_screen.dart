import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';

import '../store.dart';

// TODO add chart that shows progress on event
// TODO secure app

final GlobalKey<AnimatedCircularChartState> _chartKey =
    new GlobalKey<AnimatedCircularChartState>();

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('events')
            .document(Store.selectedEvent)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          return snapshot.hasData && snapshot.data != null
              ? Scaffold(
                  appBar: AppBar(title: Text('Szczegóły zbiórki')),
                  body: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GestureDetector(
                          onTap: () {
                            var edit = () async {
                              if (!await _isEventAuthor(snapshot.data)) return;
                              var nameController = TextEditingController();
                              var descriptionController =
                                  TextEditingController();
                              var addressController = TextEditingController();
                              nameController.text = snapshot.data['name'];
                              descriptionController.text =
                                  snapshot.data['description'];
                              addressController.text = snapshot.data['address'];
                              showDialog(
                                  child: AlertDialog(
                                    title: Text('Edytuj zbiórkę'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: 'Nazwa'),
                                          controller: nameController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: 'Opis'),
                                          controller: descriptionController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: 'Adres'),
                                          controller: addressController,
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          'Usuń',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Firestore.instance
                                              .collection('events')
                                              .document(
                                                  snapshot.data.documentID)
                                              .delete();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Anuluj'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Zapisz'),
                                        onPressed: () {
                                          () async {
                                            try {
                                              var coordinatesList =
                                                  await Geocoder
                                                      .local
                                                      .findAddressesFromQuery(
                                                          addressController
                                                              .text);

                                              var loc = GeoPoint(
                                                  coordinatesList.first
                                                      .coordinates.latitude,
                                                  coordinatesList.first
                                                      .coordinates.longitude);
                                              Firestore.instance
                                                  .collection('events')
                                                  .document(
                                                      snapshot.data.documentID)
                                                  .updateData({
                                                'name': nameController.text,
                                                'description':
                                                    descriptionController.text,
                                                'address':
                                                    addressController.text,
                                                'location': loc
                                              });
                                              Navigator.of(context).pop();
                                            } catch (err) {
                                              showDialog(
                                                  context: context,
                                                  child: AlertDialog(
                                                    title: Text(
                                                        'Nieprawidłowy adres'),
                                                    content: Text(
                                                        'Podaj prawidłowy adres'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('OK'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      )
                                                    ],
                                                  ));
                                            }
                                          }();
                                        },
                                      ),
                                    ],
                                  ),
                                  context: context);
                            };
                            () async {
                              if (await _isEventAuthor(snapshot.data)) edit();
                            }();
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    top: 8.0,
                                  ),
                                  child: Text(
                                    snapshot.hasData
                                        ? snapshot.data.data['name']
                                        : 'ładowanie',
                                    style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, top: 8.0),
                                  child: FutureBuilder(
                                      future: (snapshot.data.data['author']
                                              as DocumentReference)
                                          .get(),
                                      builder: (context, authorSnap) {
                                        return Text(
                                          (snapshot.hasData
                                              ? snapshot.data['description']
                                              : 'ładowanie'),
                                        );
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, top: 8.0),
                                  child: FutureBuilder(
                                      future: (snapshot.data.data['author']
                                              as DocumentReference)
                                          .get(),
                                      builder: (context, authorSnap) {
                                        return Text(
                                          'Zbiórkę organizuje: ' +
                                              (authorSnap.hasData
                                                  ? authorSnap.data.data['name']
                                                  : 'ładowanie'),
                                        );
                                      }),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, top: 8.0, bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Adres: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Flexible(
                                          child: Text(
                                              snapshot.hasData
                                                  ? snapshot
                                                      .data.data['address']
                                                  : 'ładowanie',
                                              textAlign: TextAlign.left),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      snapshot.hasData
                          ? _buildMapCard(snapshot.data)
                          : Container(),
                      snapshot.hasData
                          ? _buildThingsCard(snapshot.data)
                          : Container()
                    ],
                  ),
                )
              : Container();
        });
  }

  _buildMapCard(DocumentSnapshot eventDoc) {
    return Container(
      height: 270,
      child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
          child: Card(
              child: FlutterMap(
            options: MapOptions(
              center: LatLng(Store.position.latitude, Store.position.longitude),
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayerOptions(markers: [
                Marker(
                  width: 32.0,
                  height: 32.0,
                  point: LatLng(eventDoc.data['location'].latitude,
                      eventDoc.data['location'].longitude),
                  builder: (ctx) => Container(
                    child: Image(image: AssetImage("assets/marker.png")),
                  ),
                )
              ])
            ],
          ))),
    );
  }

  _isEventAuthor(DocumentSnapshot eventDoc) async {
    var docs = await Firestore.instance
        .collection('organisations')
        .document((await (eventDoc.data['author'] as DocumentReference)
                .snapshots()
                .first)
            .documentID)
        .collection('members')
        .where('id', isEqualTo: Store.user.uid)
        .getDocuments();
    return docs.documents.length > 0;
  }

  _buildThingsCard(DocumentSnapshot eventDoc) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('events')
            .document(eventDoc.documentID)
            .collection('things')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
            child: Card(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                  ),
                  child: Text(
                    'Najpotrzebniejsze rzeczy',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 16.0, bottom: 16.0),
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data != null
                        ? snapshot.data.documents.length + 1
                        : 1,
                    itemBuilder: (context, index) {
                      if (snapshot.data == null) return Container();
                      if (snapshot.data.documents == null) return Container();
                      if (index < snapshot.data.documents.length) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            var open = () async {
                              var result = await _isEventAuthor(eventDoc);
                              if (!result) return;
                              TextEditingController nameController =
                                  new TextEditingController();
                              TextEditingController targetController =
                                  new TextEditingController();
                              nameController.text =
                                  snapshot.data.documents[index].data['name'];
                              targetController.text = snapshot
                                  .data.documents[index].data['target']
                                  .toString();
                              int count =
                                  snapshot.data.documents[index].data['count'];
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text('Edytuj'),
                                          content: new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Nazwa',
                                                  ),
                                                  controller: nameController,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 24.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          count.toString(),
                                                          style: TextStyle(
                                                              fontSize: 24.0),
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        Text('na'),
                                                        SizedBox(width: 8.0),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                          child: TextField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              WhitelistingTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: 'Cel',
                                                            ),
                                                            controller:
                                                                targetController,
                                                          ),
                                                        ),
                                                        FlatButton(
                                                            child: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              setState(() {
                                                                count++;
                                                              });
                                                              () async {
                                                                if (await _isEventAuthor(
                                                                    eventDoc))
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          'events')
                                                                      .document(
                                                                          eventDoc
                                                                              .documentID)
                                                                      .collection(
                                                                          'things')
                                                                      .document(snapshot
                                                                          .data
                                                                          .documents[
                                                                              index]
                                                                          .documentID)
                                                                      .delete();
                                                              }();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                            mainAxisSize: MainAxisSize.min,
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                                child: Text('Dodaj'),
                                                onPressed: () {
                                                  setState(() {
                                                    count++;
                                                  });
                                                  () async {
                                                    if (await _isEventAuthor(
                                                        eventDoc))
                                                      Firestore.instance
                                                          .collection('events')
                                                          .document(eventDoc
                                                              .documentID)
                                                          .collection('things')
                                                          .document(snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID)
                                                          .updateData(
                                                              {'count': count});
                                                  }();
                                                }),
                                            FlatButton(
                                                child: Text('Odejmij'),
                                                onPressed: () {
                                                  if (count == 0) return;
                                                  setState(() {
                                                    count--;
                                                  });
                                                  () async {
                                                    if (await _isEventAuthor(
                                                        eventDoc))
                                                      Firestore.instance
                                                          .collection('events')
                                                          .document(eventDoc
                                                              .documentID)
                                                          .collection('things')
                                                          .document(snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID)
                                                          .updateData(
                                                              {'count': count});
                                                  }();
                                                }),
                                            FlatButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  () async {
                                                    if (await _isEventAuthor(
                                                        eventDoc))
                                                      Firestore.instance
                                                          .collection('events')
                                                          .document(eventDoc
                                                              .documentID)
                                                          .collection('things')
                                                          .document(snapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID)
                                                          .updateData({
                                                        'name':
                                                            nameController.text,
                                                        'count': count,
                                                        'target': int.parse(
                                                            targetController
                                                                .text)
                                                      });
                                                  }();
                                                  Navigator.of(context).pop();
                                                }),
                                          ],
                                        );
                                      },
                                    );
                                  });
                            };
                            open();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 20,
                                    child: Text((index + 1).toString()),
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Text(
                                    snapshot.data.documents[index].data['name'],
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontStyle: FontStyle.italic,
                                        decoration: snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['count'] >=
                                                snapshot.data.documents[index]
                                                    .data['target']
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none),
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Zebrano: ${snapshot.data.documents[index].data['count']} / ${snapshot.data.documents[index].data['target']}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          decoration: snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['count'] >=
                                                  snapshot.data.documents[index]
                                                      .data['target']
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            () async {
                              if (await _isEventAuthor(eventDoc))
                                Firestore.instance
                                    .collection('events')
                                    .document(eventDoc.documentID)
                                    .collection('things')
                                    .add({
                                  'count': 0,
                                  'target': 1,
                                  'name': 'Nowy przedmiot'
                                });
                            }();
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 20,
                                  child: Text('N'),
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Text(
                                  'Dodaj nowy',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            )),
          );
        });
  }
}
