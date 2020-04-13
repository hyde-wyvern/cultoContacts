import 'package:contacts_app/UI/Model/ContactsModel.dart';
import 'package:contacts_app/UI/contact/ContactCreatePage.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'Widget/ContactTile.dart';

class ContactsListPage extends StatefulWidget {
  @override
  _ContactsListPageState createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
//Build function runs whenever the state changes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ScopedModelDescendant<ContactsModel>(
          builder: (context, child, model) {
        if (model.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: model.contacts.length,
            //This code runs and build every single list item
            itemBuilder: (context, index) {
              return ContactTile(
                contactIndex: index,
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ContactCreatePage()),
            );
          }),
    );
  }
}
