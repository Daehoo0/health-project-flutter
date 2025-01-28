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

      final promptMakanan =
          "Carikan menu makanan yang cocok dan kebutuhan kalori sesuai tujuan $_selectedGoal. Orang ini memiliki tinggi badan ${widget.userData['height']} cm, berat badan ${widget.userData['weight']} kg, dan usia $_age tahun.";

      final responseMakanan = await client.text(promptMakanan);

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
          SnackBar(
            content: Text('$fieldName berhasil disimpan!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dokumen pengguna tidak ditemukan.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          'Program Kesehatan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Stats Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.height,
                              '${widget.userData['height']} cm',
                              'Tinggi',
                            ),
                            _buildStatItem(
                              Icons.fitness_center,
                              '${widget.userData['weight']} kg',
                              'Berat',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih tujuan Anda:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGoal,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Pilih Tujuan'),
                      ),
                      items: _goals.map((String goal) {
                        return DropdownMenuItem<String>(
                          value: goal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(goal),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGoal = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Masukkan Usia (tahun)',
                    labelStyle: const TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _age = int.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fetchSuggestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Generate Program',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_resultMakanan.isNotEmpty || _resultOlahraga.isNotEmpty)
                  Column(
                    children: [
                      if (_resultMakanan.isNotEmpty)
                        _buildResultCard(
                          'Rekomendasi Menu Makanan',
                          _resultMakanan,
                          Icons.restaurant_menu,
                          Colors.orange,
                        ),
                      const SizedBox(height: 16),
                      if (_resultOlahraga.isNotEmpty)
                        _buildResultCard(
                          'Program Olahraga',
                          _resultOlahraga,
                          Icons.fitness_center,
                          Colors.blue,
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSavingMakanan
                                  ? null
                                  : () => _saveToFirestore('Menu Makanan', true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isSavingMakanan
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.save),
                              label: const Text('Simpan Menu'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSavingOlahraga
                                  ? null
                                  : () => _saveToFirestore('Program Olahraga', false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isSavingOlahraga
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.save),
                              label: const Text('Simpan Program'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.teal, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );