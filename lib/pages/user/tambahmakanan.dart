import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:health_project_flutter/AuthProvider.dart';

class AddFoodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kotak pertama dengan GestureDetector
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ScanImage(), // Anda bisa memberikan data dummy untuk admin
                ),
              );
              // Tambahkan aksi lain di sini
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(16.0),
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_search,
                    size: 48.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Scan Gambar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Kotak kedua dengan GestureDetector
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualInputFood(), // Anda bisa memberikan data dummy untuk admin
                ),
              );
              // Tambahkan aksi lain di sini
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(16.0),
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 48.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Input Manual',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanImage extends StatelessWidget {
  const ScanImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
class ManualInputFood extends StatefulWidget {
  const ManualInputFood({super.key});

  @override
  State<ManualInputFood> createState() => _ManualInputFoodState();
}

class _ManualInputFoodState extends State<ManualInputFood> {
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int jumlahkalori = -1;
  String selectedUnit = 'Gram'; // Default dropdown value
  final List<String> foodUnits = ['Tangkai','Sisir (contoh: pisang)','Pack','Sachet','Box','Bungkus','Kaleng','Mangkok','Loyang','Porsi','Buah','Lembar','Potong','Iris','Butir','Batang','Mililiter (ml)','Liter (L)','Sendok Teh (sdt)','Sendok Makan (sdm)','Gelas','Gram','Kilogram'];
  final Gemini client = Gemini.instance;
  Future<int> _updateCalorieText() async {
    final response = await client.text(
        "apakah "+_calorieController.text+" merupakan makanan?jawab dengan iya atau tidak saja"
    );
    if(response!.content!.parts![0].text!.toLowerCase().contains("tidak")){
      isLoading.value = false;
      print("bukan makanan");
      return -1;
    }else{
      final response = await client.text(
          "Berapa perkiraan kalori dari "+_quantityController.text+" "+selectedUnit+" "+_calorieController.text+" jawab perkiraannya saja (dalam bentuk angka), jangan berikan teks lain"
      );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, value, child) {
              return value
                  ? Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading"),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Field "Masukkan Makanan"
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _calorieController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Masukkan Makanan',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Field "Jumlah"
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // Dropdown "Satuan"
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: foodUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedUnit = newValue!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Satuan',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Kalori : " + (jumlahkalori != -1 ? jumlahkalori.toString() : "Belum Diketahui"),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: ()async {
                        String calorie = _calorieController.text.trim();
                        String quantity = _quantityController.text.trim();
                        if (calorie.isEmpty || quantity.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Semua input harus terisi!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          isLoading.value = true;
                          var hasil = await _updateCalorieText();
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
                        }
                      },
                      child: Text('Dapatkan Perkiraan Kalori'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ElevatedButton(
            onPressed: jumlahkalori == -1 ? null : () {
              _firestore.collection('makananuser').add({
                'nama': _calorieController.text,
                'satuan': _quantityController.text+" "+selectedUnit,
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
            child: Text('Tambahkan Makanan'),
          ),
        ),
      ),
    );
  }
}

