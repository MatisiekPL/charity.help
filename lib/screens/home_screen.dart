import 'package:charity_help/fragments/home_fragment.dart';
import 'package:charity_help/fragments/profile_fragment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:geocoder/geocoder.dart';

import '../store.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _title = 'Zbiórki';
  List<Widget> _appBarActions = [];

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();

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
      if (index == 0) {
        _title = 'Zbiórki';
        _appBarActions = [
          PopupMenuButton<String>(
            onSelected: (choice) {
              switch (choice) {
                case 'add':
                  showDialog(
                      context: context,
                      builder: (context) {
                        dynamic setActionsState;
                        nameController
                            .addListener(() => setActionsState(() {}));
                        descriptionController
                            .addListener(() => setActionsState(() {}));
                        addressController
                            .addListener(() => setActionsState(() {}));
                        var selectedOrganisation;
                        return AlertDialog(
                          title: Text('Nowa zbiórka'),
                          content: StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance
                                  .collection('organisations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || snapshot.data == null)
                                  return CircularProgressIndicator();
                                List items = snapshot.data.documents.map((el) {
                                  return DropdownMenuItem<dynamic>(
                                    value: el.documentID,
                                    child: Text(el.data['name']),
                                  );
                                }).toList();
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      decoration:
                                          InputDecoration(labelText: 'Nazwa'),
                                      controller: nameController,
                                      autofocus: false,
                                    ),
                                    TextField(
                                      decoration:
                                          InputDecoration(labelText: 'Opis'),
                                      controller: descriptionController,
                                      autofocus: false,
                                    ),
                                    TextField(
                                      decoration:
                                          InputDecoration(labelText: 'Adres'),
                                      controller: addressController,
                                      autofocus: false,
                                    ),
                                    StatefulBuilder(
                                      builder: (context, setDropdownState) =>
                                          DropdownButton<dynamic>(
                                        isExpanded: true,
                                        items: items,
                                        hint: Text('Organizacja'),
                                        value: selectedOrganisation == null
                                            ? null
                                            : selectedOrganisation.documentID,
                                        onChanged: (selection) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          setDropdownState(() {
                                            selectedOrganisation = snapshot
                                                .data.documents
                                                .where((el) =>
                                                    el.documentID == selection)
                                                .first;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Anuluj'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            StatefulBuilder(builder: (context, setState) {
                              setActionsState = setState;
                              return FlatButton(
                                child: Text('Zapisz'),
                                onPressed: (nameController.text.isEmpty ||
                                        descriptionController.text.isEmpty ||
                                        addressController.text.isEmpty ||
                                        selectedOrganisation != null)
                                    ? null
                                    : () {
                                        () async {
                                          try {
                                            var coordinatesList = await Geocoder
                                                .local
                                                .findAddressesFromQuery(
                                                    addressController.text);
                                            var loc = GeoPoint(
                                                coordinatesList
                                                    .first.coordinates.latitude,
                                                coordinatesList.first
                                                    .coordinates.longitude);
                                            await Firestore.instance
                                                .collection('events')
                                                .add({
                                              'name': nameController.text,
                                              'description':
                                                  descriptionController.text,
                                              'location': loc,
                                              'address': addressController.text,
                                              'author': Firestore.instance
                                                  .collection('organisations')
                                                  .document(selectedOrganisation
                                                      .documentID)
                                            });
                                            nameController.text = "";
                                            descriptionController.text = "";
                                            addressController.text = "";
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
                              );
                            })
                          ],
                        );
                      });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'add',
                  child: Text('Dodaj zbiórkę'),
                )
              ];
            },
          ),
        ];
      } else {
        _title = 'Profil';
        _appBarActions = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_title)),
        actions: _appBarActions,
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
