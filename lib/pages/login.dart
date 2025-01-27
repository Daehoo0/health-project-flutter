import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/pages/admin/homeadmin.dart';
import 'package:health_project_flutter/pages/dokter/homedokter.dart';
import 'package:health_project_flutter/pages/register.dart';
import 'package:health_project_flutter/pages/user/homeuser.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Gagal', style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.teal)),
              ),
            ],
          );
        },
      );
    }

    Future<void> _login() async {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog('Email dan kata sandi tidak boleh kosong!');
        return;
      }

      // Periksa apakah email dan password sesuai untuk admin
      if (email == 'admin' && password == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeAdmin(userData: {}),
          ),
        );
        return;
      }

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;
        context.read<DataLogin>().setuserlogin(uid);

        // Ambil data pengguna berdasarkan UID
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          print(userData['role']);

          if (userData['role'] == 'dokter') {
            // Jika role adalah dokter, arahkan ke HomeDokter
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeDokter(userData: userData),
              ),
            );
          } else if (userData['role'] == 'Pasien') {
            // Jika role adalah pasien, arahkan ke HomeUser
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeUser(userData: userData),
              ),
            );
          } else {
            _showErrorDialog('Role tidak valid!');
          }
          return;
        } else {
          _showErrorDialog('Akun tidak ditemukan!');
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'Login gagal! Silakan coba lagi.');
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body:Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'lib/assets/login.json',
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.teal),
                        prefixIcon: Icon(Icons.email, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.teal.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi',
                        labelStyle: TextStyle(color: Colors.teal),
                        prefixIcon: Icon(Icons.lock, color: Colors.teal),
                        filled: true,
                        fillColor: Colors.teal.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shadowColor: Colors.teal.withOpacity(0.5),
                        elevation: 5,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Belum punya akun? Daftar di sini',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('|', style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigasi ke halaman lupa password
                          },
                          child: Text(
                            'Lupa Kata Sandi',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
