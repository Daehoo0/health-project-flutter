import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

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

  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _genderController = TextEditingController(text: widget.userData['gender'] ?? '');
    _tinggiController = TextEditingController(text: widget.userData['height']?.toString() ?? '');
    _beratController = TextEditingController(text: widget.userData['weight']?.toString() ?? '');
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          setState(() {
            _profileImage = File(pickedFile.path); // Use the path directly for web
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path); // Use File for non-web platforms
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile').child(fileName);

      if (kIsWeb) {
        final Uint8List bytes = await image.readAsBytes(); // Baca file sebagai bytes
        UploadTask uploadTask = ref.putData(bytes);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        print('Image uploaded successfully: $downloadURL'); // Logging
        return downloadURL;
      } else {
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        print('Image uploaded successfully: $downloadURL'); // Logging
        return downloadURL;
      }
    } catch (e) {
      print('Error uploading image: $e'); // Tambahkan logging error
      _showErrorSnackBar('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;

        if (_profileImage != null) {
          imageUrl = await _uploadImage(_profileImage!);
          if (imageUrl == null) {
            print('Failed to upload image.');
            return; // Jangan lanjutkan jika upload gagal
          }
        } else {
          imageUrl = widget.userData['profile'] ?? '';
        }

        final updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'gender': _genderController.text.trim(),
          'height': double.tryParse(_tinggiController.text) ?? 0.0,
          'weight': double.tryParse(_beratController.text) ?? 0.0,
          'profile': imageUrl, // Simpan URL gambar
        };

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(updatedData);

          widget.updateUserData(updatedData);

          print('Profile updated successfully in Firestore: $updatedData'); // Logging
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error saving profile: $e'); // Logging error
        _showErrorSnackBar('Error saving profile: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? (kIsWeb
                    ? NetworkImage(_profileImage!.path) // For web, use the path directly
                    : FileImage(_profileImage!) as ImageProvider) // For other platforms, use FileImage
                    : (widget.userData['profile'] != null && widget.userData['profile'].isNotEmpty
                    ? NetworkImage(widget.userData['profile'])
                    : null),
                child: _profileImage == null &&
                    (widget.userData['profile'] == null || widget.userData['profile'].isEmpty)
                    ? Icon(Icons.person, color: Colors.white, size: 50)
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pilih Gambar Profil'),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Nama'),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', isEmail: true),
              SizedBox(height: 20),
              _buildTextField(_genderController, 'Gender'),
              SizedBox(height: 20),
              _buildTextField(_tinggiController, 'Tinggi Badan (cm)', isNumber: true),
              SizedBox(height: 20),
              _buildTextField(_beratController, 'Berat Badan (kg)', isNumber: true),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType:
      isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong.';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Masukkan email yang valid.';
        }
        return null;
      },
    );
  }
}
