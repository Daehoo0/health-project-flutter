import 'package:flutter/material.dart';
import 'package:kesehatan/pages/admin/adddokter.dart';

class DoctorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dokter'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDoctorPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 5, // Ganti dengan jumlah dokter dari database
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Dokter ${index + 1}'),
              subtitle: Text('Spesialis Dokter ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Logika edit dokter
                    },
                    icon: Icon(Icons.edit, color: Colors.orange),
                  ),
                  IconButton(
                    onPressed: () {
                      // Logika hapus dokter
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
