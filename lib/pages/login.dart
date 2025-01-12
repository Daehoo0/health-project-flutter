import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:health_project_flutter/pages/register.dart';
import 'package:health_project_flutter/pages/admin/homeadmin.dart';
import 'package:health_project_flutter/pages/user/homeuser.dart';
import 'package:health_project_flutter/pages/dokter/homedokter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email dan kata sandi tidak boleh kosong!');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Cek apakah pengguna adalah dokter
      DocumentSnapshot doctorDoc = await _firestore.collection('users').doc(uid).get();
      if (doctorDoc.exists) {
        Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;

        // Verifikasi apakah role-nya 'dokter' dan email-nya sesuai
        if (doctorData['role'] == 'dokter' && doctorData['email'] == email) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDokter(userData: doctorData), // Berikan doctorData
            ),
          );
          return;
        }
      }

      // Cek apakah pengguna adalah pasien
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeUser(userData: userData ?? {}),
            ),
          );
        } else {
          _showErrorDialog('User data is incomplete or empty.');
        }
      } else {
        _showErrorDialog('User not found.');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Login gagal! Silakan coba lagi.');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
      ),
    );
  }
}
