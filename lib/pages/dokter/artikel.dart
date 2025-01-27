import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtikelDokterPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('artikel').get();
      List<Map<String, dynamic>> data = [];
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        docData['id'] = doc.id; // Tambahkan ID dokumen ke data
        data.add(docData);
      });
      return data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Artikel Kesehatan'),
              backgroundColor: Colors.teal,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Navigasi ke halaman untuk menambah artikel
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TambahArtikelPage()),
                );
              },
              backgroundColor: Colors.teal,
              child: Icon(Icons.add),
            ),
            body: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    snapshot.data![index]["thumbnail_url"] ?? 'https://via.placeholder.com/150',
                    width: 100,
                    height: 100,
                  ),
                  title: Text(snapshot.data![index]['judul'] ?? 'No title'),
                  subtitle: Text(snapshot.data![index]['deskripsi'] ?? 'No details'),
                  onTap: () async {
                    if (snapshot.data![index]['source'] == "personal") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailArtikelDokterPage(idartikel: snapshot.data![index]["id"]),
                        ),
                      );
                    } else {
                      final url = snapshot.data![index]['url_link'];
                      if (url != null && await canLaunch(url)) {
                        await launch(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open the article')),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}

class DetailArtikelDokterPage extends StatelessWidget {
  final String idartikel;
  DetailArtikelDokterPage({required this.idartikel});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getArticleDetails() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('artikel').doc(idartikel).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getArticleDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available'));
        } else {
          final article = snapshot.data!;
          // Format the 'created_at' timestamp to a readable date
          String formattedDate = '';
          if (article['created_at'] is Timestamp) {
            DateTime dateTime = (article['created_at'] as Timestamp).toDate();
            formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString();
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(article['judul'] ?? 'No title'),
              backgroundColor: Colors.teal,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['thumbnail_url'] != null)
                    Image.network(
                      article['thumbnail_url'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 16),
                  Text(
                    article['judul'] ?? 'No title',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dibuat tanggal $formattedDate',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    article['deskripsi'] ?? 'No description',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class TambahArtikelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Artikel'),
        backgroundColor: Colors.teal,
      ),
      body: Center(child: Text('Halaman Tambah Artikel')), // Placeholder untuk halaman tambah artikel
    );
  }
}