import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class CalorieCounterPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }
  final Gemini client = Gemini.instance;
  Future<String> findPokemon({
    required File image,
  }) async {
    final response = await client.textAndImage(
        text: "hanya tampilkan nama_makanan#perkiraan_kalori, jika bukan makanan tampilkan \"Harap Masukkan Gambar Makanan\"",
        images:[
          image.readAsBytesSync(),
        ]
    );
    return response!.content!.parts![0].text!;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contoh SnackBar"),
        ),
      body: ElevatedButton(
        onPressed: () async {
          final image = await _pickImage(ImageSource.gallery);
          if (image != null) {
            String hasilai = await findPokemon(image: image);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(hasilai),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Text('Pick Image'),
      ),
    );
  }
}
class ImagePickerExample extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
        child: FutureBuilder<File?>(
          future: null, // Initially, there's no image selected
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              return Image.file(snapshot.data!);
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No image selected.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // // final image = await _pickImage(ImageSource.camera);
                      // if (image != null) {
                      //   await f
                      // }
                    },
                    child: Text('Pick Image'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

  class ImageDisplayPage extends StatelessWidget {
  final File image;

  ImageDisplayPage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Image'),
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}