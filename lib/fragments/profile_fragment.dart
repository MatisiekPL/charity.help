import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';

class ProfileFragment extends StatefulWidget {
  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _buildorganisationsWidget(),
          SizedBox(height: 16),
          ProfileCodeWidget()
        ],
      ),
    );
  }

  _buildorganisationsWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8.0,
              ),
              child: Text(
                'Organizacje',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 8.0,
              ),
              child: FlatButton(
                child: Text('Dodaj nową organizację'),
                onPressed: () {
                  Firestore.instance.collection('organisations').add({
                    'members': [
                      {'id': Store.user.uid, 'name': Store.user.displayName}
                    ],
                    'contact': 'do edycji',
                    'description': 'do edycji',
                    'name': 'do edycji',
                  });
                },
              ),
            )
          ],
        ),
        StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('organisations').snapshots(),
            builder: (context, query) {
              if (query.hasError) return new Text('Error: ${query.error}');
              switch (query.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: query.data.documents.length,
                      itemBuilder: (context, index) {
                        var organisation = query.data.documents[index];
                        return Card(
                            child: Padding(
                          padding: const EdgeInsets.only(
                            left: 12.0,
                            top: 8.0,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  organisation['name'],
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(),
                                Text(
                                  '${organisation['description']}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Divider(),
                                Text(
                                  'Kontakt: ${organisation['contact']}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child:
                                              Container(child: Text("Edytuj")),
                                        ),
                                        onTap: () {
                                          var nameController =
                                              TextEditingController();
                                          var descriptionController =
                                              TextEditingController();
                                          var contactController =
                                              TextEditingController();
                                          nameController.text =
                                              organisation['name'];
                                          descriptionController.text =
                                              organisation['description'];
                                          contactController.text =
                                              organisation['contact'];
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'Edycja organizacji'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      TextField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      'Nazwa')),
                                                      SizedBox(
                                                        height: 8.0,
                                                      ),
                                                      TextField(
                                                          controller:
                                                              descriptionController,
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      'Opis')),
                                                      SizedBox(
                                                        height: 8.0,
                                                      ),
                                                      TextField(
                                                          controller:
                                                              contactController,
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      'Kontakt')),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('Zapisz'),
                                                      onPressed: () {
                                                        Firestore.instance
                                                            .collection(
                                                                'organisations')
                                                            .document(
                                                                organisation
                                                                    .documentID)
                                                            .updateData({
                                                          'name': nameController
                                                              .text,
                                                          'contact':
                                                              contactController
                                                                  .text,
                                                          'description':
                                                              descriptionController
                                                                  .text
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text('Anuluj'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(child: Text("Usuń")),
                                        ),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Potwierdzenie'),
                                                  content: Text(
                                                      'Czy na pewno chcesz usunąć tą ogranizację?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text(
                                                        'Potwierdź',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        Firestore.instance
                                                            .collection(
                                                                'organisations')
                                                            .document(
                                                                organisation
                                                                    .documentID)
                                                            .delete();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      child: Text('Anuluj'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                              child: Text("Członkowie")),
                                        ),
                                        onTap: () {
                                          showDialog(
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Członkowie'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      StreamBuilder<
                                                              QuerySnapshot>(
                                                          stream: Firestore
                                                              .instance
                                                              .collection(
                                                                  'organisations')
                                                              .document(
                                                                  organisation
                                                                      .documentID)
                                                              .collection(
                                                                  'members')
                                                              .snapshots(),
                                                          builder:
                                                              (context, snap) {
                                                            if (!snap.hasData ||
                                                                snap.data ==
                                                                    null)
                                                              return CircularProgressIndicator();
                                                            return ListView
                                                                .builder(
                                                              shrinkWrap: true,
                                                              itemCount: snap
                                                                  .data
                                                                  .documents
                                                                  .length,
                                                              itemBuilder:
                                                                  (BuildContext
                                                                          context,
                                                                      int index) {
                                                                var member = snap
                                                                        .data
                                                                        .documents[
                                                                    index];
                                                                return Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(member.data[
                                                                            'name'] ??
                                                                        'Ładowanie'),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        () async {
                                                                          var result = await Firestore
                                                                              .instance
                                                                              .collection('organisations')
                                                                              .document(organisation.documentID)
                                                                              .collection('members')
                                                                              .where('id', isEqualTo: member.data['id'])
                                                                              .getDocuments();
                                                                          try {
                                                                            await Firestore.instance.collection('organisations').document(organisation.documentID).collection('members').document(result.documents[0].documentID).delete();
                                                                          } catch (err) {
                                                                            print(err);
                                                                          }
                                                                        }();
                                                                      },
                                                                      child: Icon(
                                                                          Icons
                                                                              .delete),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8.0),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          }),
                                                      TextField(
                                                        textInputAction:
                                                            TextInputAction.go,
                                                        maxLines: 1,
                                                        decoration: InputDecoration(
                                                            labelText:
                                                                'Kod użytkownika'),
                                                        onSubmitted: (code) {
                                                          try {
                                                            var invitation = utf8
                                                                .decode(base64
                                                                    .decode(
                                                                        code));
                                                            var id = invitation
                                                                .split('.')[0];
                                                            var name =
                                                                invitation
                                                                    .split(
                                                                        '.')[1];
                                                            Firestore.instance
                                                                .collection(
                                                                    'organisations')
                                                                .document(
                                                                    organisation
                                                                        .documentID)
                                                                .collection(
                                                                    'members')
                                                                .add({
                                                              'id': id,
                                                              'name': name
                                                            });
                                                          } catch (err) {
                                                            showDialog(
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Kod nieprawidłowy'),
                                                                    content: Text(
                                                                        'Podany kod jest nieprawidłowy'),
                                                                    actions: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'OK'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      )
                                                                    ],
                                                                  );
                                                                },
                                                                context:
                                                                    context);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('OK'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              },
                                              context: context);
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        ));
                      });
              }
            }),
      ],
    );
  }
}

class ProfileCodeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String code = base64
        .encode(utf8.encode(Store.user.uid + '.' + Store.user.displayName));
    return Column(
      children: <Widget>[
        Text(
          'Kod użytkownika: ',
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(height: 8.0),
        Row(
          children: <Widget>[
            Container(
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Icon(Icons.content_copy),
              onTap: () {
                Clipboard.setData(new ClipboardData(text: code));
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kod został skopiowany'),
                  ),
                );
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )
      ],
    );
  }
}
