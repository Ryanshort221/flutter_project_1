import 'package:flutter/material.dart';
import 'package:flutter_project_1/pages/todos.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO List',
      home: const MyTodos(),
      routes: {
        '/todos': (context) => const MyTodos(),
      },
    );
  }
}