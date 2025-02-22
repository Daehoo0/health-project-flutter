import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';

class EditProgramPage extends StatelessWidget {
  final DocumentSnapshot program;

  EditProgramPage({required this.program});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _namaController =
    TextEditingController(text: program['nama']);
    final TextEditingController _deskripsiController =
    TextEditingController(text: program['deskripsi']);
    final TextEditingController _hargaController =
    TextEditingController(text: program['harga']);
    List<TextEditingController> makananControllers = List.generate(
      7,
          (index) => TextEditingController(
          text: program['listmakanan'][index] ?? ''),
    );
    List<TextEditingController> olahragaControllers = List.generate(
      7,
          (index) => TextEditingController(
          text: program['listolahraga'][index] ?? ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Program'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
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
              controller: _hargaController,
              decoration: InputDecoration(
                labelText: 'Harga Program',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.price_change),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Detail Program untuk 7 Hari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...List.generate(7, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hari ${index + 1}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: makananControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Menu Makanan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fastfood),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: olahragaControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Menu Olahraga',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),
            ElevatedButton(
              onPressed: () {
                // Validasi input
                String nama = _namaController.text;
                String deskripsi = _deskripsiController.text;
                String harga = _hargaController.text;

                if (nama.isNotEmpty &&
                    deskripsi.isNotEmpty &&
                    harga.isNotEmpty) {
                  // Menyiapkan data makanan dan olahraga
                  List<String> listMakanan = makananControllers
                      .map((controller) => controller.text)
                      .toList();
                  List<String> listOlahraga = olahragaControllers
                      .map((controller) => controller.text)
                      .toList();

                  // Mengupdate data di Firestore
                  _firestore.collection('programdokter').doc(program.id).update({
                    'nama': nama,
                    'deskripsi': deskripsi,
                    'harga': harga,
                    'listmakanan': listMakanan,
                    'listolahraga': listOlahraga,
                  }).then((value) {
                    // Kembali ke halaman sebelumnya setelah berhasil update
                    Navigator.pop(context);
                  }).catchError((error) {
                    // Menampilkan pesan error jika gagal update
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengupdate data: $error')),
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
                'Simpan Perubahan',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
