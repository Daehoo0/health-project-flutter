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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text);
      final user = FirebaseAuth.instance.currentUser!;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final docId = userDoc.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({
            'saldo': FieldValue.increment(amount),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Top up berhasil! Saldo Anda telah diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
          _amountController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data pengguna tidak ditemukan.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saat memperbarui saldo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSnackbarMessage(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Masukkan jumlah saldo anda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Top Up (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _showSnackbarMessage('Masukkan jumlah top up!');
                    return 'Masukkan jumlah';
                  }
                  if (int.tryParse(value) == null) {
                    _showSnackbarMessage('Masukkan angka valid!');
                    return 'Masukkan angka valid';
                  }
                  if (int.parse(value) < 10000) {
                    _showSnackbarMessage('Minimal top up adalah Rp 10.000!');
                    return 'Minimal Rp 10.000';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitTopUp();
                  } else {
                    _showSnackbarMessage(
                        'Harap periksa kembali inputan Anda!',
                        backgroundColor: Colors.orange);
                  }
                },
                child: Text('Top Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
