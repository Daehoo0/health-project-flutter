import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitTopUp() async {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text);

      try {
        // Ambil email dari pengguna yang sedang login
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("Pengguna tidak login.");
        }
        String email = user.email!;

        // Cari dokumen berdasarkan email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Dapatkan ID dokumen pengguna dan saldo saat ini
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          String docId = userDoc.id;
          int currentBalance = userDoc.get('balance') ?? 0;

          // Update saldo baru
          int updatedBalance = currentBalance + amount;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'balance': updatedBalance});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Top up berhasil! Saldo sekarang: Rp $updatedBalance')),
          );

          // Reset input
          _amountController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pengguna dengan email tersebut tidak ditemukan.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Up Saldo'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan Jumlah Saldo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Saldo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah saldo tidak boleh kosong!';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null) {
                    return 'Masukkan angka yang valid!';
                  }
                  if (amount < 10000) {
                    return 'Jumlah saldo minimal Rp 10.000!';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitTopUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Text('Top Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
