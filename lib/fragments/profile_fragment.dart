import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        children: <Widget>[_buildOrganizationsWidget()],
      ),
    );
  }

  _buildOrganizationsWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
        StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('organizations').snapshots(),
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
                        var organization = query.data.documents[index];
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
                                  organization['name'],
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(),
                                Text(
                                  '${organization['description']}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Divider(),
                                Text(
                                  'Kontakt: ${organization['contact']}',
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
                                              organization['name'];
                                          descriptionController.text =
                                              organization['description'];
                                          contactController.text =
                                              organization['contact'];
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
                                                        Firestore.instance.collection('organizations').document(organization.documentID).updateData({
                                                          'name': nameController.text,
                                                          'contact': contactController.text,
                                                          'description': descriptionController.text
                                                        });
                                                        Navigator.of(context).pop();
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
                                                                'organizations')
                                                            .document(
                                                                organization
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
