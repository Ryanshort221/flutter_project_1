import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/model/record.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Record> records = [];

  void _vote(Record record) {
    record.votes++;
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, records[index]);
      },
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        records = [];
        for (DocumentSnapshot doc in snapshot.data!.docs) {
          records.add(Record.fromSnapshot(doc));
        }

        return _buildList(context);
      },
    );
  }

  Widget _buildListItem(BuildContext context, Record record) {
    return ListTile(
      title: Text(record.name),
      trailing: Text(record.votes.toString()),
      onTap: () => _vote(record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baby Names Votes')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    int votes = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new record'),
          content: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    name = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Votes'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    votes = int.parse(value!);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  _addRecord(name, votes);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addRecord(String name, int votes) {
    FirebaseFirestore.instance.collection('baby').doc(name).set({
      'name': name,
      'votes': votes,
    });
  }
}
