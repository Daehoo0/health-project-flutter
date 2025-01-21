import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TambahArtikelPage extends StatelessWidget {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _gambarController = TextEditingController();  // Controller untuk URL gambar
  final TextEditingController _isiartikelController = TextEditingController();
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
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Deskripsi Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),

            // Input untuk URL Gambar
            TextField(
              controller: _gambarController,
              decoration: InputDecoration(
                labelText: 'URL Gambar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _isiartikelController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Isi Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.abc),
              ),
            ),
            SizedBox(height: 16),
            // Preview gambar jika URL valid
            if (_gambarController.text.isNotEmpty) ...[
              Image.network(
                _gambarController.text,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
            ],
            // Tombol untuk menyimpan artikel ke Firebase
            ElevatedButton(
              onPressed: () async {
                String judul = _judulController.text;
                String deskripsi = _deskripsiController.text;
                String gambarUrl = _gambarController.text;
                String isiartikel = _isiartikelController.text;

                // Validasi input
                if (judul.isNotEmpty && deskripsi.isNotEmpty && gambarUrl.isNotEmpty && isiartikel.isNotEmpty) {
                  try {
                    // Menambahkan artikel ke Firestore
                    await artikelCollection.add({
                      'judul': judul,
                      'deskripsi': deskripsi,
                      'gambar_url': gambarUrl,  // Menyimpan URL gambar jika ada
                      'isi': isiartikel,
                      'source':'personal',
                      'created_at': FieldValue.serverTimestamp(),
                    });

                    // Tampilkan snackbar sukses dan kembali ke halaman utama
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Artikel berhasil ditambahkan')),
                    );

                    Navigator.pop(context); // Kembali ke halaman CRUD Artikel
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
