import 'package:contacts_app/UI/contact/widget/ContactForm.dart';
import 'package:contacts_app/data/contacts.dart';
import 'package:flutter/material.dart';

class ContactEditPage extends StatelessWidget {
  final Contact target;

  ContactEditPage({
    Key key,
    @required this.target,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact'),
      ),
      body: ContactForm(
        target: target,
      ),
    );
  }
}
