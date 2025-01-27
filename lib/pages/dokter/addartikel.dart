import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TambahArtikelPage extends StatefulWidget {
  @override
  _TambahArtikelPageState createState() => _TambahArtikelPageState();
}

class _TambahArtikelPageState extends State<TambahArtikelPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _thumbnailUrlController = TextEditingController(); // Controller untuk Thumbnail URL

  // Referensi ke koleksi Firestore "artikel"
  final CollectionReference artikelCollection =
  FirebaseFirestore.instance.collection('artikel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Artikel'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input untuk Judul Artikel
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 16),

            // Input untuk Deskripsi Artikel
            TextField(
              controller: _deskripsiController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Deskripsi Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),

            // Input untuk Thumbnail URL
            TextField(
              controller: _thumbnailUrlController,
              decoration: InputDecoration(
                labelText: 'Thumbnail URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            SizedBox(height: 16),

            // Tombol untuk menyimpan artikel ke Firestore
            ElevatedButton(
              onPressed: () async {
                String judul = _judulController.text;
                String deskripsi = _deskripsiController.text;
                String thumbnailUrl = _thumbnailUrlController.text;

                // Validasi input
                if (judul.isNotEmpty &&
                    deskripsi.isNotEmpty &&
                    thumbnailUrl.isNotEmpty) {
                  try {
                    // Menambahkan artikel ke Firestore
                    await artikelCollection.add({
                      'judul': judul,
                      'deskripsi': deskripsi,
                      'thumbnail_url': thumbnailUrl, // Tambahkan Thumbnail URL
                      'source': 'personal',
                      'created_at': FieldValue.serverTimestamp(),
                    });

                    // Tampilkan snackbar sukses dan kembali ke halaman utama
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Artikel berhasil ditambahkan')),
                    );

                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  } catch (e) {
                    // Jika ada error, tampilkan pesan error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan artikel')),
                    );
                  }
                } else {
                  // Tampilkan pesan jika input kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap isi semua field')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Simpan Artikel',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
