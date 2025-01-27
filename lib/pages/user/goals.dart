import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Goals extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Goals({super.key, required this.userData});

  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  String? _selectedGoal;
  String _resultMakanan = '';
  String _resultOlahraga = '';
  bool _isLoading = false;
  bool _isSavingMakanan = false;
  bool _isSavingOlahraga = false;
  int? _age;

  final List<String> _goals = [
    'Menurunkan Berat Badan',
    'Menaikkan Berat Badan',
    'Menaikkan Massa Otot',
  ];

  Future<void> _fetchSuggestions() async {
    if (_selectedGoal == null) {
      setState(() {
        _resultMakanan = 'Pilih tujuan terlebih dahulu.';
        _resultOlahraga = 'Pilih tujuan terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Gemini client = Gemini.instance;

      // Prompt untuk Makanan
      final promptMakanan =
          "Carikan menu makanan yang cocok dan kebutuhan kalori sesuai tujuan $_selectedGoal. Orang ini memiliki tinggi badan ${widget.userData['height']} cm, berat badan ${widget.userData['weight']} kg, dan usia $_age tahun.";

      final responseMakanan = await client.text(promptMakanan);

      // Prompt untuk Olahraga
      final promptOlahraga =
          "Carikan jenis olahraga yang cocok sesuai tujuan $_selectedGoal dan berikan jumlah set dan repetisi yang direkomendasikan. Orang ini memiliki tinggi badan ${widget.userData['height']} cm, berat badan ${widget.userData['weight']} kg, dan usia $_age tahun.";

      final responseOlahraga = await client.text(promptOlahraga);

      setState(() {
        _resultMakanan = responseMakanan?.output ?? 'Tidak ada rekomendasi makanan yang ditemukan.';
        _resultOlahraga = responseOlahraga?.output ?? 'Tidak ada jadwal olahraga yang ditemukan.';
      });
    } catch (e) {
      setState(() {
        _resultMakanan = 'Gagal mendapatkan rekomendasi makanan: ${e.toString()}';
        _resultOlahraga = 'Gagal mendapatkan jadwal olahraga: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirestore(String fieldName, bool isSavingMakanan) async {
    if (isSavingMakanan ? _resultMakanan.isEmpty : _resultOlahraga.isEmpty) return;

    setState(() {
      if (isSavingMakanan) {
        _isSavingMakanan = true;
      } else {
        _isSavingOlahraga = true;
      }
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = context.read<DataLogin>().uiduser;

      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        await firestore.collection('users').doc(uid).update({
          if (isSavingMakanan) 'listmakanan': _resultMakanan,
          if (!isSavingMakanan) 'listjadwalolahraga': _resultOlahraga,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fieldName berhasil disimpan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dokumen pengguna tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        if (isSavingMakanan) {
          _isSavingMakanan = false;
        } else {
          _isSavingOlahraga = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih tujuan Anda:',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: DropdownButton<String>(
                  value: _selectedGoal,
                  isExpanded: true,
                  hint: const Text('Pilih Tujuan'),
                  items: _goals.map((String goal) {
                    return DropdownMenuItem<String>(
                      value: goal,
                      child: Text(goal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoal = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Masukkan Usia (tahun)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _age = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchSuggestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Generate',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              if (_resultMakanan.isNotEmpty || _resultOlahraga.isNotEmpty)
                Column(
                  children: [
                    if (_resultMakanan.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _resultMakanan,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    if (_resultOlahraga.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _resultOlahraga,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isSavingMakanan
                          ? null
                          : () => _saveToFirestore('listmakanan', true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: _isSavingMakanan
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Menu Makanan'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isSavingOlahraga
                          ? null
                          : () => _saveToFirestore('listjadwalolahraga', false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: _isSavingOlahraga
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Jadwal Olahraga'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
