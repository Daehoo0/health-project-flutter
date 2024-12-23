import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Dokter'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Dokter',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Spesialis: Spesialisasi Dokter',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Divider(height: 40, thickness: 1),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.teal),
              title: Text('Nomor Telepon'),
              subtitle: Text('+62 812-3456-7890'),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.teal),
              title: Text('Email'),
              subtitle: Text('dokter@example.com'),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.teal),
              title: Text('Alamat'),
              subtitle: Text('Jl. Sehat No. 123, Kota Kesehatan'),
            ),
          ],
        ),
      ),
    );
  }
}
