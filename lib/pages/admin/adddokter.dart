import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddDoctorPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  String _startHour = "00";
  String _startMinute = "00";
  String _endHour = "00";
  String _endMinute = "00";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Dokter'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              SizedBox(height: 16),
              Text(
                'Hari',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _dayController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan hari jadwal (contoh: Senin)',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Jam Mulai',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startHour,
                      items: List.generate(24, (index) {
                        final value = index.toString().padLeft(2, '0');
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          _startHour = value;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Jam',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startMinute,
                      items: List.generate(60, (index) {
                        final value = index.toString().padLeft(2, '0');
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          _startMinute = value;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Menit',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Jam Selesai',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endHour,
                      items: List.generate(24, (index) {
                        final value = index.toString().padLeft(2, '0');
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          _endHour = value;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Jam',
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endMinute,
                      items: List.generate(60, (index) {
                        final value = index.toString().padLeft(2, '0');
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          _endMinute = value;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Menit',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Logika untuk menyimpan data dokter
                    final String name = _nameController.text;
                    final String specialization = _specializationController.text;
                    final String day = _dayController.text;
                    final String startTime = "$_startHour : $_startMinute";
                    final String endTime = "$_endHour : $_endMinute";

                    if (name.isNotEmpty &&
                        specialization.isNotEmpty &&
                        day.isNotEmpty &&
                        startTime.isNotEmpty &&
                        endTime.isNotEmpty) {
                      try {
                        // Referensi ke Firebase Database
                        final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('jadwal');

                        // Simpan data ke Firebase
                        await databaseRef.push().set({
                          'nama': name,
                          'spesisalis': specialization,
                          'hari': day,
                          'jam_mulai': startTime,
                          'jam_selesai': endTime,
                        });

                        // Kembali ke halaman sebelumnya
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Jadwal Dokter berhasil ditambahkan')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Terjadi kesalahan: $e')),
                        );
                      }
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
      ),
    );
  }
}