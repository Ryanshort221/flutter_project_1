import 'package:flutter/material.dart';
// import 'package:flutter_project_1/pages/login.dart';
// import 'package:flutter_project_1/pages/register.dart';
// import 'package:flutter_project_1/pages/todos.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Stack(
          children: [
            // Add your background widget here
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.webp'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/todos');
                    },
                    child: const Text('My Todos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
