import 'package:flutter/material.dart';
import 'package:flutter_project_1/pages/my_home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TODO List',
      home: MyHomePage(),
    );
  }
}
