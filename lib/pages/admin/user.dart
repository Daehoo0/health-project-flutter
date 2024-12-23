import 'package:flutter/material.dart';

class DeleteUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hapus User'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: 5, // Ganti dengan jumlah user dari database
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('User ${index + 1}'),
              subtitle: Text('Email: user${index + 1}@example.com'),
              trailing: IconButton(
                onPressed: () {
                  // Logika hapus user
                },
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
