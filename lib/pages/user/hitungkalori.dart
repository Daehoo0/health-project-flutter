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
  Future<Candidates> findPokemon({
    required File image,
  }) async {
    final response = await client.textAndImage(
        text: "hanya tampilkan nama makanan :  xxx perkiraan kalori : xxx jangan tampilkan yang lain, jangan berikan peringatan kalori berbeda beda, hanya tampilkan sesuai yang saya mau",
        images:[
          image.readAsBytesSync(),
        ]
    );
    print(response);
    if (response != null) {
      return response;
    }
    throw Exception("Failed to find pokemon");
  }

  @override
  Widget build(BuildContext context) {
    // findPokemon();
    return ElevatedButton(
      onPressed: () async {
        final image = await _pickImage(ImageSource.gallery);
        if (image != null) {
          findPokemon(image: image);
        }
      },
      child: Text('Pick Image'),
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