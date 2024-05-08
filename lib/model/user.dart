import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String _name;
  String _email;
  String _password;
  final DocumentReference reference;

  User(this.reference,
      {required String name, required String email, required String password})
      : _name = name,
        _email = email,
        _password = password;

  String get name => _name;
  set name(String value) => _name = value;

  String get email => _email;
  set email(String value) => _email = value;

  String get password => _password;
  set password(String value) => _password = value;

  User.fromMap(Map<String, dynamic> map, {required this.reference})
      : _name = map['name'],
        _email = map['email'],
        _password = map['password'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  User.fromJson(Map<String, dynamic> json, this.reference)
      : _name = json['name'],
        _email = json['email'],
        _password = json['password'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    return data;
  }
}
