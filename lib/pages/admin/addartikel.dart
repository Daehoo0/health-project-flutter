import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddArtikelPage extends StatelessWidget {
  final TextEditingController _judulController;
  final TextEditingController _thumbnailController;
  final TextEditingController _urlLinkController;
  final TextEditingController _deskripsiController;
  final String? documentId;

  AddArtikelPage({
    Key? key,
    String? judul,
    String? thumbnailUrl,
    String? urlLink,
    String? deskripsi,
    this.documentId,
  })  : _judulController = TextEditingController(text: judul),
        _thumbnailController = TextEditingController(text: thumbnailUrl),
        _urlLinkController = TextEditingController(text: urlLink),
        _deskripsiController = TextEditingController(text: deskripsi),
        super(key: key);

  final CollectionReference artikelCollection =
  FirebaseFirestore.instance.collection('artikel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documentId == null ? 'Tambah Artikel' : 'Edit Artikel'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _thumbnailController,
              decoration: InputDecoration(
                labelText: 'URL Thumbnail Gambar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _urlLinkController,
              decoration: InputDecoration(
                labelText: 'URL Link Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi Artikel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String judul = _judulController.text;
                String thumbnailUrl = _thumbnailController.text;
                String urlLink = _urlLinkController.text;
                String deskripsi = _deskripsiController.text;

                if (judul.isNotEmpty && thumbnailUrl.isNotEmpty && urlLink.isNotEmpty && deskripsi.isNotEmpty) {
                  try {
                    if (documentId == null) {
                      await artikelCollection.add({
                        'judul': judul,
                        'thumbnail_url': thumbnailUrl,
                        'url_link': urlLink,
                        'deskripsi': deskripsi,
                        'source': 'web',
                        'created_at': FieldValue.serverTimestamp(),
                      });
                    } else {
                      await artikelCollection.doc(documentId).update({
                        'judul': judul,
                        'thumbnail_url': thumbnailUrl,
                        'url_link': urlLink,
                        'deskripsi': deskripsi,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(documentId == null ? 'Artikel berhasil ditambahkan' : 'Artikel berhasil diperbarui')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan artikel')),
                    );
                  }
                } else {
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
                documentId == null ? 'Simpan Artikel' : 'Perbarui Artikel',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}