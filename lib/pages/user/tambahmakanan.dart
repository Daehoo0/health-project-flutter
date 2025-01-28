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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ScanImage()),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                height: 160.0,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
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
                    SizedBox(height: 12.0),
                    Text(
                      'Scan Gambar',
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
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ManualInputFood()),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                height: 160.0,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6.0,
                      offset: Offset(0, 3),
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
                    SizedBox(height: 12.0),
                    Text(
                      'Input Manual',
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
  String selectedUnit = 'Gram';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Input Manual Makanan'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, value, child) {
              return value
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100),
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 20),
                    Text("Menghitung kalori...",
                        style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        )),
                  ],
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Makanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _calorieController,
                    decoration: InputDecoration(
                      labelText: 'Nama Makanan',
                      hintText: 'Contoh: Nasi Goreng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.fastfood),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.scale),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: foodUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit,
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedUnit = newValue!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Satuan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.straighten),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department,
                            color: Colors.teal, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Kalori: " + (jumlahkalori != -1
                              ? "$jumlahkalori kkal"
                              : "Belum Diketahui"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String calorie = _calorieController.text.trim();
                      String quantity = _quantityController.text.trim();
                      if (calorie.isEmpty || quantity.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Semua input harus terisi!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        isLoading.value = true;
                        var hasil = await _updateCalorieText();
                        if(hasil == -1){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Harap Masukkan Nama Makanan"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          setState(() {
                            jumlahkalori = hasil;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Dapatkan Perkiraan Kalori',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: jumlahkalori == -1 ? null : () {
            _firestore.collection('makananuser').add({
              'nama': _calorieController.text,
              'satuan': _quantityController.text+" "+selectedUnit,
              'kalori': jumlahkalori,
              'owner': context.read<DataLogin>().uiduser,
              'created_at': FieldValue.serverTimestamp(),
            }).then((value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil Menambahkan Makanan'),
                  backgroundColor: Colors.green,
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menyimpan data: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            disabledBackgroundColor: Colors.grey[300],
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Tambahkan Makanan',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}