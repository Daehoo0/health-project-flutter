import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/dokter/addprogram.dart';

class ProgramPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Program'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Tambah Program
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahProgramPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 5, // Jumlah program
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Program ${index + 1}'),
              subtitle: Text('Deskripsi singkat program ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Logika edit program
                    },
                    icon: Icon(Icons.edit, color: Colors.orange),
                  ),
                  IconButton(
                    onPressed: () {
                      // Logika hapus program
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
