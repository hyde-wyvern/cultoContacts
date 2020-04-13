import 'dart:async';
import 'dart:ui';

import 'package:contacts_app/UI/Model/ContactsModel.dart';
import 'package:contacts_app/UI/contact/ContactEditPage.dart';
import 'package:contacts_app/data/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class ContactTile extends StatelessWidget {
  const ContactTile({
    Key key,
    @required this.contactIndex,
  }) : super(key: key);

  final int contactIndex;

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<ContactsModel>(context);
    final displayedContact = model.contacts[contactIndex];
    return Slidable(
      actionPane: SlidableBehindActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Call',
          color: Colors.green,
          icon: Icons.phone,
          onTap: () => _callPhoneNumber(context, displayedContact.phoneNumber),
        ),
        IconSlideAction(
          caption: 'Email',
          color: Colors.blue,
          icon: Icons.mail,
          onTap: () => _writeEmail(context, displayedContact.email),
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            model.deleteContact(displayedContact);
          },
        )
      ],
      child: _buildContent(context, displayedContact, model),
    );
  }

  Future _callPhoneNumber(BuildContext context, String number) async {
    final url = 'tel:$number';
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    } else {
      final snackbar = SnackBar(
        content: Text('Cannot make a call'),
      );
      //Showing an error message!
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  Future _writeEmail(BuildContext context, String mail) async {
    final url = 'mailto:$mail';
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    } else {
      final snackbar = SnackBar(
        content: Text('Cannot write an email'),
      );
      //Showing an error message!
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  Container _buildContent(
      BuildContext context, Contact displayedContact, ContactsModel model) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: ListTile(
          leading: _buildCircleAvatar(displayedContact),
          title: Text(displayedContact.name),
          subtitle: Text(displayedContact.email),
          trailing: IconButton(
            icon: Icon(
              displayedContact.isFavorite ? Icons.star : Icons.star_border,
              color: displayedContact.isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              model.changeFavoriteStatus(displayedContact);
            },
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ContactEditPage(
                  target: displayedContact,
                ),
              ),
            );
          }),
    );
  }

  Hero _buildCircleAvatar(Contact displayedContact) {
    return Hero(
      tag: displayedContact.hashCode,
      child: CircleAvatar(
        child: _buildCircleAvatarContent(displayedContact),
      ),
    );
  }

  Widget _buildCircleAvatarContent(Contact displayedContact) {
    if (displayedContact.imageFile == null) {
      return Text(
        displayedContact.name[0],
      );
    } else {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            displayedContact.imageFile,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}
