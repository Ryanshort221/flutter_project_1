import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project_1/model/user.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // user has username, password, email, and isApproved
  List<User> users = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // have the home icon that pushes /home into 
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}