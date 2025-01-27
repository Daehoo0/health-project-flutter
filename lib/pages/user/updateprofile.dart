import 'dart:typed_data'; // Untuk MemoryImage dan Uint8List
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) updateUserData;

  UpdateProfilePage({required this.userData, required this.updateUserData});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  Uint8List? _webImageBytes;

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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 80
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, store bytes directly
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          // For mobile, use File
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb) {
      return _webImageBytes != null
          ? MemoryImage(_webImageBytes!)
          : (widget.userData['profile'] != null && widget.userData['profile'].isNotEmpty
          ? NetworkImage(widget.userData['profile'])
          : null);
    } else {
      return _profileImage != null
          ? FileImage(_profileImage!)
          : (widget.userData['profile'] != null && widget.userData['profile'].isNotEmpty
          ? NetworkImage(widget.userData['profile'])
          : null);
    }
  }

  Future<String?> _uploadImage() async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('profile').child(fileName);

      if (kIsWeb) {
        if (_webImageBytes == null) return widget.userData['profile'];

        UploadTask uploadTask = ref.putData(_webImageBytes!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        return 'profile/$fileName'; // Return full storage path
      } else {
        if (_profileImage == null) return widget.userData['profile'];

        UploadTask uploadTask = ref.putFile(_profileImage!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        return 'profile/$fileName'; // Return full storage path
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;

        if (_profileImage != null) {
          imageUrl = await _uploadImage();
          if (imageUrl == null) {
            return null; // Jangan lanjutkan jika upload gagal
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
          'profile': imageUrl,
        };

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatedData);
          widget.updateUserData(updatedData);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        _showErrorSnackBar('Error saving profile: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
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
                backgroundImage: _getImageProvider(),
                child: _getImageProvider() == null
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
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
