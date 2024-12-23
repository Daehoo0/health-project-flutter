import 'package:flutter/material.dart';
import 'package:kesehatan/pages/dokter/addartikel.dart';

class ArtikelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Artikel'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Tambah Artikel
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahArtikelPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: 5, // Ganti dengan jumlah artikel dari database
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Judul Artikel ${index + 1}'),
              subtitle: Text('Deskripsi singkat artikel ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Logika edit artikel
                    },
                    icon: Icon(Icons.edit, color: Colors.orange),
                  ),
                  IconButton(
                    onPressed: () {
                      // Logika hapus artikel
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
