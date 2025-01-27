import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';

class TambahProgramPage extends StatelessWidget {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Program'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Program',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi Program',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _durasiController,
              decoration: InputDecoration(
                labelText: 'Durasi Program (hari)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _hargaController,
              decoration: InputDecoration(
                labelText: 'Harga Program',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.price_change),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logika untuk menyimpan program
                String nama = _namaController.text;
                String deskripsi = _deskripsiController.text;
                String durasi = _durasiController.text;
                String harga = _hargaController.text;
                if (nama.isNotEmpty && deskripsi.isNotEmpty && durasi.isNotEmpty) {
                  // Menyimpan data ke Firestore
                  _firestore.collection('programdokter').add({
                    'nama': nama,
                    'deskripsi': deskripsi,
                    'durasi': durasi,
                    'created_at': FieldValue.serverTimestamp(),
                    'owner':context.read<DataLogin>().uiduser,
                    'harga':harga,
                  }).then((value) {
                    // Kembali ke halaman sebelumnya setelah berhasil menyimpan
                    Navigator.pop(context);
                  }).catchError((error) {
                    // Menampilkan pesan error jika gagal menyimpan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan data: $error')),
                    );
                  });
                } else {
                  // Tampilkan pesan error jika input kosong
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
                'Simpan Program',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
