import 'package:flutter/material.dart';

class AddSchedulePage extends StatelessWidget {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Jadwal'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama kegiatan
            Text(
              'Nama Kegiatan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama kegiatan',
              ),
            ),
            SizedBox(height: 16),

            // Tanggal kegiatan
            Text(
              'Tanggal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan tanggal (YYYY-MM-DD)',
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  _dateController.text =
                  "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                }
              },
            ),
            SizedBox(height: 16),

            // Waktu kegiatan
            Text(
              'Waktu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan waktu (HH:MM)',
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  _timeController.text =
                  "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                }
              },
            ),
            SizedBox(height: 24),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logika untuk menyimpan data jadwal
                  final String eventName = _eventNameController.text;
                  final String date = _dateController.text;
                  final String time = _timeController.text;

                  if (eventName.isNotEmpty && date.isNotEmpty && time.isNotEmpty) {
                    // Simpan data ke database atau state management
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Jadwal berhasil ditambahkan')),
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
