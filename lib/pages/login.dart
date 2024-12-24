import 'package:flutter/material.dart';
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

  void _login() {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email == 'admin' && password == 'admin') {
      // Navigate to HomeAdmin page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeAdmin()),
      );
    } else if (email == 'user' && password == 'user') {
      // Navigate to HomeUser page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeUser()),
      );
    } else if (email == 'dokter' && password == 'dokter') {
      // Navigate to HomeDokter page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeDokter()),
      );
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Gagal'),
            content: Text('Email atau Password salah.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated doctor illustration
                  Lottie.asset(
                    'lib/assets/login.json', // Ganti dengan path file dokter Lottie Anda
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Password field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Login button
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
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Links
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
                          // Navigate to forgot password page
                        },
                        child: Text(
                          'Lupa Password',
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
