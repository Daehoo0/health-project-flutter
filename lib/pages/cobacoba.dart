import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UpdateProfilePage(),
    );
  }
}

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _base64String;
  Uint8List? _imageBytes;

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

  void _updateProfile() {
    if (_base64String != null) {
      print('Base64 String: $_base64String');
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
