import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

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
      }

      final html.File file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      return reader.result as Uint8List?;
    } catch (e) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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