import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'addartikel.dart'; // Halaman untuk menambah artikel

class ArtikelPage extends StatefulWidget {
  @override
  _ArtikelPageState createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  // Referensi ke koleksi "artikel" di Firestore
  final CollectionReference artikelCollection =
  FirebaseFirestore.instance.collection('artikel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artikel Kesehatan'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman TambahArtikelPage untuk menambah artikel
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahArtikelPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: artikelCollection.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan!'));
          }

          final articles = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              var article = articles[index];
              String? gambarUrl = article['gambar_url'];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(article['judul']),
                  subtitle: Text(article['deskripsi']),
                  leading: gambarUrl != null && gambarUrl.isNotEmpty
                      ? Image.network(gambarUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : null, // Menampilkan gambar thumbnail jika ada
                ),
              );
            },
          );
        },
      ),
    );
  }
}
