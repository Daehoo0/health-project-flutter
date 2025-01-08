import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) updateUserData;

  UpdateProfilePage({required this.userData, required this.updateUserData});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _tinggiController;
  late TextEditingController _beratController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _genderController = TextEditingController(text: widget.userData['gender']);
    _tinggiController = TextEditingController(text: widget.userData['height'].toString());
    _beratController = TextEditingController(text: widget.userData['weight'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _tinggiController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final updatedData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'gender': _genderController.text,
      'height': double.tryParse(_tinggiController.text) ?? 0.0,
      'weight': double.tryParse(_beratController.text) ?? 0.0,
    };

    try {
      // Cari dokumen berdasarkan email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Dapatkan ID dokumen pengguna
        String docId = querySnapshot.docs.first.id;

        // Update data pengguna
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update(updatedData);

        // Update data lokal
        widget.updateUserData(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna dengan email tersebut tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Edit Profil'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _tinggiController,
              decoration: InputDecoration(
                labelText: 'Tinggi Badan',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _beratController,
              decoration: InputDecoration(
                labelText: 'Berat Badan',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
