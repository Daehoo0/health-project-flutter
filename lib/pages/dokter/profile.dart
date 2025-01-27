import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _specializationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  File? _profileImage; // For storing the profile image

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from Firestore
  Future<void> _loadProfileData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _specializationController.text = data['specialization'] ?? '';
          _emailController.text = data['email'] ?? user.email!;
        });
      }
    }
  }

  // Save profile data
  Future<void> _saveProfileData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        if (_emailController.text != user.email) {
          await user.updateEmail(_emailController.text);
          await user.sendEmailVerification();
        }

        // Save the profile to Firestore in "doctors" collection
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'specialization': _specializationController.text,
          'email': _emailController.text,
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

  // Function to pick profile image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadProfileImage(pickedFile); // Upload to Firebase
    }
  }

  // Upload the image to Firebase Storage
  Future<void> _uploadProfileImage(XFile pickedFile) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String fileName = '${user.uid}_profile.jpg';
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

        await storageRef.putFile(File(pickedFile.path));
        String downloadUrl = await storageRef.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profile': downloadUrl,
        });

        setState(() {
          _profileImage = File(pickedFile.path); // Update the local profile image
        });
      } catch (e) {
        print("Error uploading profile image: $e");
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
            // Profile Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) // If image exists, use it
                    : AssetImage('lib/assets/profile.jpg') as ImageProvider,
                backgroundColor: Colors.teal[100],
              ),
            ),
            SizedBox(height: 20),
            // Name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama', hintText: _nameController.text),
            ),
            SizedBox(height: 10),
            // Specialization input
            TextField(
              controller: _specializationController,
              decoration: InputDecoration(labelText: 'Spesialisasi', hintText: _specializationController.text),
            ),
            SizedBox(height: 10),
            // Email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Baru', hintText: _emailController.text),
            ),
            SizedBox(height: 20),
            // Save Button
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
