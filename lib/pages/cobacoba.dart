import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Top Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: cobaini(),
    );
  }
}
class cobaini extends StatelessWidget {
  const cobaini({super.key});
  Future<void> saveData() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final firestore = FirebaseFirestore.instance;
    // Instance Firestore
    try {
      // 1. Ambil data dari dokumen
      final document = await firestore.collection('users').doc("8gckLYOPL6h50jkJSed5k0sc4qE2").get();

      if (document.exists) {
        // Ambil data saat ini dari field 'list_program'
        Map<String, dynamic> currentData = document.data()!;
        List<dynamic> currentList = currentData['list_program'] ?? [];
        // 2. Tambahkan data baru ke list_program
        Map<String, dynamic> newProgram = {
          'id': 'YyYsvl9bOB7pFzmC3JOb',
          'nama': "Program Mata",
          'deskripsi':"ini deskripsi",
          'tanggal_beli':DateTime.now(),
          'tanggal_selesai': DateTime.now(),
          'harga': true,
          'report':[
            {
              "untuk_tanggal":DateTime.now(),
              'isi_makanan':[
                {
                  "nama":'nasi goreng',
                  "done":false,
                },
                {
                  "nama":'cakue',
                  "done":false,
                },
              ],
              'isi_olahraga':[
                {
                  "nama":'lari santai',
                  "done":false,
                },
                {
                  "nama":'jalan santai',
                  "done":false,
                },
              ]
            },
            {
              "untuk_tanggal":DateTime.now(),
              'isi_makanan':[
                {
                  "nama":'nasi kuning',
                  "done":false,
                },
                {
                  "nama":'bebek goreng',
                  "done":false,
                },
              ],
              'isi_olahraga':[
                {
                  "nama":'lari berat',
                  "done":false,
                },
                {
                  "nama":'jalan berat',
                  "done":false,
                },
              ]
            },
          ],
          'owner':true
        };

        currentList.add(newProgram);

        // 3. Update data ke Firestore
        await firestore.collection('users').doc("8gckLYOPL6h50jkJSed5k0sc4qE2").update({
          'list_program': currentList,
        });

        debugPrint("Data berhasil diperbarui!");
      } else {
        debugPrint("Dokumen tidak ditemukan!");
      }
    } catch (e) {
      debugPrint("Terjadi kesalahan: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: saveData,
        child: const Text("Save Data to Firebase"),
      ),
    );
  }
}
class ProgramCekMataScreen extends StatefulWidget {
  const ProgramCekMataScreen({super.key});

  @override
  State<ProgramCekMataScreen> createState() => _ProgramCekMataScreenState();
}

class _ProgramCekMataScreenState extends State<ProgramCekMataScreen> {
  // Data array untuk checkbox
  final List<Map<String, dynamic>> _programList = [
    {'name': 'Program 1', 'isChecked': true},
    {'name': 'Program 2', 'isChecked': false},
    {'name': 'Program 3', 'isChecked': true},
    {'name': 'Program 4', 'isChecked': false},
    {'name': 'Program 5', 'isChecked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Cek Mata'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Program Cek Mata',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi: Program ini membantu Anda untuk memeriksa kesehatan mata melalui berbagai opsi program yang tersedia.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'List Program',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _programList.map((program) {
                    return CheckboxListTile(
                      title: Text(program['name']),
                      value: program['isChecked'],
                      onChanged: (bool? value) {
                        setState(() {
                          program['isChecked'] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}