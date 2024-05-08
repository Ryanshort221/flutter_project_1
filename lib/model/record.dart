import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  String _name;
  int _votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {required this.reference})
      : _name = map['name'],
        _votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  set votes(int value) {
    _votes = value;
    reference.update(toJson());
  }

  int get votes => _votes;
  String get name => _name;

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'votes': _votes,
    };
  }
}