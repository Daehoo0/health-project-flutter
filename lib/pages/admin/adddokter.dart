import 'package:flutter/material.dart';

class AddDoctorPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Dokter'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Dokter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama dokter',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Spesialisasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _specializationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan spesialisasi dokter',
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logika untuk menyimpan data dokter
                  final String name = _nameController.text;
                  final String specialization = _specializationController.text;

                  if (name.isNotEmpty && specialization.isNotEmpty) {
                    // Simpan data ke database atau state management
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dokter berhasil ditambahkan')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Semua field harus diisi')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
