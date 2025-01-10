import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _specializationController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  File? _image;
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Memuat data awal dari Firestore
  Future<void> _loadProfileData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('dokter').doc(user.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _specializationController.text = data['specialization'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? user.email!;
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['profileImageUrl'] ?? '';
        });
      }
    }
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child("dokter_images/$fileName");
      UploadTask uploadTask = ref.putFile(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  // Fungsi untuk memperbarui data profil di Firestore
  Future<void> _saveProfileData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Perbarui email pengguna jika diubah
        if (_emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
          await user.sendEmailVerification();
        }

        // Simpan data ke Firestore
        await _firestore.collection('dokter').doc(user.uid).update({
          'name': _nameController.text,
          'specialization': _specializationController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'profileImageUrl': _profileImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil Dokter'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                backgroundImage: _image == null
                    ? (_profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null)
                    : FileImage(_image!) as ImageProvider,
                child: _image == null && _profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Dokter'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _specializationController,
              decoration: InputDecoration(labelText: 'Spesialisasi'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Baru'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfileData,
              child: Text('Simpan Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
