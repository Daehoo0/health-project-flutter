import 'dart:convert';
import 'dart:typed_data'; // Untuk MemoryImage dan Uint8List
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/main.dart';
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
  final ImagePicker _picker = ImagePicker();
  String _base64String = "";
  Uint8List? _imageBytes;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _tinggiController;
  late TextEditingController _beratController;

  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void loadgambar() async{
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).get();
    List<Map<String, dynamic>> data = [];
    data.add(snapshot.data() as Map<String, dynamic>);
    _base64String = data[0]["profile"];
  }
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _genderController = TextEditingController(text: widget.userData['gender'] ?? '');
    _tinggiController = TextEditingController(text: widget.userData['height']?.toString() ?? '');
    _beratController = TextEditingController(text: widget.userData['weight']?.toString() ?? '');
    loadgambar();
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Handle image picking for web
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final bytes = await image.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _base64String = base64Encode(bytes);
          });
        }
      } else {
        // Handle image picking for mobile
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final File file = File(image.path);
          final bytes = await file.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _base64String = base64Encode(bytes);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
      await _firestore.collection('users').doc(context.read<DataLogin>().uiduser).update({
        'profile': _base64String,
      });
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        await _uploadImage();

        final updatedData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'gender': _genderController.text.trim(),
          'height': double.tryParse(_tinggiController.text) ?? 0.0,
          'weight': double.tryParse(_beratController.text) ?? 0.0,
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
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                  child: _imageBytes == null
                      ? const Icon(
                    Icons.camera_alt,
                    size: 40,
                  )
                      : null,
                ),
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
