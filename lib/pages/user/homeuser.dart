import 'package:flutter/material.dart';

class HomeUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home User'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          'Selamat datang, User!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}