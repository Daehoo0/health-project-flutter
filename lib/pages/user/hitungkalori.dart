import 'dart:io';
<<<<<<< HEAD
=======

import 'package:cloud_firestore/cloud_firestore.dart';
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

<<<<<<< HEAD
class CalorieCounterPage extends StatefulWidget {
  @override
  _CalorieCounterPageState createState() => _CalorieCounterPageState();
}

class _CalorieCounterPageState extends State<CalorieCounterPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Process image with Gemini
        await _processImage();
=======
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../AuthProvider.dart';
class Caloridarifoto extends StatefulWidget {
  const Caloridarifoto({super.key});

  @override
  State<Caloridarifoto> createState() => _CaloridarifotoState();
}

class _CaloridarifotoState extends State<Caloridarifoto> {
  final Gemini client = Gemini.instance;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var namamakanan = "";
  int jumlahkalori = -1;
  Future<Uint8List?> _pickImageWeb() async {
    try {
      final html.FileUploadInputElement uploadInput =
      html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      await uploadInput.onChange.first;

      if (uploadInput.files!.isEmpty) {
        return null;
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
      }

      final html.File file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      return reader.result as Uint8List?;
    } catch (e) {
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    try {
      final Gemini client = Gemini.instance;
      final response = await client.textAndImage(
        text: "hanya tampilkan nama_makanan#perkiraan_kalori, jika bukan makanan tampilkan \"Harap Masukkan Gambar Makanan\"",
        images: [_selectedImage!.readAsBytesSync()],
      );

      setState(() {
        _result = response?.content?.parts?[0].text ?? "Tidak dapat memproses gambar";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_result!),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
=======
      print("Error picking image: $e");
      return null;
    }
  }

  Future<int> findCalories({
    required Uint8List imageBytes,
  }) async {
    final response = await client.textAndImage(
        text: "apakah gambar berikut merupakan makanan?jawab dengan iya atau tidak saja",
        images:[imageBytes]
    );
    print(response!.content!.parts![0].text);
    if(response!.content!.parts![0].text!.toLowerCase().contains("tidak")){
      isLoading.value = false;
      print("bukan makanan");
      return -1;
    }else{
      var response = await client.textAndImage(
          text: "berikan nama makanannya saja dari foto ini, jangan berikan teks lain",
          images: [imageBytes]
      );
      namamakanan = response!.content!.parts![0].text!;
      print(response!.content!.parts![0].text!);
      response = await client.textAndImage(
          text: "Berapa perkiraan kalori dari gambar makanan berikut jawab perkiraannya saja (dalam bentuk angka), jangan berikan teks lain",
          images: [imageBytes]
      );
      print(response!.content!.parts![0].text!);
      if(response!.content!.parts![0].text!.split("-").length > 1){
        var hasil = response!.content!.parts![0].text!.split("-");
        isLoading.value = false;
        return ((int.parse(hasil[0])+int.parse(hasil[1]))/2).round();
      }else{
        isLoading.value = false;
        return int.parse(response!.content!.parts![0].text!);
      }
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: Text(
          "Penghitung Kalori",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_selectedImage != null) ...[
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
              if (_result != null) ...[
                Text(
                  _result!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
              ],
              if (_isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Pilih dari Galeri'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Ambil Foto'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
=======
        appBar: AppBar(
          title: Text("Contoh SnackBar"),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                isLoading.value = true;
                final imageBytes = await _pickImageWeb();
                var hasil = await findCalories(imageBytes: imageBytes!);
                if(hasil == -1){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Harap Masukkan Nama Makanan"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }else{
                  setState(() {
                    jumlahkalori = hasil;
                  });
                }
              },
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10,),
            Text(
              "Kalori : " + (jumlahkalori != -1 ? jumlahkalori.toString() : "Belum Diketahui"),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: jumlahkalori == -1 ? null : () {
                  _firestore.collection('makananuser').add({
                    'nama': namamakanan,
                    'satuan': "",
                    'kalori': jumlahkalori,
                    'owner': context.read<DataLogin>().uiduser,
                    'created_at': FieldValue.serverTimestamp(),
                  }).then((value) {
                    // Kembali ke halaman sebelumnya setelah berhasil menyimpan
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Berhasil Menambahkan Makanan')),
                    );
                  }).catchError((error) {
                    // Menampilkan pesan error jika gagal menyimpan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan data: $error')),
                    );
                  });
                },
                child: Text('Simpan Data'),
              ),
            ),
          ],
        )
    );
  }
}
>>>>>>> c286ca1aa4a06390d113cc7ef3acd791ca387f64
