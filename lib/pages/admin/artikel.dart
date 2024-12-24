import 'package:flutter/material.dart';
import 'package:health_project_flutter/pages/admin/addartikel.dart';

class ArticlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logika untuk menambah artikel
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddArtikelPage()),
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
              title: Text('Artikel ${index + 1}'),
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
