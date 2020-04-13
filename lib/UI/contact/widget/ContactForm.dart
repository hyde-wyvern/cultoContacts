import 'package:contacts_app/UI/Model/ContactsModel.dart';
import 'package:contacts_app/data/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io';

class ContactForm extends StatefulWidget {
  final Contact target;

  ContactForm({
    Key key,
    this.target,
  }) : super(key: key);

  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  String _email;
  String _phoneNumber;
  File _contactImageFile;

  bool get isEditMode => widget.target != null;
  bool get hasSelectedCustomImage => _contactImageFile != null;

  @override
  void initState() {
    super.initState();
    _contactImageFile = widget.target?.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          SizedBox(height: 10),
          _buildContactPicture(),
          SizedBox(height: 10),
          TextFormField(
            onSaved: (value) => _name = value,
            validator: _validateName,
            initialValue: widget.target?.name,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            validator: _validateEmail,
            initialValue: widget.target?.email,
            onSaved: (value) => _email = value,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: widget.target?.phoneNumber,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            onSaved: (value) => _phoneNumber = value,
          ),
          RaisedButton(
            onPressed: _onSavedContactButtonPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('SAVE CONTACT '),
                Icon(
                  Icons.person,
                  size: 18,
                )
              ],
            ),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildContactPicture() {
    final halfScreenDiameter = MediaQuery.of(context).size.width / 4;
    return Hero(
      tag: widget.target?.hashCode ?? 0,
      child: GestureDetector(
        onTap: _onContactPictureTap,
        child: CircleAvatar(
          radius: halfScreenDiameter,
          child: _buildAvatarContent(halfScreenDiameter),
        ),
      ),
    );
  }

  void _onContactPictureTap() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _contactImageFile = imageFile;
    });
  }

  Widget _buildAvatarContent(double halfScreenDiameter) {
    if (isEditMode || hasSelectedCustomImage) {
      return _buildEditModeCircleAvatar(halfScreenDiameter);
    } else {
      return Icon(
        Icons.person,
        size: halfScreenDiameter,
      );
    }
  }

  Widget _buildEditModeCircleAvatar(double halfScreenDiameter) {
    if (_contactImageFile == null) {
      return Text(
        widget.target.name[0],
        style: TextStyle(fontSize: halfScreenDiameter),
      );
    } else {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.file(
            _contactImageFile,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  String _validateName(String value) {
    if (value.isEmpty) {
      return 'Enter Name';
    }
    return null;
  }

  String _validateEmail(String value) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zAZ0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (value.isEmpty) {
      return 'Enter an E-mail';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
    if (value.isEmpty) {
      return 'Enter a Phone Number';
    } else if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _onSavedContactButtonPressed() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final newOrEditedContact = Contact(
        name: _name,
        email: _email,
        phoneNumber: _phoneNumber,
        //Elvis validator (?.) returns null if the referenced value doesn't exist
        //Null coalescing operator (??) used with elvis returns the specified value instead of null when the condition is not met.
        isFavorite: widget.target?.isFavorite ?? false,
        imageFile: _contactImageFile,
      );
      if (isEditMode) {
        newOrEditedContact.id = widget.target.id;
        ScopedModel.of<ContactsModel>(context)
            .updateContact(newOrEditedContact);
      } else {
        ScopedModel.of<ContactsModel>(context).addContact(newOrEditedContact);
      }
      Navigator.of(context).pop();
    }
  }
}
